# Git Automation Suite 🚀

Una suite de herramientas de automatización Git diseñada para mejorar la productividad en el manejo de múltiples repositorios y flujos de trabajo.

## ✨ Características Principales

### 🔄 Git Push Automation (gitp)
Automatización inteligente de commits y push con análisis automático de cambios.

**Comandos disponibles:**
```bash
gitp <rama> <proyecto> [OPCIONES]
```

**Opciones:**
- -d, --diff [TIPO] - Commit automático con tipo específico
- -m, --message "TEXTO" - Mensaje personalizado para el commit
- -b, --branch [RAMA] - Push a rama alternativa

**Tipos de commit:**
- 🔧 fix - Corrección de errores
- 🚀 feat - Nueva funcionalidad
- 🚨 hotfix - Corrección urgente
- 📖 docs - Documentación
- 🔄 refactor - Reestructuración de código

**Ejemplos:**
```bash
gitp qa commons -d fix
gitp main app -d feat -m "Nueva feature de usuario"
gitp develop api -d fix -b staging
```

## Ejemplo 1: Commit de Corrección (fix)
```bash
🔧 Correcciones (1 archivo, +15/-3 líneas)

Archivos modificados:
- src/auth.js (+12/-2)
- config/database.js (+3/-1)
```

## Ejemplo 2: Commit de Nueva Funcionalidad (feat)
```bash
🚀 Nueva funcionalidad (3 archivos modificados)

Archivos modificados:
- components/UserProfile.js (+45/-8)
- styles/user.css (+23/-2)
- utils/helpers.js (+12/-1)
``` 

## Ejemplo 3: Commit de Documentación (docs)
```bash
📖 Documentación (2 archivos, +28/-0 líneas)

Archivos modificados:
- README.md (+20/-0)
- docs/api.md (+8/-0)
```

## Ejemplo 4: Commit de Reestructuración (refactor)
```bash
🔄 Reestructuración (1 archivo, +67/-34 líneas)

Archivos modificados:
- services/apiService.js (+67/-34)
```

## Ejemplo 5: Commit de Corrección Urgente (hotfix)
```bash
🚨 Corrección urgente (2 archivos, +8/-4 líneas) - Parche de seguridad crítico

Archivos modificados:
- middleware/security.js (+5/-2)
- config/env.js (+3/-2)
```

## Ejemplo 6: Commit con Descripción Personalizada
```bash
🔧 Correcciones (4 archivos modificados) - Mejoras en validación de formularios

Archivos modificados:
- components/FormValidator.js (+25/-10)
- utils/validation.js (+18/-5)
- tests/validation.test.js (+30/-2)
- styles/forms.css (+8/-1)
```

## Ejemplo 7: Commit de Actualización General
```bash
📦 Actualización (5 archivos modificados)

Archivos modificados:
- package.json (+3/-1)
- package-lock.json (+15/-0)
- src/index.js (+2/-0)
- config/app.js (+5/-2)
- README.md (+3/-1)
```

## Ejemplo 8: Commit con Múltiples Archivos
```bash
🚀 Nueva funcionalidad (8 archivos modificados) - Sistema de notificaciones push

Archivos modificados:
- components/Notifications.js (+89/-12)
- services/notificationService.js (+45/-8)
- hooks/useNotifications.js (+32/-3)
- styles/notifications.css (+28/-2)
- utils/constants.js (+15/-0)
- tests/notifications.test.js (+67/-5)
- docs/notifications.md (+23/-0)
- config/push.js (+18/-4)
```
---

### 🛠️ Git Automation (gita)
Comandos Git esenciales con interfaz unificada y manejo de errores mejorado.

**Comandos disponibles:**
```bash
gita <rama> <proyecto> [COMANDO] [ARGUMENTO]
```

**Comandos soportados:**
- status - Estado del repositorio
- log - Historial de commits
- pull - Descargar cambios
- pull-origin - Descargar desde origen específico
- checkout - Cambiar rama o restaurar archivo
- checkout-b - Crear nueva rama
- branch - Listar ramas
- fetch - Obtener cambios remotos

**Ejemplos:**
```bash
gita main app status
gita develop api log
gita qa commons checkout-b nueva-feature
```

### 📁 Git List Projects (gitlp)
Explorador de proyectos y ramas disponibles.

**Uso:**
```bash
gitlp          # Listar todas las ramas
gitlp main     # Proyectos en rama main
gitlp develop  # Proyectos en rama develop
```

## 🚀 Instalación

### Prerrequisitos
- Bash 4.0+
- Git 2.20+
- Variable de entorno GIT_BASE_PATH configurada

### Configuración

1. **Clona el repositorio:**
```bash
git clone https://github.com/tu-usuario/git-automation-suite.git
cd git-automation-suite
```

2. **Configura la variable de entorno:**
```bash
echo 'export GIT_BASE_PATH="$HOME/projects"' >> ~/.bashrc
```

3. **Instala los aliases:**
```bash
echo "source $(pwd)/git-automation.sh" >> ~/.bashrc
``` 

4. **Recarga la configuración:**
```bash
source ~/.bashrc
```

### Estructura de Directorios
```bash
$GIT_BASE_PATH/
├── main/
│   ├── app/
│   ├── web/
│   └── api/
├── develop/
│   ├── app/
│   └── web/
└── qa/
    ├── app/
    └── commons/
``` 
## 📖 Uso Avanzado

### Flujo de Trabajo Típico

1. **Explorar proyectos disponibles:**
```bash
gitlp
gitlp main
``` 

2. **Trabajar en un proyecto:**
```bash
gita main app status
gita main app pull
```

3. **Hacer commit y push:**
```bash
gitp main app -d feat -m "Nueva funcionalidad"
gitp develop api -d fix -b staging
``` 

### Configuración Personalizada

Puedes personalizar el comportamiento editando las variables en el script:
# En git-automation.sh
```bash
export GIT_BASE_PATH="$HOME/my-projects"
export DEFAULT_COMMIT_TYPE="feat"
export AUTO_PUSH_ENABLED=true
``` 

## 🛠️ Características Técnicas

### Manejo de Errores Inteligente
- ✅ Detección automática de conflictos
- ✅ Recomendaciones específicas para cada error
- ✅ Clasificación por gravedad (crítico, advertencia, info)
- ✅ Mantiene terminal abierta en errores críticos

### Análisis Automático de Cambios
- 📊 Estadísticas de archivos modificados
- 🔍 Detección de tipo de cambios
- 📝 Generación inteligente de mensajes de commit
- 🎨 Formato consistente con emojis

### Interfaz de Usuario Mejorada
- 🎯 Output formateado y colorizado
- 📋 Información contextual relevante
- ⏸️ Control de flujo con confirmaciones
- 🔄 Progreso visual de operaciones

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (git checkout -b feature/AmazingFeature)
3. Commit tus cambios (git commit -m 'Add some AmazingFeature')
4. Push a la rama (git push origin feature/AmazingFeature)
5. Abre un Pull Request

## 📝 Roadmap

- [ ] Integración con CI/CD
- [ ] Sistema de plugins
- [ ] Dashboard de métricas
- [ ] Modo interactivo (TUI)
- [ ] Soporte para múltiples remotos
- [ ] Plantillas de commit personalizables

## 🐛 Solución de Problemas

### Problemas Comunes

**Error: "Directorio no encontrado"**
- Verifica que GIT_BASE_PATH esté configurado correctamente
- Confirma que la estructura de directorios coincida

**Error: "No es un repositorio Git"**
- Asegúrate de que el directorio contenga un repositorio Git inicializado

**Comando no encontrado**
- Verifica que el script esté correctamente sourceado en tu shell

### Logs y Debug
Para modo verbose, agrega antes de ejecutar:
export GIT_AUTOMATION_DEBUG=true

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver LICENSE para más información.

## 👨‍💻 Autor

Creado con ❤️ para la comunidad de desarrolladores.

---

**¿Preguntas o sugerencias?** ¡Abre un issue o contribuye al proyecto!