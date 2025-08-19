# 🔐 Sistema de Autenticación Completo
### React Native + PHP + MySQL

> **Template/Boilerplate completo** para sistema de login robusto y seguro, compatible con Web, Android e iOS.

---

## ✨ Características Principales

🚀 **Sistema completo de autenticación** listo para usar en cualquier aplicación  
📱 **Compatibilidad multiplataforma** - Una sola base de código para Web, Android e iOS  
🔒 **Seguridad robusta** con tokens, hash de contraseñas y auditoría automática  
📧 **Reseteo por email** con tokens temporales seguros  
⚡ **UI/UX optimizada** con estilos profesionales y navegación fluida  

---

## 🎯 Funcionalidades Implementadas

### **Frontend (React Native/Web)**
- ✅ **Login con validación** de email y contraseñas
- ✅ **Reseteo de contraseñas** con tokens seguros por email
- ✅ **Manejo de sesiones** con tokens de 24 horas
- ✅ **Validación automática** de sesiones al iniciar
- ✅ **Logout con confirmación** en ambos botones
- ✅ **RefreshControl** para actualizar datos
- ✅ **Compatibilidad multiplataforma** (Web, Android, iOS)
- ✅ **Enter para login** rápido
- ✅ **UI/UX profesional** con estilos consistentes

### **Backend (PHP)**
- ✅ **API RESTful** bien estructurada
- ✅ **Autenticación segura** con tokens únicos
- ✅ **Sistema de reseteo** con tokens temporales
- ✅ **Manejo de sesiones** con expiración automática
- ✅ **Triggers de auditoría** para histórico automático
- ✅ **Limpieza automática** de sesiones expiradas
- ✅ **Logs detallados** para debugging

### **Base de Datos (MySQL)**
- ✅ **Estructura normalizada** con tablas de auditoría
- ✅ **Triggers automáticos** para sesiones
- ✅ **Índices optimizados** para rendimiento
- ✅ **Campos de auditoría** en todas las tablas

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología | Descripción |
|------------|------------|-------------|
| **Frontend** | React Native + Expo | Aplicación multiplataforma |
| **Backend** | PHP | API RESTful con endpoints seguros |
| **Base de Datos** | MySQL/MariaDB | Base de datos relacional con triggers |
| **Email** | PHPMailer + SMTP | Envío de emails para reseteo |
| **Almacenamiento** | localStorage/AsyncStorage | Persistencia de tokens |
| **Estilo** | StyleSheet nativo | Diseño profesional multiplataforma |

---

## 🚀 Componentes Incluidos

### **Pantallas Frontend**
- **LoginScreen** - Login con validación y Enter rápido
- **PasswordResetScreen** - Reseteo de contraseña por email
- **HomeScreen** - Dashboard con información de sesión

### **API Backend**
- **`/api/login.php`** - Autenticación de usuarios
- **`/api/logout.php`** - Cierre de sesión seguro
- **`/api/validate_session.php`** - Validación de tokens
- **`/api/reset_password.php`** - Solicitud de reseteo
- **`/api/confirm_reset.php`** - Confirmación de nueva contraseña

### **Base de Datos**
- **Tabla `usuarios`** - Información de usuarios
- **Tabla `sesiones`** - Manejo de tokens de sesión
- **Tabla `reseteo_clave`** - Tokens de reseteo temporal
- **Tablas `*_hist`** - Auditoría automática con triggers

---

## 📦 Estructura del Proyecto

```
atenciones/
├── frontend/                 # App React Native
│   ├── src/
│   │   ├── screens/         # Pantallas principales
│   │   │   ├── LoginScreen.js
│   │   │   ├── PasswordResetScreen.js
│   │   │   └── HomeScreen.js
│   │   └── services/        # Servicios de API
│   │       ├── ApiService.js
│   │       └── StorageService.js
│   ├── App.js              # Componente principal
│   └── package.json
├── backend/                # API PHP
│   ├── api/               # Endpoints
│   │   ├── login.php
│   │   ├── logout.php
│   │   ├── validate_session.php
│   │   ├── reset_password.php
│   │   └── confirm_reset.php
│   ├── config/           # Configuraciones
│   │   ├── database.php
│   │   ├── auth.php
│   │   └── cors.php
│   └── PHPMailer/       # Librería de email
├── bd.sql              # Script de base de datos inicial
├── bdUltimo.sql       # Script con triggers y datos
└── README.md
```

---

## ⚡ Instalación Rápida

### **1. Clonar el repositorio**
```bash
git clone https://github.com/polielb/login-react-native-expo.git
cd login-react-native-expo
```

### **2. Configurar Backend**
```bash
# Importar base de datos
mysql -u root -p < bdUltimo.sql

# Configurar variables de entorno
cp backend/.env.example backend/.env
# Editar backend/.env con tus datos
```

### **3. Configurar Frontend**
```bash
cd front
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con la URL de tu API
```

### **4. Ejecutar**
```bash
# Backend: Configurar en servidor web (Apache/Nginx)
# Frontend:
npm start
# Elegir: w (web), a (Android), i (iOS)
```

---

## 🔧 Configuración

### **Variables de Entorno Backend** (`backend/.env`)
```env
DB_HOST=localhost
DB_NAME=atencionesfsa
DB_USER=tu_usuario
DB_PASS=tu_password

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_PASS=tu_app_password
```

### **Variables de Entorno Frontend** (`front/.env`)
```env
REACT_NATIVE_API_URL=http://tu-servidor.com/backend
```

---

## 🎨 Capturas de Pantalla

*Próximamente: Screenshots del sistema funcionando en Web, Android e iOS*

---

## 🔒 Características de Seguridad

- 🛡️ **Hash de contraseñas** con PHP `password_hash()`
- 🔑 **Tokens únicos** de 64 caracteres para sesiones
- ⏰ **Expiración automática** de tokens (24 horas)
- 🧹 **Limpieza automática** de sesiones expiradas
- 📝 **Auditoría completa** con triggers de base de datos
- 🔐 **Validación de email** con regex
- 🚫 **Protección CORS** configurada

---

## 🚀 Uso Como Template

Este proyecto está diseñado para ser usado como **base/template** para cualquier aplicación que necesite autenticación. 

### **Para usar en tu proyecto:**
1. Clona este repositorio
2. Personaliza los estilos y colores
3. Añade tus pantallas específicas
4. Modifica la base de datos según tus necesidades
5. ¡Listo para producción!

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## ⭐ ¡Dale una estrella!

Si este template te fue útil, ¡no olvides darle una ⭐ en GitHub!

---

## 📞 Soporte

¿Problemas o preguntas? Abre un [Issue](https://github.com/polielb/login-react-native-expo/issues) en GitHub.

---

**Desarrollado con ❤️ para la comunidad de desarrolladores**