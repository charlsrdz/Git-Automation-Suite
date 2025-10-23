# Git Automation Suite 🚀

Una suite de herramientas de automatización Git diseñada para mejorar la productividad en el manejo de múltiples repositorios y flujos de trabajo.

## ✨ Características Principales

### 🔄 Git Push Automation (gitp)
Automatización inteligente de commits y push con análisis automático de cambios.

**Comandos disponibles:**
gitp <rama> <proyecto> [OPCIONES]

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
gitp qa commons -d fix
gitp main app -d feat -m "Nueva feature de usuario"
gitp develop api -d fix -b staging

### 🛠️ Git Automation (gita)
Comandos Git esenciales con interfaz unificada y manejo de errores mejorado.

**Comandos disponibles:**
gita <rama> <proyecto> [COMANDO] [ARGUMENTO]

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
gita main app status
gita develop api log
gita qa commons checkout-b nueva-feature

### 📁 Git List Projects (gitlp)
Explorador de proyectos y ramas disponibles.

**Uso:**
gitlp          # Listar todas las ramas
gitlp main     # Proyectos en rama main
gitlp develop  # Proyectos en rama develop

## 🚀 Instalación

### Prerrequisitos
- Bash 4.0+
- Git 2.20+
- Variable de entorno GIT_BASE_PATH configurada

### Configuración

1. **Clona el repositorio:**
git clone https://github.com/tu-usuario/git-automation-suite.git
cd git-automation-suite

2. **Configura la variable de entorno:**
echo 'export GIT_BASE_PATH="$HOME/projects"' >> ~/.bashrc

3. **Instala los aliases:**
echo "source $(pwd)/git-automation.sh" >> ~/.bashrc

4. **Recarga la configuración:**
source ~/.bashrc

### Estructura de Directorios
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

## 📖 Uso Avanzado

### Flujo de Trabajo Típico

1. **Explorar proyectos disponibles:**
gitlp
gitlp main

2. **Trabajar en un proyecto:**
gita main app status
gita main app pull

3. **Hacer commit y push:**
gitp main app -d feat -m "Nueva funcionalidad"
gitp develop api -d fix -b staging

### Configuración Personalizada

Puedes personalizar el comportamiento editando las variables en el script:
# En git-automation.sh
export GIT_BASE_PATH="$HOME/my-projects"
export DEFAULT_COMMIT_TYPE="feat"
export AUTO_PUSH_ENABLED=true

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