// ================================================================================
// src/services/ApiService.js - COMPATIBLE CON WEB Y MÓVIL + ERRORES MEJORADOS
// ================================================================================
import axios from 'axios';
import StorageService from './StorageService';
import { API_BASE_URL } from '@env';

class ApiService {
  
  // ============ MANEJO DE TOKENS ============
  
  static async saveToken(token) {
    try {
      await StorageService.setItem('session_token', token);
      console.log('✅ Token guardado exitosamente');
    } catch (error) {
      console.error('❌ Error saving token:', error);
    }
  }
  
  static async getToken() {
    try {
      const token = await StorageService.getItem('session_token');
      return token;
    } catch (error) {
      console.error('❌ Error getting token:', error);
      return null;
    }
  }
  
  static async removeToken() {
    try {
      await StorageService.removeItem('session_token');
      console.log('🗑️ Token eliminado');
    } catch (error) {
      console.error('❌ Error removing token:', error);
    }
  }
  
  // ============ FUNCIONES DE DEBUG ============
  
  static async getStorageInfo() {
    return await StorageService.getStorageInfo();
  }
  
  static async debugToken() {
    const info = await this.getStorageInfo();
    console.log('🔍 Debug Token Info:', info);
    return info;
  }
  
  // ============ INTERCEPTORES AXIOS ============
  
  static setupInterceptors() {
    // Interceptor para agregar token a todas las requests
    axios.interceptors.request.use(
      async (config) => {
        const token = await this.getToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
          console.log(`🔑 Token agregado a request: ${config.url}`);
        } else {
          console.log(`⚠️ No hay token disponible para: ${config.url}`);
        }
        return config;
      },
      (error) => {
        console.error('❌ Error en request interceptor:', error);
        return Promise.reject(error);
      }
    );
    
    // Interceptor para manejar respuestas de error 401 (no autorizado)
    axios.interceptors.response.use(
      (response) => {
        console.log(`✅ Response exitosa: ${response.config.url}`);
        return response;
      },
      async (error) => {
        console.log(`❌ Error en response: ${error.config?.url}`, error.response?.status);
        
        if (error.response?.status === 401) {
          console.log('🚨 Token inválido o expirado, limpiando almacenamiento');
          await this.removeToken();
          
          // Emitir evento personalizado para que la app sepa que debe redirigir al login
          if (typeof window !== 'undefined') {
            window.dispatchEvent(new CustomEvent('token_expired'));
          }
        }
        return Promise.reject(error);
      }
    );
    
    console.log('🔧 Interceptores de Axios configurados');
  }
  
  // ============ AUTENTICACIÓN ============
  
  static async login(correo, clave) {
    try {
      console.log('🔐 Intentando login para:', correo);
      
      const response = await axios.post(`${API_BASE_URL}/login.php`, {
        correo,
        clave
      });
      
      console.log('📨 Respuesta del servidor:', response.data);
      
      // Si el login es exitoso y retorna un token, guardarlo
      if (response.data.success && response.data.token) {
        await this.saveToken(response.data.token);
        console.log('🎉 Login exitoso, token guardado');
      }
      
      return response.data;
    } catch (error) {
      console.log('❌ Error en login:', error.response?.data);
      
      // 🆕 MANEJO MEJORADO DE ERRORES ESPECÍFICOS
      if (error.response) {
        const status = error.response.status;
        const data = error.response.data;
        
        let errorMessage = 'Error del servidor';
        
        switch (status) {
          case 400:
            errorMessage = data?.error || data?.message || 'Datos de entrada inválidos';
            break;
          case 401:
            // Manejar específicamente errores de credenciales
            if (data?.error?.includes('Credenciales') || 
                data?.error?.includes('inválidas') ||
                data?.error?.includes('Invalid') ||
                data?.error?.includes('credentials') ||
                data?.message?.includes('password') ||
                data?.message?.includes('user')) {
              errorMessage = 'Credenciales inválidas';
            } else {
              errorMessage = data?.error || data?.message || 'No autorizado';
            }
            break;
          case 403:
            errorMessage = 'Acceso denegado';
            break;
          case 404:
            errorMessage = 'Servicio no encontrado. Contacte al administrador.';
            break;
          case 422:
            errorMessage = data?.error || data?.message || 'Datos inválidos';
            break;
          case 429:
            errorMessage = 'Demasiados intentos. Espere unos minutos e intente nuevamente.';
            break;
          case 500:
            errorMessage = 'Error interno del servidor. Intente nuevamente en unos momentos.';
            break;
          case 502:
          case 503:
          case 504:
            errorMessage = 'Servidor no disponible. Intente nuevamente en unos momentos.';
            break;
          default:
            errorMessage = data?.error || data?.message || `Error del servidor (${status})`;
            break;
        }
        
        throw new Error(errorMessage);
        
      } else if (error.request) {
        // Error de conexión
        if (error.code === 'NETWORK_ERROR' || error.code === 'ECONNREFUSED') {
          throw new Error('No se pudo conectar con el servidor. Verifica tu conexión a internet.');
        } else if (error.code === 'TIMEOUT') {
          throw new Error('Tiempo de espera agotado. Intente nuevamente.');
        } else {
          throw new Error('No se pudo conectar con el servidor. Verifica tu conexión a internet.');
        }
      } else {
        // Error al configurar la petición
        throw new Error('Error en la petición: ' + error.message);
      }
    }
  }
  
  static async logout() {
    try {
      console.log('🚪 Cerrando sesión...');
      
      const token = await this.getToken();
      if (token) {
        try {
          await axios.post(`${API_BASE_URL}/logout.php`, { token });
          console.log('✅ Logout exitoso en servidor');
        } catch (error) {
          console.log('⚠️ Error en logout del servidor (continuando):', error.response?.data);
        }
      }
      
      await this.removeToken();
      console.log('🧹 Token local eliminado');
      
      return { success: true };
    } catch (error) {
      console.log('❌ Error en logout:', error);
      // Aunque falle el logout en el servidor, limpiar token local
      await this.removeToken();
      throw new Error('Error al cerrar sesión');
    }
  }
  
  static async validateSession() {
    try {
      const token = await this.getToken();
      if (!token) {
        console.log('❌ No hay token almacenado');
        return { valid: false, error: 'No hay token almacenado' };
      }
      
      console.log('🔍 Validando sesión...');
      
      const response = await axios.post(`${API_BASE_URL}/validate_session.php`, {
        token
      });
      
      console.log('✅ Sesión validada:', response.data);
      return response.data;
    } catch (error) {
      console.log('❌ Error validando sesión:', error.response?.data);
      if (error.response) {
        const errorMessage = error.response.data?.error || 'Error validando sesión';
        return { valid: false, error: errorMessage };
      } else if (error.request) {
        return { valid: false, error: 'No se pudo conectar con el servidor' };
      } else {
        return { valid: false, error: 'Error en la petición' };
      }
    }
  }
  
  static async isLoggedIn() {
    const result = await this.validateSession();
    return result.valid;
  }
  
  static async getCurrentUser() {
    const result = await this.validateSession();
    return result.valid ? result.user : null;
  }
  
  // ============ RESETEO DE CONTRASEÑA ============
  
  static async requestPasswordReset(correo, claveActual, nuevaClave) {
    try {
      console.log('🔄 Solicitando reseteo de contraseña para:', correo);
      
      const response = await axios.post(`${API_BASE_URL}/reset_password.php`, {
        correo,
        claveActual,
        nuevaClave
      });
      
      console.log('✅ Reseteo solicitado exitosamente:', response.data);
      return response.data;
    } catch (error) {
      console.log('❌ Error en reseteo:', error.response?.data);
      
      if (error.response) {
        const errorMessage = error.response.data?.error || 
                            error.response.data?.message || 
                            `Error del servidor (${error.response.status})`;
        throw new Error(errorMessage);
      } else if (error.request) {
        throw new Error('No se pudo conectar con el servidor. Verifica tu conexión a internet.');
      } else {
        throw new Error('Error en la petición: ' + error.message);
      }
    }
  }

  static async verifyResetToken(token) {
    try {
      const response = await axios.get(`${API_BASE_URL}/verify_reset_token.php?token=${token}`);
      return response.data;
    } catch (error) {
      console.log('❌ Error en verifyResetToken:', error.response?.data);
      if (error.response) {
        const errorMessage = error.response.data?.error || error.response.data?.message || 'Error del servidor';
        throw new Error(errorMessage);
      } else if (error.request) {
        throw new Error('No se pudo conectar con el servidor. Verifica tu conexión a internet.');
      } else {
        throw new Error('Error en la petición: ' + error.message);
      }
    }
  }
  
  // ============ MÉTODOS PROTEGIDOS (Requieren autenticación) ============
  
  static async getProtectedData(endpoint) {
    try {
      console.log(`🔒 Solicitando datos protegidos: ${endpoint}`);
      const response = await axios.get(`${API_BASE_URL}/${endpoint}`);
      return response.data;
    } catch (error) {
      if (error.response?.status === 401) {
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw error;
    }
  }
  
  static async postProtectedData(endpoint, data) {
    try {
      console.log(`🔒 Enviando datos protegidos: ${endpoint}`);
      const response = await axios.post(`${API_BASE_URL}/${endpoint}`, data);
      return response.data;
    } catch (error) {
      if (error.response?.status === 401) {
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw error;
    }
  }
}

// Configurar interceptores al cargar el módulo
ApiService.setupInterceptors();

export default ApiService;