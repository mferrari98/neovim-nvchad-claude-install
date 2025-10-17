# Instalador Automatizado de Neovim + NvChad

Script de instalación automatizada que configura un entorno de desarrollo completo basado en Neovim con configuración NvChad en sistemas Linux.

## Componentes Instalados

### Software Principal
- **Neovim v0.11.4**: Editor de texto moderno instalado en `/opt/nvim`
- **NvChad**: Framework de configuración para Neovim con interfaz moderna y conjunto de plugins preconfigurados
- **CLI de IA**: Herramienta de línea de comandos para asistencia de código

### Dependencias del Sistema
El script instala y configura automáticamente:
- **Git**: Control de versiones
- **Node.js y npm**: Runtime JavaScript (configurado para instalaciones globales en `~/.npm-global` sin privilegios de root)
- **Ripgrep**: Herramienta de búsqueda rápida en archivos
- **fd-find**: Búsqueda de archivos y directorios
- **wget/curl**: Gestores de descarga (con fallback automático)
- **tar, gzip**: Compresión y descompresión
- **ca-certificates**: Certificados para conexiones seguras

## Sistemas Soportados

- ✅ Debian/Ubuntu (apt)
- ✅ Arch Linux (pacman)

## Instalación

```bash
git clone https://github.com/mferrari98/neovim-nvchad-claude-install.git
cd neovim-nvchad-claude-install
chmod +x install.sh
./install.sh
```

⚠️ **Importante**: No ejecutar como root. El script solicita privilegios elevados automáticamente cuando es necesario.

## Funcionamiento del Script

### 1. Detección del Sistema
- Identifica automáticamente el gestor de paquetes (apt/pacman)
- Verifica conectividad a internet

### 2. Instalación de Dependencias
- Actualiza repositorios del sistema
- Instala paquetes base requeridos
- Verifica o instala Node.js/npm según disponibilidad

### 3. Configuración de npm
- Crea directorio `~/.npm-global` para paquetes globales
- Configura npm para instalaciones sin privilegios de root
- Actualiza PATH en archivo de configuración del shell (~/.bashrc o ~/.config/fish/config.fish)

### 4. Instalación de Neovim
- Descarga binario precompilado de Neovim v0.11.4
- Extrae a `/opt/nvim`
- Crea enlace simbólico en `/usr/local/bin/nvim`

### 5. Configuración de NvChad
- Crea backup con timestamp de configuraciones Neovim existentes
- Clona repositorio starter de NvChad a `~/.config/nvim`
- Prepara entorno para instalación automática de plugins en primer inicio

### 6. Instalación de Herramientas CLI
- Instala paquete npm global de asistencia de código
- Verifica disponibilidad en PATH

## Post-Instalación

1. Recargar configuración del shell: `source ~/.bashrc`
2. Inicializar Neovim: `nvim` (instalará plugins automáticamente en primer uso)
3. Configurar CLI de IA con autenticación según sea necesario

## Estructura de Directorios

```
/opt/nvim/                          # Binarios de Neovim
~/.config/nvim/                     # Configuración de NvChad
~/.local/share/nvim/                # Datos y plugins
~/.npm-global/                      # Paquetes npm globales
```

## Características Técnicas

- Detección automática del gestor de paquetes del sistema
- Sistema de backups automáticos con timestamps
- Verificación de conectividad antes de descargas
- Manejo de errores con reintentos (hasta 3 intentos)
- Protección contra ejecución como root
- Output colorizado para mejor legibilidad
- Configuración de PATH persistente según shell detectado

## Solución de Problemas

### Comando no encontrado después de instalar
```bash
source ~/.bashrc  # o reinicia la terminal
```

### Error de permisos con npm
El script configura automáticamente npm para instalaciones en `~/.npm-global/` sin requerir privilegios de root.

### Restaurar configuración anterior
Los backups se crean automáticamente:
```
~/.config/nvim.backup.YYYYMMDD_HHMMSS
~/.local/share/nvim.backup.YYYYMMDD_HHMMSS
~/.local/state/nvim.backup.YYYYMMDD_HHMMSS
```

## Desinstalación

Ejecutar el script `uninstall.sh` incluido en el repositorio para remover todos los componentes instalados.

## Licencia

MIT
