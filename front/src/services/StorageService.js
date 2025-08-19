// ================================================================================
// STORAGE SERVICE - front/src/services/StorageService.js
// Compatible con WEB y MÓVIL
// ================================================================================

import { Platform } from 'react-native';

class StorageService {
  static isWeb = Platform.OS === 'web';
  
  // Detectar si AsyncStorage está disponible
  static getAsyncStorage() {
    try {
      // Importar dinámicamente AsyncStorage solo si no estamos en web
      if (!this.isWeb) {
        return require('@react-native-async-storage/async-storage').default;
      }
      return null;
    } catch (error) {
      console.log('AsyncStorage no disponible:', error);
      return null;
    }
  }

  /**
   * Guardar un valor en el almacenamiento
   */
  static async setItem(key, value) {
    try {
      if (this.isWeb) {
        // En web usar localStorage
        if (typeof window !== 'undefined' && window.localStorage) {
          localStorage.setItem(key, value);
          console.log(`🌐 Token guardado en localStorage: ${key}`);
        } else {
          console.error('localStorage no disponible');
        }
      } else {
        // En móvil usar AsyncStorage
        const AsyncStorage = this.getAsyncStorage();
        if (AsyncStorage) {
          await AsyncStorage.setItem(key, value);
          console.log(`📱 Token guardado en AsyncStorage: ${key}`);
        } else {
          console.error('AsyncStorage no disponible');
        }
      }
    } catch (error) {
      console.error('Error guardando en storage:', error);
    }
  }

  /**
   * Obtener un valor del almacenamiento
   */
  static async getItem(key) {
    try {
      if (this.isWeb) {
        // En web usar localStorage
        if (typeof window !== 'undefined' && window.localStorage) {
          const value = localStorage.getItem(key);
          console.log(`🌐 Token obtenido de localStorage: ${key} = ${value ? value.substring(0, 8) + '...' : 'null'}`);
          return value;
        } else {
          console.error('localStorage no disponible');
          return null;
        }
      } else {
        // En móvil usar AsyncStorage
        const AsyncStorage = this.getAsyncStorage();
        if (AsyncStorage) {
          const value = await AsyncStorage.getItem(key);
          console.log(`📱 Token obtenido de AsyncStorage: ${key} = ${value ? value.substring(0, 8) + '...' : 'null'}`);
          return value;
        } else {
          console.error('AsyncStorage no disponible');
          return null;
        }
      }
    } catch (error) {
      console.error('Error obteniendo de storage:', error);
      return null;
    }
  }

  /**
   * Eliminar un valor del almacenamiento
   */
  static async removeItem(key) {
    try {
      if (this.isWeb) {
        // En web usar localStorage
        if (typeof window !== 'undefined' && window.localStorage) {
          localStorage.removeItem(key);
          console.log(`🌐 Token eliminado de localStorage: ${key}`);
        } else {
          console.error('localStorage no disponible');
        }
      } else {
        // En móvil usar AsyncStorage
        const AsyncStorage = this.getAsyncStorage();
        if (AsyncStorage) {
          await AsyncStorage.removeItem(key);
          console.log(`📱 Token eliminado de AsyncStorage: ${key}`);
        } else {
          console.error('AsyncStorage no disponible');
        }
      }
    } catch (error) {
      console.error('Error eliminando de storage:', error);
    }
  }

  /**
   * Obtener información del almacenamiento para debug
   */
  static async getStorageInfo() {
    const keys = await this.getAllKeys();
    const info = {
      platform: this.isWeb ? 'web' : 'mobile',
      storage_type: this.isWeb ? 'localStorage' : 'AsyncStorage',
      total_keys: keys.length,
      keys: keys,
      session_token_exists: keys.includes('session_token')
    };
    
    if (keys.includes('session_token')) {
      const token = await this.getItem('session_token');
      info.token_preview = token ? token.substring(0, 16) + '...' : null;
    }
    
    return info;
  }

  /**
   * Obtener todas las claves del almacenamiento
   */
  static async getAllKeys() {
    try {
      if (this.isWeb) {
        if (typeof window !== 'undefined' && window.localStorage) {
          return Object.keys(localStorage);
        }
        return [];
      } else {
        const AsyncStorage = this.getAsyncStorage();
        if (AsyncStorage) {
          return await AsyncStorage.getAllKeys();
        }
        return [];
      }
    } catch (error) {
      console.error('Error obteniendo claves:', error);
      return [];
    }
  }
}

export default StorageService;