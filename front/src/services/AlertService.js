// ================================================================================
// src/services/AlertService.js - SERVICIO DE ALERTAS MULTIPLATAFORMA
// ================================================================================
import { Alert, Platform } from 'react-native';

class AlertService {
  static show(title, message, buttons = [{ text: 'OK' }], options = {}) {
    if (Platform.OS === 'web') {
      // Para web, usar window.alert o confirm
      if (buttons.length === 1) {
        // Solo un botón - usar alert simple
        window.alert(`${title}\n\n${message}`);
        if (buttons[0].onPress) {
          buttons[0].onPress();
        }
      } else {
        // Múltiples botones - usar confirm
        const result = window.confirm(`${title}\n\n${message}`);
        if (result && buttons[0]?.onPress) {
          buttons[0].onPress();
        } else if (!result && buttons[1]?.onPress) {
          buttons[1].onPress();
        }
      }
    } else {
      // Para iOS y Android - usar Alert.alert normal
      Alert.alert(title, message, buttons, options);
    }
  }

  static showError(message, onPress = null) {
    this.show('Error', message, [{ 
      text: 'OK', 
      onPress: onPress 
    }]);
  }

  static showSuccess(message, onPress = null) {
    this.show('Éxito', message, [{ 
      text: 'OK', 
      onPress: onPress 
    }]);
  }

  static showConfirm(title, message, onConfirm, onCancel = null) {
    this.show(title, message, [
      { 
        text: 'Cancelar', 
        style: 'cancel',
        onPress: onCancel 
      },
      { 
        text: 'Confirmar', 
        onPress: onConfirm 
      }
    ]);
  }
}

export default AlertService;