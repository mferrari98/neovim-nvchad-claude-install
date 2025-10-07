# Neovim + NvChad + Claude Code Installer

Script automatizado para instalar y configurar un entorno de desarrollo completo con Neovim, NvChad y Claude Code en sistemas Linux.

## ¿Qué instala este script?

Este instalador configura automáticamente:

- **Neovim v0.11.4**: Editor de texto moderno y extensible
- **NvChad**: Configuración pre-hecha de Neovim con una interfaz moderna y plugins esenciales
- **Claude Code**: CLI oficial de Anthropic para interactuar con Claude desde la terminal

## Dependencias instaladas

El script también instala las dependencias necesarias:

- Git
- Node.js y npm
- Ripgrep (búsqueda de archivos rápida)
- fd-find (búsqueda de archivos)
- curl/wget
- tar, gzip

## Sistemas soportados

- ✅ Debian/Ubuntu (apt)
- ✅ Fedora/RHEL (dnf)
- ✅ Arch Linux (pacman)

## Instalación

```bash
chmod +x install.sh
./install.sh
```

⚠️ **Nota**: No ejecutes el script como root o con sudo. El script solicitará permisos elevados cuando sea necesario.

## Características

- ✅ Detección automática del gestor de paquetes
- ✅ Backup automático de configuraciones existentes
- ✅ Manejo de errores con reintentos
- ✅ Output con colores para mejor legibilidad
- ✅ Descarga con fallback (wget → curl)

## Post-instalación

Después de ejecutar el script:

1. Reinicia tu terminal o ejecuta `source ~/.bashrc`
2. Ejecuta `nvim` para inicializar NvChad (instalará plugins automáticamente)
3. Configura Claude Code: `claude auth login`

## Uso

- **Neovim**: `nvim [archivo]`
- **Claude Code**: `claude [comando]`

## Autor

Creado por mferrari98
