// ================================================================================
// ARCHIVO: front/src/screens/LoginScreen.js - CON BOTÓN CAMBIAR CLAVE
// ================================================================================

import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import ApiService from '../services/ApiService';

const LoginScreen = ({ navigation, onLogin }) => {
  const [correo, setCorreo] = useState('');
  const [clave, setClave] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const handleLogin = async () => {
    // Limpiar mensaje de error previo
    setErrorMessage('');

    if (!correo.trim() || !clave.trim()) {
      setErrorMessage('Por favor ingrese correo y contraseña');
      return;
    }

    // Validar formato de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      setErrorMessage('Por favor ingrese un correo electrónico válido');
      return;
    }

    setLoading(true);
    try {
      console.log('🔐 Iniciando login...');
      const response = await ApiService.login(correo, clave);
      
      console.log('📨 Respuesta del login:', response);
      
      if (response.needsPasswordReset) {
        console.log('🔄 Redirigiendo a reseteo de contraseña');
        navigation.navigate('PasswordReset', { 
          correo: response.correo,
          usuario: response.usuario
        });
      } else if (response.success) {
        console.log('🎉 Login exitoso!');
        console.log('👤 Usuario:', response.user);
        console.log('🔑 Token recibido:', response.token?.substring(0, 16) + '...');
        
        if (typeof onLogin === 'function') {
          console.log('✅ onLogin es una función, llamándola INMEDIATAMENTE...');
          onLogin(response.user);
          console.log('🚀 onLogin ejecutado exitosamente');
        } else {
          console.error('❌ onLogin no es una función:', typeof onLogin);
          setErrorMessage('Error en la navegación. onLogin no está definido.');
        }
      }
    } catch (error) {
      console.log('❌ Error en login:', error);
      
      let errorMsg = 'Error al iniciar sesión';
      
      if (error.message) {
        if (error.message.includes('Credenciales inválidas') || 
            error.message.includes('Invalid credentials') ||
            error.message.includes('Usuario o contraseña incorrectos')) {
          errorMsg = '❌ Usuario o contraseña incorrectos. Verifique sus datos e intente nuevamente.';
        } else if (error.message.includes('conectar') || 
                   error.message.includes('connection') ||
                   error.message.includes('network')) {
          errorMsg = '🌐 Error de conexión. Verifique su conexión a internet.';
        } else if (error.message.includes('servidor') || 
                   error.message.includes('server')) {
          errorMsg = '🔧 Error del servidor. Intente nuevamente en unos momentos.';
        } else {
          errorMsg = `⚠️ ${error.message}`;
        }
      }
      
      setErrorMessage(errorMsg);
      
      // Mostrar Alert solo para errores críticos (no credenciales)
      if (error.message && !error.message.includes('Credenciales inválidas')) {
        Alert.alert('Error', errorMsg);
      }
      
    } finally {
      setLoading(false);
    }
  };

  // 🆕 NUEVA FUNCIÓN: Manejar cambio de contraseña
  const handlePasswordChange = () => {
    // Limpiar error previo
    setErrorMessage('');

    // Verificar que hay email
    if (!correo.trim()) {
      setErrorMessage('Ingrese su correo electrónico para cambiar la contraseña');
      return;
    }
    
    // Validar formato email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      setErrorMessage('Ingrese un correo electrónico válido para cambiar la contraseña');
      return;
    }
    
    // Navegar a reseteo con el email
    console.log('🔄 Navegando a cambio de contraseña para:', correo);
    navigation.navigate('PasswordReset', { 
      correo: correo,
      fromLogin: true // Para identificar que viene del login
    });
  };

  const handlePasswordSubmit = () => {
    console.log('⚡ Enter presionado en contraseña - Iniciando login automáticamente');
    handleLogin();
  };

  // Funciones de debug (solo para desarrollo extremo)
  const handleDebugInfo = async () => {
    try {
      const token = await ApiService.getToken();
      const storageInfo = await ApiService.getStorageInfo();
      
      console.log('🔍 DEBUG INFO COMPLETO:');
      console.log('Token actual:', token);
      console.log('Storage info:', storageInfo);
      console.log('onLogin type:', typeof onLogin);
      console.log('navigation:', navigation);
      
      if (typeof window !== 'undefined' && window.localStorage) {
        const directToken = localStorage.getItem('session_token');
        console.log('Token directo de localStorage:', directToken);
      }
      
      Alert.alert(
        'Debug Info',
        `Token: ${token ? 'Existe ✅' : 'No existe ❌'}\n` +
        `Platform: ${storageInfo?.platform || 'N/A'}\n` +
        `Storage: ${storageInfo?.storage_type || 'N/A'}\n` +
        `onLogin: ${typeof onLogin}\n` +
        `Navigation: ${navigation ? 'OK ✅' : 'Error ❌'}`
      );
    } catch (error) {
      console.error('Error en debug:', error);
      Alert.alert('Error Debug', error.message);
    }
  };

  const forceNavigation = () => {
    if (typeof onLogin === 'function') {
      console.log('🧪 FORZANDO NAVEGACIÓN...');
      onLogin({
        id: 'test',
        nombres: 'Usuario',
        apellidos: 'Prueba',
        correo: 'test@test.com'
      });
    } else {
      Alert.alert('Error', 'onLogin no es una función');
    }
  };

  return (
    <KeyboardAvoidingView 
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.logoContainer}>
          <Ionicons name="medical" size={80} color="#2196F3" />
          <Text style={styles.title}>AtencionesFSA Formosa</Text>
          <Text style={styles.subtitle}>Sistema de Gestión</Text>
        </View>

        <View style={styles.formContainer}>
          {/* MENSAJE DE ERROR PROMINENTE */}
          {errorMessage ? (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={20} color="#f44336" />
              <Text style={styles.errorText}>{errorMessage}</Text>
            </View>
          ) : null}

          <View style={[
            styles.inputContainer,
            errorMessage && errorMessage.includes('correo') ? styles.inputError : null
          ]}>
            <Ionicons name="mail-outline" size={20} color="#666" style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Correo electrónico"
              value={correo}
              onChangeText={(text) => {
                setCorreo(text);
                if (errorMessage) setErrorMessage('');
              }}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              returnKeyType="next"
              onSubmitEditing={() => {
                this.passwordInput?.focus();
              }}
            />
          </View>

          <View style={[
            styles.inputContainer,
            errorMessage && (errorMessage.includes('contraseña') || errorMessage.includes('incorrectos')) ? styles.inputError : null
          ]}>
            <Ionicons name="lock-closed-outline" size={20} color="#666" style={styles.inputIcon} />
            <TextInput
              ref={(input) => { this.passwordInput = input; }}
              style={[styles.input, styles.passwordInput]}
              placeholder="Contraseña"
              value={clave}
              onChangeText={(text) => {
                setClave(text);
                if (errorMessage) setErrorMessage('');
              }}
              secureTextEntry={!showPassword}
              autoCapitalize="none"
              autoCorrect={false}
              returnKeyType="go"
              onSubmitEditing={handlePasswordSubmit}
            />
            <TouchableOpacity
              style={styles.eyeIcon}
              onPress={() => setShowPassword(!showPassword)}
            >
              <Ionicons 
                name={showPassword ? "eye-outline" : "eye-off-outline"} 
                size={20} 
                color="#666" 
              />
            </TouchableOpacity>
          </View>

          {/* BOTÓN PRINCIPAL: INICIAR SESIÓN */}
          <TouchableOpacity
            style={[styles.loginButton, loading && styles.loginButtonDisabled]}
            onPress={handleLogin}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.loginButtonText}>Iniciar Sesión</Text>
            )}
          </TouchableOpacity>

          {/* 🆕 BOTÓN SECUNDARIO: CAMBIAR CLAVE */}
          <TouchableOpacity
            style={styles.changePasswordButton}
            onPress={handlePasswordChange}
            disabled={loading}
          >
            <Ionicons name="key-outline" size={18} color="#FF9800" style={styles.changePasswordIcon} />
            <Text style={styles.changePasswordText}>Cambiar Contraseña</Text>
          </TouchableOpacity>

          {/* 🔧 BOTONES DEBUG - SOLO EN DESARROLLO EXTREMO */}
          {__DEV__ && false && (
            <View style={styles.debugContainer}>
              <TouchableOpacity
                style={styles.debugButton}
                onPress={handleDebugInfo}
              >
                <Ionicons name="bug-outline" size={16} color="#FF9800" />
                <Text style={styles.debugButtonText}>Debug Info</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.forceButton}
                onPress={forceNavigation}
              >
                <Ionicons name="arrow-forward" size={16} color="#4CAF50" />
                <Text style={styles.forceButtonText}>Forzar Home</Text>
              </TouchableOpacity>
            </View>
          )}

          <View style={styles.helpContainer}>
            <Text style={styles.helpText}>
              📝 Para primer acceso use: 12345
            </Text>
            <Text style={styles.helpSubText}>
              Se le solicitará crear una nueva contraseña
            </Text>
            <Text style={styles.helpSubText}>
              💡 Presione Enter en la contraseña para ingresar rápidamente
            </Text>
          </View>

          <View style={styles.testContainer}>
            <Text style={styles.testTitle}>🧪 Datos de Prueba:</Text>
            <Text style={styles.testText}>Email: test@example.com</Text>
            <Text style={styles.testText}>Clave: 12345</Text>
            <TouchableOpacity 
              style={styles.autoFillButton}
              onPress={() => {
                setCorreo('test@example.com');
                setClave('12345');
                setErrorMessage('');
              }}
            >
              <Text style={styles.autoFillText}>Rellenar automáticamente</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContainer: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 20,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2196F3',
    marginTop: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginTop: 5,
  },
  formContainer: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
    ...(Platform.OS === 'web' ? {
      boxShadow: '0px 2px 3.84px rgba(0, 0, 0, 0.1)',
    } : {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 3.84,
      elevation: 5,
    }),
  },
  // ESTILOS PARA MENSAJES DE ERROR
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffebee',
    borderWidth: 1,
    borderColor: '#f44336',
    borderRadius: 8,
    padding: 12,
    marginBottom: 15,
  },
  errorText: {
    color: '#c62828',
    fontSize: 14,
    marginLeft: 8,
    flex: 1,
    fontWeight: '500',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    marginBottom: 15,
    paddingHorizontal: 15,
    backgroundColor: '#f9f9f9',
  },
  inputError: {
    borderColor: '#f44336',
    borderWidth: 2,
    backgroundColor: '#ffebee',
  },
  inputIcon: {
    marginRight: 10,
  },
  input: {
    flex: 1,
    height: 50,
    fontSize: 16,
    color: '#333',
  },
  passwordInput: {
    paddingRight: 40,
  },
  eyeIcon: {
    position: 'absolute',
    right: 15,
    padding: 5,
  },
  loginButton: {
    backgroundColor: '#2196F3',
    borderRadius: 8,
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 10,
  },
  loginButtonDisabled: {
    backgroundColor: '#ccc',
  },
  loginButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  // 🆕 ESTILOS PARA BOTÓN CAMBIAR CONTRASEÑA
  changePasswordButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff3e0',
    borderWidth: 2,
    borderColor: '#FF9800',
    borderRadius: 8,
    height: 45,
    marginTop: 10,
  },
  changePasswordIcon: {
    marginRight: 8,
  },
  changePasswordText: {
    color: '#FF9800',
    fontSize: 16,
    fontWeight: '600',
  },
  // ESTILOS DEBUG (OCULTOS)
  debugContainer: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 10,
  },
  debugButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#FFF3E0',
    borderWidth: 1,
    borderColor: '#FF9800',
    borderRadius: 8,
    height: 40,
  },
  debugButtonText: {
    color: '#FF9800',
    fontSize: 12,
    marginLeft: 5,
    fontWeight: 'bold',
  },
  forceButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#E8F5E8',
    borderWidth: 1,
    borderColor: '#4CAF50',
    borderRadius: 8,
    height: 40,
  },
  forceButtonText: {
    color: '#4CAF50',
    fontSize: 12,
    marginLeft: 5,
    fontWeight: 'bold',
  },
  helpContainer: {
    marginTop: 20,
    padding: 15,
    backgroundColor: '#e3f2fd',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
  },
  helpText: {
    color: '#1976d2',
    fontSize: 14,
    textAlign: 'center',
    fontWeight: '600',
  },
  helpSubText: {
    color: '#1976d2',
    fontSize: 12,
    textAlign: 'center',
    fontStyle: 'italic',
    marginTop: 5,
  },
  testContainer: {
    marginTop: 15,
    padding: 15,
    backgroundColor: '#f3e5f5',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#9C27B0',
  },
  testTitle: {
    color: '#7B1FA2',
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  testText: {
    color: '#7B1FA2',
    fontSize: 13,
    marginBottom: 2,
  },
  autoFillButton: {
    backgroundColor: '#9C27B0',
    borderRadius: 6,
    padding: 8,
    marginTop: 10,
    alignItems: 'center',
  },
  autoFillText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
});

export default LoginScreen;