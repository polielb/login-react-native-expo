// ================================================================================
// PasswordResetScreen.js - CON SOPORTE PARA NAVEGACIÓN DESDE LOGIN
// ================================================================================
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import ApiService from '../services/ApiService';
import AlertService from '../services/AlertService';

const PasswordResetScreen = ({ navigation, route }) => {
  const { correo, usuario, fromLogin } = route.params || {};
  const [correoField, setCorreoField] = useState(correo || '');
  const [claveActual, setClaveActual] = useState('');
  const [nuevaClave, setNuevaClave] = useState('');
  const [confirmarClave, setConfirmarClave] = useState('');
  const [loading, setLoading] = useState(false);
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  useEffect(() => {
    if (usuario && !fromLogin) {
      // Solo mostrar alerta si NO viene del login (es decir, viene de reseteo forzado)
      AlertService.show(
        'Reseteo de Contraseña Requerido',
        `Hola ${usuario}, necesitas configurar una nueva contraseña para continuar.`,
        [{ text: 'Entendido' }]
      );
    } else if (fromLogin) {
      // Si viene del login, mostrar mensaje informativo diferente
      console.log('🔄 Usuario viene del login para cambiar contraseña voluntariamente');
    }
  }, [usuario, fromLogin]);

  const validateForm = () => {
    if (!correoField.trim()) {
      AlertService.showError('Por favor ingrese su correo electrónico');
      return false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correoField)) {
      AlertService.showError('Por favor ingrese un correo electrónico válido');
      return false;
    }

    if (!claveActual.trim()) {
      AlertService.showError('Por favor ingrese su contraseña actual');
      return false;
    }

    if (!nuevaClave.trim()) {
      AlertService.showError('Por favor ingrese la nueva contraseña');
      return false;
    }

    if (nuevaClave.length < 6) {
      AlertService.showError('La nueva contraseña debe tener al menos 6 caracteres');
      return false;
    }

    if (nuevaClave !== confirmarClave) {
      AlertService.showError('Las contraseñas no coinciden');
      return false;
    }

    if (nuevaClave === claveActual) {
      AlertService.showError('La nueva contraseña debe ser diferente a la actual');
      return false;
    }

    return true;
  };

  const handlePasswordReset = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      console.log('Iniciando proceso de reseteo para:', correoField);
      
      const response = await ApiService.requestPasswordReset(correoField, claveActual, nuevaClave);
      
      console.log('Respuesta del servidor:', response);
      
      if (response.success) {
        AlertService.show(
          '📧 Email Enviado',
          'Se ha enviado un correo con el enlace de confirmación.\n\n⚠️ IMPORTANTE: Debes hacer click en el enlace del email para completar el cambio de contraseña.',
          [
            {
              text: 'Entendido',
              onPress: () => navigation.navigate('Login')
            }
          ]
        );
      } else {
        const errorMessage = response.error || response.message || 'Error desconocido del servidor';
        AlertService.showError(errorMessage);
      }
    } catch (error) {
      console.log('Error capturado en handlePasswordReset:', error);
      console.log('Mensaje del error:', error.message);
      
      AlertService.showError(
        error.message || 'Error desconocido al solicitar reseteo de contraseña'
      );
    } finally {
      setLoading(false);
    }
  };

  // 🆕 NUEVA FUNCIÓN: Cancelar y volver al login
  const handleCancel = () => {
    navigation.navigate('Login');
  };

  return (
    <KeyboardAvoidingView 
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.headerContainer}>
          <Ionicons name="key" size={60} color="#FF9800" />
          <Text style={styles.title}>
            {fromLogin ? 'Cambiar Contraseña' : 'Configurar Nueva Contraseña'}
          </Text>
          {usuario && !fromLogin && (
            <Text style={styles.subtitle}>
              Usuario: {usuario}
            </Text>
          )}
          <Text style={styles.description}>
            {fromLogin ? 
              'Cambie su contraseña actual por una nueva' :
              'Configure su nueva contraseña de acceso segura'
            }
          </Text>
        </View>

        <View style={styles.formContainer}>
          <View style={styles.inputContainer}>
            <Ionicons name="mail-outline" size={20} color="#666" style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Correo electrónico"
              value={correoField}
              onChangeText={setCorreoField}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              editable={!correo} // Solo editable si no viene pre-llenado
            />
          </View>

          <View style={styles.inputContainer}>
            <Ionicons name="lock-closed-outline" size={20} color="#666" style={styles.inputIcon} />
            <TextInput
              style={[styles.input, styles.passwordInput]}
              placeholder="Contraseña actual"
              value={claveActual}
              onChangeText={setClaveActual}
              secureTextEntry={!showCurrentPassword}
              autoCapitalize="none"
              autoCorrect={false}
            />
            <TouchableOpacity
              style={styles.eyeIcon}
              onPress={() => setShowCurrentPassword(!showCurrentPassword)}
            >
              <Ionicons 
                name={showCurrentPassword ? "eye-outline" : "eye-off-outline"} 
                size={20} 
                color="#666" 
              />
            </TouchableOpacity>
          </View>

          <View style={styles.inputContainer}>
            <Ionicons name="lock-closed" size={20} color="#666" style={styles.inputIcon} />
            <TextInput
              style={[styles.input, styles.passwordInput]}
              placeholder="Nueva contraseña"
              value={nuevaClave}
              onChangeText={setNuevaClave}
              secureTextEntry={!showNewPassword}
              autoCapitalize="none"
              autoCorrect={false}
            />
            <TouchableOpacity
              style={styles.eyeIcon}
              onPress={() => setShowNewPassword(!showNewPassword)}
            >
              <Ionicons 
                name={showNewPassword ? "eye-outline" : "eye-off-outline"} 
                size={20} 
                color="#666" 
              />
            </TouchableOpacity>
          </View>

          <View style={styles.inputContainer}>
            <Ionicons name="checkmark-circle-outline" size={20} color="#666" style={styles.inputIcon} />
            <TextInput
              style={[styles.input, styles.passwordInput]}
              placeholder="Confirmar nueva contraseña"
              value={confirmarClave}
              onChangeText={setConfirmarClave}
              secureTextEntry={!showConfirmPassword}
              autoCapitalize="none"
              autoCorrect={false}
            />
            <TouchableOpacity
              style={styles.eyeIcon}
              onPress={() => setShowConfirmPassword(!showConfirmPassword)}
            >
              <Ionicons 
                name={showConfirmPassword ? "eye-outline" : "eye-off-outline"} 
                size={20} 
                color="#666" 
              />
            </TouchableOpacity>
          </View>

          {/* BOTONES DE ACCIÓN */}
          <View style={styles.buttonContainer}>
            <TouchableOpacity
              style={[styles.resetButton, loading && styles.resetButtonDisabled]}
              onPress={handlePasswordReset}
              disabled={loading}
            >
              {loading ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <Text style={styles.resetButtonText}>
                  {fromLogin ? 'Enviar Solicitud de Cambio' : 'Solicitar Cambio de Contraseña'}
                </Text>
              )}
            </TouchableOpacity>

            {/* 🆕 BOTÓN CANCELAR (solo si viene del login) */}
            {fromLogin && (
              <TouchableOpacity
                style={styles.cancelButton}
                onPress={handleCancel}
                disabled={loading}
              >
                <Text style={styles.cancelButtonText}>Cancelar</Text>
              </TouchableOpacity>
            )}
          </View>

          <View style={styles.warningContainer}>
            <Ionicons name="warning" size={24} color="#FF9800" />
            <Text style={styles.warningTitle}>¡IMPORTANTE!</Text>
            <Text style={styles.warningText}>
              • Se enviará un email con un enlace de confirmación
            </Text>
            <Text style={styles.warningText}>
              • Debes hacer click en el enlace para activar la nueva contraseña
            </Text>
            <Text style={styles.warningText}>
              • El enlace expira en 24 horas
            </Text>
          </View>

          <View style={styles.infoContainer}>
            <Text style={styles.infoText}>
              📋 Requisitos de la nueva contraseña:
            </Text>
            <Text style={styles.infoText}>
              • Mínimo 6 caracteres
            </Text>
            <Text style={styles.infoText}>
              • Debe ser diferente a la actual
            </Text>
            <Text style={styles.infoText}>
              • Debe coincidir en ambos campos
            </Text>
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
  headerContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FF9800',
    marginTop: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 18,
    color: '#2196F3',
    marginTop: 5,
    fontWeight: '600',
  },
  description: {
    fontSize: 16,
    color: '#666',
    marginTop: 5,
    textAlign: 'center',
  },
  formContainer: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
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
  // 🆕 ESTILOS PARA CONTENEDOR DE BOTONES
  buttonContainer: {
    gap: 10,
  },
  resetButton: {
    backgroundColor: '#FF9800',
    borderRadius: 8,
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 10,
  },
  resetButtonDisabled: {
    backgroundColor: '#ccc',
  },
  resetButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  // 🆕 ESTILOS PARA BOTÓN CANCELAR
  cancelButton: {
    backgroundColor: '#fff',
    borderWidth: 2,
    borderColor: '#666',
    borderRadius: 8,
    height: 45,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cancelButtonText: {
    color: '#666',
    fontSize: 16,
    fontWeight: '600',
  },
  warningContainer: {
    marginTop: 20,
    padding: 15,
    backgroundColor: '#fff3e0',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#FF9800',
    alignItems: 'center',
  },
  warningTitle: {
    color: '#ef6c00',
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  warningText: {
    color: '#ef6c00',
    fontSize: 14,
    marginBottom: 5,
    textAlign: 'center',
  },
  infoContainer: {
    marginTop: 15,
    padding: 15,
    backgroundColor: '#e8f5e8',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
  },
  infoText: {
    color: '#2e7d32',
    fontSize: 14,
    marginBottom: 3,
  },
});

export default PasswordResetScreen;