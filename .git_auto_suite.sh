# Función de Automatización Git para ZSH con Oh My ZSH
# Ruta base para todos los proyectos
GIT_BASE_PATH="$HOME/Git"

git_push_automation() {
    # Configuración inicial
    local rama="" proyecto="" mensaje_commit="" change_description=""
    local use_diff=false rama_alternativa="" critical_error=0
    local ruta_proyecto="" commit_icon="📦" diff_type="update"
    
    # Función de ayuda mejorada
    show_help() {
        echo "🚀 Git Push Automation - Ayuda"
        echo "=========================================="
        echo "Uso: gitp <rama> <proyecto> [OPCIONES]"
        echo ""
        echo "Parámetros obligatorios:"
        echo "  <rama>      - Rama de trabajo (ej: main, develop)"
        echo "  <proyecto>  - Nombre del proyecto"
        echo ""
        echo "Opciones disponibles:"
        echo "  -d, --diff [TIPO]    - Commit automático con tipo específico"
        echo "  -m, --message \"TEXTO\" - Mensaje personalizado para el commit"
        echo "  -b, --branch [RAMA]  - Push a rama alternativa"
        echo ""
        echo "Tipos de commit para --diff:"
        echo "  🔧 fix      - Corrección de errores"
        echo "  🚀 feat     - Nueva funcionalidad"  
        echo "  🚨 hotfix   - Corrección urgente"
        echo "  📖 docs     - Documentación"
        echo "  🔄 refactor - Reestructuración de código"
        echo ""
        echo "Ejemplos:"
        echo "  gitp qa commons -d fix"
        echo "  gitp main app -d feat -m \"Nueva feature de usuario\""
        echo "  gitp develop api -d fix -b staging"
        echo "  gitp main web -m \"Commit personalizado\" -b production"
    }

    # Función de manejo de errores mejorada
    handle_error() {
        local message="$1" level="$2" recommendation="$3"
        
        case "$level" in
            "critical")
                echo "❌ ERROR CRÍTICO: $message"
                [[ -n "$recommendation" ]] && echo "💡 Recomendación: $recommendation"
                critical_error=1
                return 1
                ;;
            "warning")
                echo "⚠️  ADVERTENCIA: $message"
                [[ -n "$recommendation" ]] && echo "💡 Sugerencia: $recommendation"
                return 0
                ;;
            "info")
                echo "ℹ️  INFORMACIÓN: $message"
                return 0
                ;;
            *)
                echo "❌ Error: $message"
                return 1
                ;;
        esac
    }

    # Validación básica de parámetros
    if [[ $# -lt 2 ]]; then
        show_help
        return 1
    fi

    # Asignar parámetros obligatorios
    rama="$1"
    proyecto="$2"
    shift 2  # Remover los primeros dos parámetros

    # Procesar opciones
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--diff)
                use_diff=true
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    diff_type="$2"
                    shift
                fi
                ;;
            -m|--message)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    change_description="$2"
                    shift
                else
                    handle_error "Falta el mensaje para -m/--message" "critical" "Usa: -m \"Tu mensaje aquí\""
                    return 1
                fi
                ;;
            -b|--branch)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    rama_alternativa="$2"
                    shift
                else
                    handle_error "Falta la rama para -b/--branch" "critical" "Usa: -b nombre_rama"
                    return 1
                fi
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            *)
                # Si no es una opción, asumir que es mensaje libre
                if [[ -z "$mensaje_commit" ]]; then
                    mensaje_commit="$1"
                fi
                ;;
        esac
        shift
    done

    # Validar parámetros obligatorios
    if [[ -z "$rama" || -z "$proyecto" ]]; then
        handle_error "Faltan parámetros obligatorios" "critical" "Consulta gitp --help para ayuda"
        return 1
    fi

    ruta_proyecto="${GIT_BASE_PATH}/${rama}/${proyecto}"

    echo "🚀 INICIANDO DESPLIEGUE"
    echo "========================"
    echo "📋 Proyecto: $proyecto"
    echo "🌿 Rama: $rama"
    [[ -n "$rama_alternativa" ]] && echo "🎯 Push a: $rama_alternativa"
    echo "📁 Ruta: $ruta_proyecto"
    echo ""

    # Verificar existencia del proyecto
    if [[ ! -d "$ruta_proyecto" ]]; then
        handle_error "Directorio no encontrado" "critical" \
            "Verifica: \n- La ruta base GIT_BASE_PATH ($GIT_BASE_PATH) \n- Que la rama '$rama' exista \n- Que el proyecto '$proyecto' esté correcto"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Navegar al proyecto
    cd "$ruta_proyecto" || {
        handle_error "No se pudo acceder al directorio" "critical" "Verifica los permisos del directorio"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    }

    # Verificar que es repo git
    if [[ ! -d ".git" ]]; then
        handle_error "No es un repositorio Git" "critical" "Inicializa con: git init"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Push final
    echo "📤 Subiendo cambios..."
    local push_target="${rama_alternativa:-$rama}"

    # Asegurar rama correcta
    if [[ -n "$rama_alternativa" ]]; then
        echo "🎯 Destino: rama '$push_target'"
    else
        echo "🔍 Verificando rama..."
        if ! git checkout "$rama" 2>/dev/null; then
            handle_error "No se pudo cambiar a la rama '$rama'" "critical" \
                "Opciones: \n- Verifica que la rama exista: git branch -a \n- Crea la rama: git checkout -b $rama"
            read -r "?⏸️  Presiona cualquier tecla para continuar..."
            return 1
        fi
    fi
    

    # Sincronizar cambios
    echo "📥 Sincronizando cambios remotos..."
    if ! git pull origin "$rama"; then
        handle_error "Conflicto al sincronizar cambios" "critical" \
            "Resuelve manualmente: \n- Revisa los conflictos: git status \n- Resuelve y haz commit: git add . && git commit -m 'Resuelve conflictos'"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Preparar cambios
    echo "📦 Preparando cambios..."
    if ! git add .; then
        handle_error "Error al agregar cambios" "critical" "Verifica el estado con: git status"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Función para obtener icono según tipo
    get_commit_icon() {
        case "$1" in
            "fix")      echo "🔧" ;;
            "feat")     echo "🚀" ;;
            "hotfix")   echo "🚨" ;;
            "docs")     echo "📖" ;;
            "refactor") echo "🔄" ;;
            *)          echo "📦" ;;
        esac
    }

    # Generar mensaje de commit
    if [[ "$use_diff" == "true" ]]; then
        commit_icon=$(get_commit_icon "$diff_type")
        local changed_files=$(git diff --staged --name-only)
        local file_count=$(echo "$changed_files" | wc -l | tr -d ' ')
        
        if [[ -n "$changed_files" ]]; then
            # Analizar cambios
            local change_summary=""
            if [[ $file_count -eq 1 ]]; then
                local main_file=$(echo "$changed_files" | head -1)
                local stats=$(git diff --staged --stat "$main_file" | tail -1)
                local additions=$(echo "$stats" | grep -o '[0-9]\+ insertion' | grep -o '[0-9]\+' || echo "0")
                local deletions=$(echo "$stats" | grep -o '[0-9]\+ deletion' | grep -o '[0-9]\+' || echo "0")
                change_summary="($file_count archivo, +$additions/-$deletions líneas)"
            else
                change_summary="($file_count archivos modificados)"
            fi

            # Construir mensaje
            case "$diff_type" in
                "fix")       mensaje_commit="$commit_icon Correcciones $change_summary" ;;
                "feat")      mensaje_commit="$commit_icon Nueva funcionalidad $change_summary" ;;
                "hotfix")    mensaje_commit="$commit_icon Corrección urgente $change_summary" ;;
                "docs")      mensaje_commit="$commit_icon Documentación $change_summary" ;;
                "refactor")  mensaje_commit="$commit_icon Reestructuración $change_summary" ;;
                *)           mensaje_commit="$commit_icon Actualización $change_summary" ;;
            esac

            # Agregar descripción personalizada si existe
            [[ -n "$change_description" ]] && mensaje_commit+=" - $change_description"

            # Agregar lista de archivos
            mensaje_commit+=$'\n\nArchivos modificados:'
            while IFS= read -r file; do
                if [[ -f "$file" ]]; then
                    local file_stats=$(git diff --staged --stat "$file" | tail -1)
                    local additions=$(echo "$file_stats" | grep -o '[0-9]\+ insertion' | grep -o '[0-9]\+' || echo "0")
                    local deletions=$(echo "$file_stats" | grep -o '[0-9]\+ deletion' | grep -o '[0-9]\+' || echo "0")
                    mensaje_commit+=$'\n'"- $file (+$additions/-$deletions)"
                fi
            done <<< "$changed_files"
        else
            # Mensaje por defecto
            case "$diff_type" in
                "fix")       mensaje_commit="$commit_icon Correcciones generales" ;;
                "feat")      mensaje_commit="$commit_icon Nueva funcionalidad" ;;
                "hotfix")    mensaje_commit="$commit_icon Corrección urgente" ;;
                "docs")      mensaje_commit="$commit_icon Actualización documentación" ;;
                "refactor")  mensaje_commit="$commit_icon Reestructuración de código" ;;
                *)           mensaje_commit="$commit_icon Actualización de proyecto" ;;
            esac
            [[ -n "$change_description" ]] && mensaje_commit+=" - $change_description"
        fi
    elif [[ -z "$mensaje_commit" && -z "$change_description" ]]; then
        echo "💬 Ingrese el mensaje de commit:"
        read -r mensaje_commit
        if [[ -z "$mensaje_commit" ]]; then
            handle_error "El mensaje de commit no puede estar vacío" "critical"
            read -r "?⏸️  Presiona cualquier tecla para continuar..."
            return 1
        fi
    else
        [[ -n "$change_description" ]] && mensaje_commit="$change_description"
    fi

    # Crear commit
    echo "💾 Confirmando cambios..."
    echo "📝 Commit: $mensaje_commit"
    if ! git commit -m "$mensaje_commit"; then
        handle_error "Error al crear commit" "critical" "Verifica si hay cambios para commitear: git status"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Verificación final
    echo "🔍 Verificación final..."
    if ! git pull origin "$rama"; then
        handle_error "Conflicto detectado antes del push" "critical" "Resuelve los conflictos manualmente y reintenta"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi
    
    if git push origin "$push_target"; then
        echo ""
        echo "✅ ¡DESPLIEGUE EXITOSO!"
        echo "========================"
        echo "🌿 Rama: $push_target"
        echo "📦 Commit: ${mensaje_commit%%$'\n'*}"  # Solo primera línea
        echo "🕒 Hora: $(date +'%H:%M:%S')"
        echo ""
        echo "🎉 ¡Todo listo! Presiona cualquier tecla para cerrar..."
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        exit 0
    else
        handle_error "Error al subir cambios" "critical" \
            "Posibles causas: \n- Sin permisos de escritura \n- Rama protegida \n- Conflictos no resueltos"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi
}

# Función principal git con personalidad mejorada
git_automation() {
    # Configuración inicial
    local rama="" proyecto="" funcion_git="" argumento_adicional=""
    local critical_error=0 ruta_proyecto=""
    
    # Función de ayuda
    show_git_help() {
        echo "🛠️  Git Automation - Ayuda"
        echo "=========================================="
        echo "Uso: gita <rama> <proyecto> [COMANDO] [ARGUMENTO]"
        echo ""
        echo "Parámetros obligatorios:"
        echo "  <rama>      - Rama de trabajo"
        echo "  <proyecto>  - Nombre del proyecto"
        echo ""
        echo "Comandos disponibles:"
        echo "  status      - Estado del repositorio"
        echo "  log         - Historial de commits"
        echo "  pull        - Descargar cambios (origin)"
        echo "  pull-origin - Descargar desde origen específico"
        echo "  checkout    - Cambiar rama o restaurar archivo"
        echo "  checkout-b  - Crear nueva rama"
        echo "  branch      - Listar ramas"
        echo "  fetch       - Obtener cambios remotos"
        echo ""
        echo "Ejemplos:"
        echo "  gita main app status"
        echo "  gita develop api log"
        echo "  gita qa commons checkout-b nueva-feature"
        echo "  gita staging web checkout src/file.js"
    }

    # Función de manejo de errores consistente
    handle_error() {
        local message="$1" level="$2" recommendation="$3"
        
        case "$level" in
            "critical")
                echo "❌ ERROR CRÍTICO: $message"
                [[ -n "$recommendation" ]] && echo "💡 Recomendación: $recommendation"
                critical_error=1
                return 1
                ;;
            "warning")
                echo "⚠️  ADVERTENCIA: $message"
                [[ -n "$recommendation" ]] && echo "💡 Sugerencia: $recommendation"
                return 0
                ;;
            "info")
                echo "ℹ️  INFORMACIÓN: $message"
                return 0
                ;;
            *)
                echo "❌ Error: $message"
                return 1
                ;;
        esac
    }

    # Validación de parámetros
    if [[ $# -lt 2 ]]; then
        show_git_help
        return 1
    fi

    # Asignar parámetros obligatorios
    rama="$1"
    proyecto="$2"
    funcion_git="${3:-status}"  # Por defecto 'status'
    argumento_adicional="$4"
    
    ruta_proyecto="${GIT_BASE_PATH}/${rama}/${proyecto}"

    echo "🛠️  EJECUTANDO COMANDO GIT"
    echo "=========================="
    echo "📋 Proyecto: $proyecto"
    echo "🌿 Rama: $rama"
    echo "⚡ Comando: $funcion_git"
    [[ -n "$argumento_adicional" ]] && echo "📝 Argumento: $argumento_adicional"
    echo "📁 Ruta: $ruta_proyecto"
    echo ""

    # Verificar existencia del proyecto
    if [[ ! -d "$ruta_proyecto" ]]; then
        handle_error "Directorio no encontrado" "critical" \
            "Verifica: \n- Ruta base: $GIT_BASE_PATH \n- Rama: $rama \n- Proyecto: $proyecto"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Navegar al proyecto
    cd "$ruta_proyecto" || {
        handle_error "No se pudo acceder al directorio" "critical" "Verifica los permisos"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    }

    # Verificar que es repo git
    if [[ ! -d ".git" ]]; then
        handle_error "No es un repositorio Git" "critical" "Inicializa con: git init"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Ejecutar comando específico
    case "$funcion_git" in
        "status")
            echo "🔍 Consultando estado del repositorio..."
            git status || {
                handle_error "Error al consultar estado" "warning" "Verifica la integridad del repo"
            }
            ;;

        "log")
            echo "📜 Mostrando historial de commits..."
            git log || {
                handle_error "Error al mostrar log" "warning"
            }
            ;;

        "pull")
            echo "📥 Descargando cambios desde origin..."
            if git pull; then
                echo "✅ Cambios descargados exitosamente"
            else
                handle_error "Error al descargar cambios" "critical" \
                    "Resuelve conflictos manualmente: git status"
            fi
            ;;

        "pull-origin")
            echo "📥 Descargando desde origen específico..."
            if git pull origin "$rama"; then
                echo "✅ Cambios descargados desde origin/$rama"
            else
                handle_error "Error al descargar desde origin" "critical" \
                    "Verifica: \n- Que la rama $rama exista en remoto \n- Tu conexión a internet"
            fi
            ;;

        "checkout")
            if [[ -n "$argumento_adicional" ]]; then
                echo "📄 Restaurando archivo: $argumento_adicional"
                if git checkout "$rama" -- "$argumento_adicional"; then
                    echo "✅ Archivo restaurado: $argumento_adicional"
                else
                    handle_error "Error al restaurar archivo" "warning" \
                        "Verifica: \n- Que el archivo exista \n- La ruta sea correcta"
                fi
            else
                echo "🌿 Cambiando a rama: $rama"
                if git checkout "$rama"; then
                    echo "✅ Cambiado a rama: $rama"
                else
                    handle_error "Error al cambiar de rama" "critical" \
                        "Opciones: \n- Ver ramas: git branch -a \n- Crear rama: git checkout -b $rama"
                fi
            fi
            ;;

        "checkout-b")
            if [[ -n "$argumento_adicional" ]]; then
                echo "🌱 Creando nueva rama: $argumento_adicional"
                if git checkout -b "$argumento_adicional"; then
                    echo "✅ Nueva rama creada: $argumento_adicional"
                else
                    handle_error "Error al crear rama" "warning" \
                        "La rama ya podría existir. Verifica con: git branch -a"
                fi
            else
                handle_error "Falta nombre para nueva rama" "critical" \
                    "Usa: gita <rama> <proyecto> checkout-b nombre-nueva-rama"
            fi
            ;;

        "branch")
            echo "🌿 Listando ramas..."
            git branch -a || {
                handle_error "Error al listar ramas" "warning"
            }
            ;;

        "fetch")
            echo "📡 Obteniendo cambios remotos..."
            if git fetch --all; then
                echo "✅ Cambios remotos obtenidos"
            else
                handle_error "Error al obtener cambios remotos" "warning" \
                    "Verifica tu conexión y permisos"
            fi
            ;;

        *)
            handle_error "Comando no reconocido: $funcion_git" "critical" \
                "Comandos válidos: status, log, pull, pull-origin, checkout, checkout-b, branch, fetch"
            show_git_help
            ;;
    esac

    # Resultado final
    echo ""
    if [[ $critical_error -eq 0 ]]; then
        echo "✅ COMANDO EJECUTADO EXITOSAMENTE"
        echo "=================================="
        echo "🕒 Hora: $(date +'%H:%M:%S')"
        echo "🎯 Proyecto: $proyecto"
        echo "🌿 Rama: $rama"
        echo "⚡ Comando: $funcion_git"
    else
        echo "❌ OPERACIÓN CON ERRORES"
        echo "========================"
    fi

    read -r "?⏸️  Presiona cualquier tecla para continuar..."
    return $critical_error
}

# Función mejorada para listar proyectos
git_list_projects() {
    local rama="$1"
    
    # Función de ayuda
    show_list_help() {
        echo "📁 Git List Projects - Ayuda"
        echo "============================"
        echo "Uso: gitlp [rama]"
        echo ""
        echo "Sin parámetros: Lista todas las ramas disponibles"
        echo "Con rama: Lista proyectos en rama específica"
        echo ""
        echo "Ejemplos:"
        echo "  gitlp           # Listar todas las ramas"
        echo "  gitlp main      # Proyectos en rama main"
        echo "  gitlp develop   # Proyectos en rama develop"
    }

    # Validar directorio base
    if [[ ! -d "$GIT_BASE_PATH" ]]; then
        echo "❌ Directorio base no encontrado: $GIT_BASE_PATH"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    echo "📁 EXPLORADOR DE PROYECTOS"
    echo "=========================="

    if [[ -z "$rama" ]]; then
        # Listar todas las ramas
        echo "🌿 RAMAS DISPONIBLES:"
        echo "-------------------"
        local ramas=($(ls -1 "$GIT_BASE_PATH" 2>/dev/null))
        
        if [[ ${#ramas[@]} -eq 0 ]]; then
            echo "ℹ️  No se encontraron ramas en: $GIT_BASE_PATH"
        else
            for rama_item in "${ramas[@]}"; do
                if [[ -d "$GIT_BASE_PATH/$rama_item" ]]; then
                    local project_count=$(ls -1 "$GIT_BASE_PATH/$rama_item" 2>/dev/null | wc -l)
                    echo "📂 $rama_item - $project_count proyectos"
                fi
            done
        fi
    else
        # Listar proyectos en rama específica
        local ruta_rama="${GIT_BASE_PATH}/${rama}"
        
        if [[ ! -d "$ruta_rama" ]]; then
            echo "❌ Rama no encontrada: $rama"
            echo "📋 Ramas disponibles:"
            ls -1 "$GIT_BASE_PATH" 2>/dev/null
        else
            echo "📂 PROYECTOS EN RAMA: $rama"
            echo "----------------------------"
            local proyectos=($(ls -1 "$ruta_rama" 2>/dev/null))
            
            if [[ ${#proyectos[@]} -eq 0 ]]; then
                echo "ℹ️  No se encontraron proyectos en: $rama"
            else
                for proyecto in "${proyectos[@]}"; do
                    local proyecto_ruta="$ruta_rama/$proyecto"
                    if [[ -d "$proyecto_ruta" ]]; then
                        # Verificar si es repo git
                        if [[ -d "$proyecto_ruta/.git" ]]; then
                            echo "✅ $proyecto (Git repo)"
                        else
                            echo "📁 $proyecto (Directorio)"
                        fi
                    fi
                done
                echo ""
                echo "📊 Total: ${#proyectos[@]} proyectos"
            fi
        fi
    fi

    echo ""
    read -r "?⏸️  Presiona cualquier tecla para continuar..."
}

# Función de Merge Inteligente
git_merge_automation() {
    # Configuración inicial
    local rama_actual="" rama_destino="" proyecto="" auto_resolve=false
    local critical_error=0 ruta_proyecto=""
    
    # Función de ayuda
    show_merge_help() {
        echo "🔄 Git Merge Automation - Ayuda"
        echo "=========================================="
        echo "Uso: gitm <rama_actual> <proyecto> <rama_destino> [OPCIONES]"
        echo ""
        echo "Parámetros obligatorios:"
        echo "  <rama_actual>   - Rama donde estás trabajando"
        echo "  <proyecto>      - Nombre del proyecto"
        echo "  <rama_destino>  - Rama a la que quieres mergear"
        echo ""
        echo "Opciones disponibles:"
        echo "  -a, --auto      - Intentar resolución automática de conflictos"
        echo "  -f, --force     - Forzar merge (no recomendado)"
        echo "  -s, --squash    - Hacer squash merge"
        echo ""
        echo "Ejemplos:"
        echo "  gitm feature-branch app main"
        echo "  gitm develop api main --auto"
        echo "  gitm hotfix web staging --squash"
    }

    # Función de manejo de errores consistente
    handle_merge_error() {
        local message="$1" level="$2" recommendation="$3"
        
        case "$level" in
            "critical")
                echo "❌ ERROR CRÍTICO EN MERGE: $message"
                [[ -n "$recommendation" ]] && echo "💡 Recomendación: $recommendation"
                critical_error=1
                return 1
                ;;
            "warning")
                echo "⚠️  ADVERTENCIA EN MERGE: $message"
                [[ -n "$recommendation" ]] && echo "💡 Sugerencia: $recommendation"
                return 0
                ;;
            "info")
                echo "ℹ️  INFORMACIÓN DE MERGE: $message"
                return 0
                ;;
            *)
                echo "❌ Error en merge: $message"
                return 1
                ;;
        esac
    }

    # Función para verificar pre-condiciones del merge
    check_merge_prerequisites() {
        echo "🔍 Verificando pre-condiciones..."
        
        # Verificar que estamos en la rama correcta
        local current_branch=$(git symbolic-ref --short HEAD)
        if [[ "$current_branch" != "$rama_actual" ]]; then
            handle_merge_error "No estás en la rama '$rama_actual'" "critical" \
                "Cambia a la rama con: git checkout $rama_actual"
            return 1
        fi

        # Verificar que el working directory está clean
        if ! git diff-index --quiet HEAD --; then
            handle_merge_error "Hay cambios sin commit en el working directory" "critical" \
                "Haz commit de tus cambios o usa git stash antes del merge"
            return 1
        fi

        # Verificar que la rama destino existe
        if ! git show-ref --verify --quiet "refs/heads/$rama_destino"; then
            handle_merge_error "La rama destino '$rama_destino' no existe" "critical" \
                "Verifica el nombre de la rama con: git branch -a"
            return 1
        fi

        # Verificar que la rama actual existe
        if ! git show-ref --verify --quiet "refs/heads/$rama_actual"; then
            handle_merge_error "La rama actual '$rama_actual' no existe" "critical" \
                "Verifica el nombre de la rama con: git branch -a"
            return 1
        fi

        echo "✅ Pre-condiciones verificadas correctamente"
        return 0
    }

    # Función para mostrar diferencias antes del merge
    show_merge_preview() {
        echo "📊 VISTA PREVIA DEL MERGE"
        echo "=========================="
        
        # Mostrar commits que se van a mergear
        local commit_count=$(git log --oneline "$rama_actual".."$rama_destino" | wc -l)
        echo "📈 Commits a mergear: $commit_count"
        
        if [[ $commit_count -gt 0 ]]; then
            echo "📜 Últimos commits en $rama_actual:"
            git log --oneline -5 "$rama_actual"
            echo ""
            echo "📜 Últimos commits en $rama_destino:"
            git log --oneline -5 "$rama_destino"
        fi

        # Mostrar archivos modificados
        echo ""
        echo "📁 Archivos que podrían tener conflictos:"
        git diff --name-only "$rama_actual"..."$rama_destino" | head -10
    }

    # Función para confirmación del usuario
    get_user_confirmation() {
        echo ""
        echo "🚨 ¿Estás seguro de que quieres mergear $rama_actual en $rama_destino?"
        echo "   Esta operación puede modificar significativamente el repositorio."
        echo ""
        read -r "?🤔 Confirma la operación (sí/no): " confirmation
        
        case "$confirmation" in
            [sS][iI]|[sS]|[yY][eE][sS]|[yY])
                echo "✅ Confirmado. Procediendo con el merge..."
                return 0
                ;;
            *)
                handle_merge_error "Merge cancelado por el usuario" "info"
                return 1
                ;;
        esac
    }

    # Función para resolución automática de conflictos simples
    auto_resolve_conflicts() {
        echo "🛠️  Intentando resolución automática de conflictos..."
        
        local resolved_files=0
        local conflict_files=$(git diff --name-only --diff-filter=U)
        
        for file in $conflict_files; do
            echo "🔧 Procesando: $file"
            
            # Intentar estrategias de resolución automática
            if [[ $file == *".json"* || $file == *".lock"* ]]; then
                # Para archivos JSON y lock files, usar la versión de la rama actual
                git checkout --ours "$file"
                git add "$file"
                ((resolved_files++))
                echo "   ✅ Resuelto usando versión actual (ours)"
            elif [[ $file == *"package.json"* || $file == *"composer.json"* ]]; then
                # Para archivos de dependencias, es mejor abortar
                echo "   ⚠️  Archivo de dependencias - requiere intervención manual"
            else
                # Para otros archivos, intentar con merge tool o dejar para manual
                echo "   ℹ️  Requiere intervención manual"
            fi
        done

        if [[ $resolved_files -gt 0 ]]; then
            echo "✅ $resolved_files conflictos resueltos automáticamente"
            return 0
        else
            echo "❌ No se pudieron resolver conflictos automáticamente"
            return 1
        fi
    }

    # Función principal de merge
    perform_merge() {
        echo "🔄 INICIANDO PROCESO DE MERGE"
        echo "=============================="
        
        # Actualizar ambas ramas
        echo "📥 Actualizando ramas remotas..."
        git fetch origin "$rama_actual" || handle_merge_error "Error al fetch $rama_actual" "warning"
        git fetch origin "$rama_destino" || handle_merge_error "Error al fetch $rama_destino" "warning"

        # Cambiar a rama destino
        echo "🌿 Cambiando a rama destino: $rama_destino"
        if ! git checkout "$rama_destino"; then
            handle_merge_error "No se pudo cambiar a la rama destino" "critical"
            return 1
        fi

        # Actualizar rama destino
        echo "📥 Actualizando rama destino..."
        if ! git pull origin "$rama_destino"; then
            handle_merge_error "Error al actualizar rama destino" "critical"
            return 1
        fi

        # Ejecutar merge
        echo "🔀 Ejecutando merge..."
        local merge_command="git merge $rama_actual"
        
        if [[ "$1" == "squash" ]]; then
            merge_command="git merge --squash $rama_actual"
            echo "📦 Usando squash merge"
        fi
        
        if ! eval "$merge_command"; then
            echo "❌ Merge falló - Conflictos detectados"
            
            # Mostrar archivos en conflicto
            local conflict_files=$(git diff --name-only --diff-filter=U)
            echo "📋 Archivos en conflicto:"
            echo "$conflict_files"
            
            # Intentar resolución automática si está habilitada
            if [[ "$auto_resolve" == "true" ]]; then
                if auto_resolve_conflicts; then
                    echo "✅ Conflictos resueltos automáticamente"
                    return 0
                fi
            fi
            
            # Guía para resolución manual
            echo ""
            echo "🛠️  RESOLUCIÓN MANUAL REQUERIDA"
            echo "==============================="
            echo "1. Edita los archivos en conflicto marcados con <<<<<<<, =======, >>>>>>>"
            echo "2. Para cada archivo, después de resolver: git add <archivo>"
            echo "3. Cuando termines: git commit -m 'Resuelve conflictos de merge'"
            echo "4. O si quieres abortar: git merge --abort"
            echo ""
            echo "💡 Usa 'git status' para ver el estado actual"
            
            handle_merge_error "Merge requiere resolución manual de conflictos" "critical"
            return 1
        fi

        echo "✅ Merge completado exitosamente"
        return 0
    }

    # Validación de parámetros
    if [[ $# -lt 3 ]]; then
        show_merge_help
        return 1
    fi

    # Procesar parámetros
    rama_actual="$1"
    proyecto="$2"
    rama_destino="$3"
    shift 3

    # Procesar opciones
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--auto)
                auto_resolve=true
                ;;
            -f|--force)
                # No implementado por seguridad, pero reservado para futuro
                echo "⚠️  Opción --force no implementada por seguridad"
                ;;
            -s|--squash)
                local squash_merge=true
                ;;
            -h|--help)
                show_merge_help
                return 0
                ;;
            *)
                handle_merge_error "Opción no reconocida: $1" "critical"
                show_merge_help
                return 1
                ;;
        esac
        shift
    done

    ruta_proyecto="${GIT_BASE_PATH}/${rama_actual}/${proyecto}"

    echo "🔄 INICIANDO MERGE AUTOMATIZADO"
    echo "==============================="
    echo "📋 Proyecto: $proyecto"
    echo "🌿 Rama origen: $rama_actual"
    echo "🎯 Rama destino: $rama_destino"
    echo "🤖 Resolución automática: $auto_resolve"
    echo "📁 Ruta: $ruta_proyecto"
    echo ""

    # Verificar existencia del proyecto
    if [[ ! -d "$ruta_proyecto" ]]; then
        handle_merge_error "Directorio no encontrado" "critical" \
            "Verifica: \n- Ruta base: $GIT_BASE_PATH \n- Rama: $rama_actual \n- Proyecto: $proyecto"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Navegar al proyecto
    cd "$ruta_proyecto" || {
        handle_merge_error "No se pudo acceder al directorio" "critical" "Verifica los permisos"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    }

    # Verificar que es repo git
    if [[ ! -d ".git" ]]; then
        handle_merge_error "No es un repositorio Git" "critical" "Inicializa con: git init"
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    # Ejecutar flujo de merge
    if ! check_merge_prerequisites; then
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    show_merge_preview

    if ! get_user_confirmation; then
        read -r "?⏸️  Presiona cualquier tecla para continuar..."
        return 1
    fi

    if perform_merge $squash_merge; then
        echo ""
        echo "✅ ¡MERGE COMPLETADO EXITOSAMENTE!"
        echo "=================================="
        echo "🌿 Rama origen: $rama_actual"
        echo "🎯 Rama destino: $rama_destino"
        echo "📋 Proyecto: $proyecto"
        echo "🕒 Hora: $(date +'%H:%M:%S')"
        echo ""
        echo "🎉 ¡Merge finalizado! Presiona cualquier tecla para continuar..."
    else
        echo ""
        echo "❌ MERGE NO COMPLETADO"
        echo "======================"
        echo "💡 Revisa los conflictos y completa el merge manualmente"
    fi

    read -r "?⏸️  Presiona cualquier tecla para continuar..."
    return $critical_error
}

# Aliases para acceso rápido
alias gita='git_automation'
alias gitp='git_push_automation'
alias gitm='git_merge_automation'
alias git-ls='git_list_projects'
