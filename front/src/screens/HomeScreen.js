// ================================================================================
// ARCHIVO: front/src/screens/HomeScreen.js - SIN BOTONES DEBUG
// ================================================================================

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ScrollView,
  RefreshControl,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import ApiService from '../services/ApiService';

const HomeScreen = ({ user, onLogout }) => {
  const [refreshing, setRefreshing] = useState(false);
  const [sessionInfo, setSessionInfo] = useState(null);

  useEffect(() => {
    loadSessionInfo();
  }, []);

  const loadSessionInfo = async () => {
    try {
      const result = await ApiService.validateSession();
      if (result.valid) {
        setSessionInfo(result.session);
      }
    } catch (error) {
      console.log('Error loading session info:', error);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadSessionInfo();
    setRefreshing(false);
  };

  // 🔧 FUNCIÓN DE LOGOUT CORREGIDA - COMPATIBLE CON WEB
  const handleLogout = () => {
    console.log('🚪 Botón logout presionado');
    console.log('📝 onLogout function:', typeof onLogout);
    
    if (!onLogout) {
      console.error('❌ onLogout no está definido');
      Alert.alert('Error', 'Función de logout no disponible');
      return;
    }

    // Para web, usar confirm() nativo que funciona mejor
    if (Platform.OS === 'web') {
      const confirmed = window.confirm('¿Estás seguro de que quieres cerrar sesión?');
      if (confirmed) {
        console.log('✅ Confirmado logout (web)');
        onLogout();
      } else {
        console.log('🚫 Logout cancelado (web)');
      }
    } else {
      // Para móvil, usar Alert normal
      Alert.alert(
        'Cerrar Sesión',
        '¿Estás seguro de que quieres cerrar sesión?',
        [
          {
            text: 'Cancelar',
            style: 'cancel',
            onPress: () => console.log('🚫 Logout cancelado (móvil)')
          },
          {
            text: 'Cerrar Sesión',
            style: 'destructive',
            onPress: () => {
              console.log('✅ Confirmado logout (móvil)');
              onLogout();
            },
          },
        ],
        { cancelable: true }
      );
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'No disponible';
    const date = new Date(dateString);
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <ScrollView 
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
      }
    >
      {/* Header con estilo original azul */}
      <View style={styles.header}>
        <View style={styles.welcomeContainer}>
          <Ionicons name="person-circle" size={60} color="#fff" />
          <Text style={styles.welcomeText}>¡Bienvenido!</Text>
          <Text style={styles.userName}>
            {user?.nombres} {user?.apellidos}
          </Text>
          <Text style={styles.userEmail}>{user?.correo}</Text>
          <Text style={styles.userInfo}>Usuario: {user?.usuario}</Text>
        </View>
      </View>

      <View style={styles.content}>
        {/* Mensaje de éxito con estilo original */}
        <Text style={styles.sectionTitle}>🎉 ¡Login Exitoso!</Text>
        
        <View style={styles.successContainer}>
          <Ionicons name="checkmark-circle" size={50} color="#4CAF50" />
          <Text style={styles.successTitle}>Sistema Funcionando Correctamente</Text>
          <Text style={styles.successText}>
            Has completado exitosamente el proceso de autenticación.
          </Text>
        </View>

        {/* Grid de menú con estilo original */}
        <View style={styles.menuGrid}>
          <TouchableOpacity style={styles.menuItem}>
            <Ionicons name="calendar" size={40} color="#4CAF50" />
            <Text style={styles.menuItemText}>Citas</Text>
            <Text style={styles.menuItemSubText}>Próximamente</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.menuItem}>
            <Ionicons name="people" size={40} color="#FF9800" />
            <Text style={styles.menuItemText}>Pacientes</Text>
            <Text style={styles.menuItemSubText}>Próximamente</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.menuItem}>
            <Ionicons name="document-text" size={40} color="#9C27B0" />
            <Text style={styles.menuItemText}>Reportes</Text>
            <Text style={styles.menuItemSubText}>Próximamente</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.menuItem}>
            <Ionicons name="settings" size={40} color="#607D8B" />
            <Text style={styles.menuItemText}>Configuración</Text>
            <Text style={styles.menuItemSubText}>Próximamente</Text>
          </TouchableOpacity>
        </View>

        {/* Información de sesión con estilo original */}
        {sessionInfo && (
          <View style={styles.sessionInfoContainer}>
            <Text style={styles.sectionTitle}>📱 Información de Sesión Activa</Text>
            
            <View style={styles.infoBox}>
              <Text style={styles.infoTitle}>⏰ Detalles de la Sesión:</Text>
              <Text style={styles.infoText}>
                ✅ Iniciada: {formatDate(sessionInfo.fecha_creacion)}
              </Text>
              <Text style={styles.infoText}>
                ⏳ Expira: {formatDate(sessionInfo.fecha_expiracion)}
              </Text>
              <Text style={styles.infoText}>
                📱 Dispositivo: {sessionInfo.dispositivo}
              </Text>
              <Text style={styles.infoText}>
                🔑 Token: {sessionInfo.token?.substring(0, 8)}...
              </Text>
            </View>
          </View>
        )}

        {/* Información del sistema con estilo original */}
        <View style={styles.statsContainer}>
          <Text style={styles.sectionTitle}>Información del Sistema</Text>
          
          <View style={styles.infoBox}>
            <Text style={styles.infoTitle}>✅ Componentes Funcionando:</Text>
            <Text style={styles.infoText}>✅ Autenticación de usuarios</Text>
            <Text style={styles.infoText}>✅ Reseteo de contraseñas</Text>
            <Text style={styles.infoText}>✅ Sistema de tokens</Text>
            <Text style={styles.infoText}>✅ Envío de emails</Text>
            <Text style={styles.infoText}>✅ Navegación entre pantallas</Text>
            <Text style={styles.infoText}>✅ Manejo de sesiones</Text>
            <Text style={styles.infoText}>✅ Validación automática</Text>
          </View>

          <View style={styles.testInfo}>
            <Text style={styles.testTitle}>🧪 Datos de Testing:</Text>
            <Text style={styles.testText}>ID: {user?.id}</Text>
            <Text style={styles.testText}>Usuario: {user?.usuario}</Text>
            <Text style={styles.testText}>Email: {user?.correo}</Text>
            <Text style={styles.testText}>Nombre: {user?.nombres} {user?.apellidos}</Text>
            <Text style={styles.testText}>Plataforma: {Platform.OS}</Text>
          </View>
        </View>
      </View>

      {/* 🔧 BOTÓN DE LOGOUT CORREGIDO */}
      <TouchableOpacity 
        style={styles.logoutButton} 
        onPress={handleLogout}
        activeOpacity={0.8}
      >
        <Ionicons name="log-out" size={20} color="#fff" />
        <Text style={styles.logoutButtonText}>Cerrar Sesión</Text>
      </TouchableOpacity>

      {/* 🔧 BOTONES DEBUG REMOVIDOS - Ya no aparecen */}
    </ScrollView>
  );
};

// Estilos originales adaptados para todas las plataformas
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  // Header azul original
  header: {
    backgroundColor: '#2196F3',
    paddingVertical: 30,
    paddingHorizontal: 20,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  welcomeContainer: {
    alignItems: 'center',
  },
  welcomeText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 10,
  },
  userName: {
    fontSize: 18,
    color: '#fff',
    marginTop: 5,
  },
  userEmail: {
    fontSize: 14,
    color: '#E3F2FD',
    marginTop: 5,
  },
  userInfo: {
    fontSize: 12,
    color: '#BBDEFB',
    marginTop: 3,
    fontStyle: 'italic',
  },
  // Content
  content: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
    textAlign: 'center',
  },
  // Container de éxito verde original
  successContainer: {
    backgroundColor: '#e8f5e8',
    borderRadius: 10,
    padding: 20,
    alignItems: 'center',
    marginBottom: 20,
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
  },
  successTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginTop: 10,
    textAlign: 'center',
  },
  successText: {
    fontSize: 14,
    color: '#2e7d32',
    marginTop: 5,
    textAlign: 'center',
  },
  // Grid de menú original
  menuGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 30,
  },
  menuItem: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
    alignItems: 'center',
    width: '47%',
    marginBottom: 15,
    // Sombras compatibles con todas las plataformas
    ...(Platform.OS === 'web' ? {
      boxShadow: '0px 2px 3.84px rgba(0, 0, 0, 0.1)',
    } : {
      shadowColor: '#000',
      shadowOffset: {
        width: 0,
        height: 2,
      },
      shadowOpacity: 0.1,
      shadowRadius: 3.84,
      elevation: 5,
    }),
  },
  menuItemText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginTop: 10,
  },
  menuItemSubText: {
    fontSize: 12,
    color: '#999',
    marginTop: 5,
    fontStyle: 'italic',
  },
  // Contenedor de información de sesión
  sessionInfoContainer: {
    marginBottom: 20,
  },
  // Contenedor de estadísticas
  statsContainer: {
    marginTop: 20,
  },
  // Caja de información verde original
  infoBox: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
    marginBottom: 15,
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
    // Sombras compatibles
    ...(Platform.OS === 'web' ? {
      boxShadow: '0px 2px 3.84px rgba(0, 0, 0, 0.1)',
    } : {
      shadowColor: '#000',
      shadowOffset: {
        width: 0,
        height: 2,
      },
      shadowOpacity: 0.1,
      shadowRadius: 3.84,
      elevation: 5,
    }),
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginBottom: 10,
  },
  infoText: {
    fontSize: 14,
    color: '#2e7d32',
    marginBottom: 5,
  },
  // Información de testing púrpura original
  testInfo: {
    backgroundColor: '#f3e5f5',
    borderRadius: 10,
    padding: 20,
    borderLeftWidth: 4,
    borderLeftColor: '#9C27B0',
    // Sombras compatibles
    ...(Platform.OS === 'web' ? {
      boxShadow: '0px 2px 3.84px rgba(0, 0, 0, 0.1)',
    } : {
      shadowColor: '#000',
      shadowOffset: {
        width: 0,
        height: 2,
      },
      shadowOpacity: 0.1,
      shadowRadius: 3.84,
      elevation: 5,
    }),
  },
  testTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#7B1FA2',
    marginBottom: 10,
  },
  testText: {
    fontSize: 14,
    color: '#7B1FA2',
    marginBottom: 5,
  },
  // 🔧 BOTÓN DE LOGOUT CORREGIDO
  logoutButton: {
    backgroundColor: '#f44336',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    margin: 20,
    borderRadius: 10,
    // Asegurar que es presionable
    minHeight: 50,
  },
  logoutButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    marginLeft: 10,
  },
});

export default HomeScreen;