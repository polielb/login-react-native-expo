// ================================================================================
// App.js - SOLO AGREGAR CONFIRMACIÓN AL BOTÓN DEL HEADER
// ================================================================================
import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { View, ActivityIndicator, StyleSheet, TouchableOpacity, Text } from 'react-native';

import LoginScreen from './src/screens/LoginScreen';
import PasswordResetScreen from './src/screens/PasswordResetScreen';
import HomeScreen from './src/screens/HomeScreen';
import ApiService from './src/services/ApiService';

const Stack = createNativeStackNavigator();

export default function App() {
  const [isLoading, setIsLoading] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [user, setUser] = useState(null);

  // Verificar sesión al iniciar la app
  useEffect(() => {
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      console.log('🔍 Verificando estado de autenticación...');
      const sessionResult = await ApiService.validateSession();
      
      console.log('📊 Resultado de validación:', sessionResult);
      
      if (sessionResult.valid) {
        console.log('✅ Sesión válida, usuario autenticado');
        setIsLoggedIn(true);
        setUser(sessionResult.user);
      } else {
        console.log('❌ Sesión inválida, redirigiendo a login');
        setIsLoggedIn(false);
        setUser(null);
      }
    } catch (error) {
      console.log('❌ Error checking auth state:', error);
      setIsLoggedIn(false);
      setUser(null);
    } finally {
      setIsLoading(false);
    }
  };

  const handleLogin = (userData) => {
    console.log('🎉 Usuario logueado:', userData);
    setIsLoggedIn(true);
    setUser(userData);
  };

  const handleLogout = async () => {
    try {
      console.log('🚪 Cerrando sesión...');
      await ApiService.logout();
    } catch (error) {
      console.log('❌ Error during logout:', error);
    } finally {
      setIsLoggedIn(false);
      setUser(null);
    }
  };

  // 🔧 NUEVA FUNCIÓN: Solo para el botón del header con confirmación
  const handleHeaderLogout = () => {
    const confirmed = window.confirm('¿Estás seguro de que quieres cerrar sesión?');
    if (confirmed) {
      handleLogout();
    }
  };

  // Pantalla de carga mientras verifica la sesión
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2196F3" />
        <Text style={styles.loadingText}>Verificando sesión...</Text>
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator>
        {isLoggedIn ? (
          // Usuario autenticado - mostrar pantallas principales
          <Stack.Screen 
            name="Home" 
            options={{ 
              title: 'Inicio',
              headerRight: () => (
                <TouchableOpacity 
                  onPress={handleHeaderLogout}  // 🔧 CAMBIO: Era handleLogout
                  style={styles.logoutHeaderButton}
                >
                  <Text style={styles.logoutHeaderText}>Cerrar Sesión</Text>
                </TouchableOpacity>
              )
            }}
          >
            {(props) => (
              <HomeScreen 
                {...props} 
                user={user} 
                onLogout={handleLogout}  // 🔧 ESTE SIGUE IGUAL
              />
            )}
          </Stack.Screen>
        ) : (
          // Usuario no autenticado - mostrar pantallas de login
          <>
            <Stack.Screen 
              name="Login" 
              options={{ title: 'Iniciar sesión' }}
            >
              {(props) => (
                <LoginScreen 
                  {...props} 
                  onLogin={handleLogin}
                />
              )}
            </Stack.Screen>
            <Stack.Screen 
              name="PasswordReset" 
              component={PasswordResetScreen} 
              options={{ title: 'Resetear clave' }} 
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  logoutHeaderButton: {
    marginRight: 10,
    paddingHorizontal: 12,
    paddingVertical: 6,
    backgroundColor: '#FF5722',
    borderRadius: 5,
  },
  logoutHeaderText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
});