# Neovim + NvChad + Claude Code Installer

Script automatizado para instalar y configurar un entorno de desarrollo completo con Neovim, NvChad y Claude Code en sistemas Linux.

## 🚀 Estado Actual

✅ **Instalador completamente funcional**
- Instalación de Neovim v0.11.4
- Configuración de NvChad (starter)
- Instalación de Claude Code
- Sistema de reintentos y fallbacks
- Manejo robusto de descargas (wget/curl)
- Configuración automática de npm global sin sudo

## ¿Qué instala este script?

Este instalador configura automáticamente:

- **Neovim v0.11.4**: Editor de texto moderno y extensible
- **NvChad**: Configuración pre-hecha de Neovim con una interfaz moderna y plugins esenciales
- **Claude Code**: CLI oficial de Anthropic para interactuar con Claude desde la terminal

## Dependencias instaladas

El script también instala las dependencias necesarias:

- Git
- Node.js y npm (configurado para instalaciones globales sin sudo)
- Ripgrep (búsqueda de archivos rápida)
- fd-find (búsqueda de archivos)
- curl/wget (con fallback automático)
- tar, gzip
- ca-certificates

## Sistemas soportados

- ✅ Debian/Ubuntu (apt)
- ✅ Fedora/RHEL (dnf)
- ✅ Arch Linux (pacman)

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/mferrari98/neovim-nvchad-claude-install.git
cd neovim-nvchad-claude-install

# Ejecutar el instalador
chmod +x install.sh
./install.sh
```

⚠️ **Nota**: No ejecutes el script como root o con sudo. El script solicitará permisos elevados cuando sea necesario.

## Características

- ✅ Detección automática del gestor de paquetes
- ✅ Backup automático de configuraciones existentes (timestamped)
- ✅ Manejo de errores con reintentos (hasta 3 intentos)
- ✅ Output con colores para mejor legibilidad
- ✅ Descarga con fallback (wget → curl)
- ✅ Configuración de npm global sin permisos de sudo
- ✅ Verificación de instalación exitosa
- ✅ Protección contra ejecución como root

## Post-instalación

Después de ejecutar el script:

1. Reinicia tu terminal o ejecuta `source ~/.bashrc`
2. Ejecuta `nvim` para inicializar NvChad (instalará plugins automáticamente)
3. Configura Claude Code: `claude auth login`

## Uso

- **Neovim**: `nvim [archivo]`
- **Claude Code**: `claude [comando]`

## Estructura de instalación

```
/opt/nvim/                          # Binarios de Neovim
~/.config/nvim/                     # Configuración de NvChad
~/.local/share/nvim/                # Datos y plugins
~/.npm-global/                      # Paquetes npm globales (sin sudo)
```

## Solución de problemas

### Claude Code no se encuentra después de instalar
```bash
source ~/.bashrc
# o reinicia tu terminal
```

### Error de permisos con npm
El script configura npm automáticamente para instalar paquetes globales sin sudo en `~/.npm-global/`

### Restaurar configuración previa
Los backups se crean automáticamente con timestamp:
```bash
~/.config/nvim.backup.YYYYMMDD_HHMMSS
~/.local/share/nvim.backup.YYYYMMDD_HHMMSS
```

## Autor

Creado por mferrari98

## Licencia

MIT
