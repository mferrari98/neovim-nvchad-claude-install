#!/bin/bash
# Script de instalación de Neovim, NvChad y Claude Code
# Compatible con: Arch Linux, Debian, Ubuntu
# Autor: Script automatizado
# Fecha: 2025

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Verificar si se ejecuta como root
if [ "$EUID" -eq 0 ]; then 
    print_error "No ejecutes este script como root (sin sudo)"
    exit 1
fi

echo "================================================"
echo "  Instalador de Neovim + NvChad + Claude Code"
echo "  Multi-distro: Arch, Debian, Ubuntu"
echo "================================================"
echo ""

# 1. DETECTAR DISTRIBUCIÓN E INSTALAR DEPENDENCIAS
print_info "Detectando sistema operativo..."

if command -v pacman &> /dev/null; then
    # ARCH LINUX
    print_info "Sistema detectado: Arch Linux"
    print_info "Instalando dependencias del sistema..."
    
    # En Arch, nodejs ya incluye npm
    sudo pacman -Sy --noconfirm curl wget git tar gzip nodejs ripgrep fd
    
elif command -v apt-get &> /dev/null; then
    # DEBIAN/UBUNTU
    print_info "Sistema detectado: Debian/Ubuntu"
    print_info "Actualizando repositorios..."
    sudo apt-get update
    
    print_info "Instalando dependencias básicas del sistema..."
    # Instalar solo las dependencias que no son nodejs/npm
    sudo apt-get install -y curl wget git tar gzip ripgrep fd-find ca-certificates
    
    # Verificar Node.js y npm
    print_info "Verificando Node.js y npm..."
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js ya instalado: $NODE_VERSION"
        
        if command -v npm &> /dev/null; then
            NPM_VERSION=$(npm --version)
            print_success "npm ya instalado: $NPM_VERSION"
        else
            print_error "Node.js instalado pero npm no encontrado"
            print_info "Tu instalación de Node.js parece incompleta"
            exit 1
        fi
    else
        print_warning "Node.js no encontrado"
        print_info "Instalando Node.js y npm desde repositorios oficiales de Debian..."
        
        # Intentar instalar solo nodejs primero (que debería incluir npm en repos oficiales)
        if sudo apt-get install -y nodejs; then
            print_success "Node.js instalado"
            
            # Verificar si npm vino incluido
            if ! command -v npm &> /dev/null; then
                print_info "Instalando npm por separado..."
                sudo apt-get install -y npm
            fi
        else
            print_error "No se pudo instalar Node.js"
            print_info "Instala Node.js manualmente y vuelve a ejecutar el script"
            exit 1
        fi
    fi
    
else
    print_error "Distribución no soportada. Este script solo funciona en Arch, Debian o Ubuntu."
    exit 1
fi

print_success "Dependencias del sistema instaladas"

# Configurar npm para instalaciones globales de usuario
print_info "Configurando npm para instalaciones globales de usuario..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Detectar shell (bash o fish)
if [ -n "$FISH_VERSION" ] || [ "$SHELL" = "/usr/bin/fish" ]; then
    SHELL_RC="$HOME/.config/fish/config.fish"
    EXPORT_CMD='set -gx PATH ~/.npm-global/bin $PATH'
else
    SHELL_RC="$HOME/.bashrc"
    EXPORT_CMD='export PATH=~/.npm-global/bin:$PATH'
fi

if ! grep -q '.npm-global/bin' "$SHELL_RC" 2>/dev/null; then
    echo "$EXPORT_CMD" >> "$SHELL_RC"
fi

export PATH=~/.npm-global/bin:$PATH

print_success "Node.js y npm configurados correctamente"

# 2. INSTALAR NEOVIM
print_info "Descargando Neovim v0.11.4..."
cd /tmp

# Limpiar descargas previas
rm -f nvim-linux-x86_64.tar.gz

# URL de descarga
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz"

# Test de conectividad
print_info "Verificando conectividad a internet..."
if wget --spider --quiet --tries=1 --timeout=5 https://www.google.com; then
    print_success "Conectividad verificada"
else
    print_warning "Problema de conectividad detectado, continuando de todas formas..."
fi

# Descargar con wget
print_info "Descargando con wget..."
if wget --tries=3 --timeout=30 --continue -O nvim-linux-x86_64.tar.gz "$NVIM_URL"; then
    print_success "Descarga completada"
else
    print_error "Falló la descarga"
    exit 1
fi

print_info "Extrayendo Neovim..."
tar -xzf nvim-linux-x86_64.tar.gz

print_info "Instalando Neovim en /opt/nvim..."
sudo rm -rf /opt/nvim
sudo mv nvim-linux-x86_64 /opt/nvim

print_info "Creando enlace simbólico..."
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# Limpiar
rm nvim-linux-x86_64.tar.gz

print_success "Neovim instalado correctamente"
nvim --version | head -n 1

# 3. INSTALAR NVCHAD
print_info "Instalando NvChad..."

# Hacer backup si existe una configuración previa
if [ -d "$HOME/.config/nvim" ]; then
    print_warning "Configuración existente de Neovim encontrada"
    BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_info "Creando backup en: $BACKUP_DIR"
    mv "$HOME/.config/nvim" "$BACKUP_DIR"
fi

if [ -d "$HOME/.local/share/nvim" ]; then
    BACKUP_DIR="$HOME/.local/share/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_info "Creando backup de datos en: $BACKUP_DIR"
    mv "$HOME/.local/share/nvim" "$BACKUP_DIR"
fi

if [ -d "$HOME/.local/state/nvim" ]; then
    BACKUP_DIR="$HOME/.local/state/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_info "Creando backup de estado en: $BACKUP_DIR"
    mv "$HOME/.local/state/nvim" "$BACKUP_DIR"
fi

if [ -d "$HOME/.cache/nvim" ]; then
    rm -rf "$HOME/.cache/nvim"
fi

print_info "Clonando NvChad..."
git clone https://github.com/NvChad/starter "$HOME/.config/nvim"

print_success "NvChad instalado correctamente"
print_info "La primera vez que abras Neovim, se instalarán los plugins automáticamente"

# 4. INSTALAR CLAUDE CODE
print_info "Instalando Claude Code..."

# Instalar Claude Code usando npm (sin sudo)
npm install -g @anthropic-ai/claude-code

print_success "Claude Code instalado correctamente"

# Verificar instalación
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "instalado")
    print_success "Claude Code verificado: $CLAUDE_VERSION"
else
    print_warning "Claude Code instalado pero no está en el PATH actual"
    print_info "Ejecuta 'source $SHELL_RC' para cargar el PATH actualizado"
fi

# RESUMEN FINAL
echo ""
echo "================================================"
print_success "¡Instalación completada exitosamente!"
echo "================================================"
echo ""
echo "Resumen de instalaciones:"
echo "  • Neovim v0.11.4 → /opt/nvim"
echo "  • NvChad → ~/.config/nvim"
echo "  • Claude Code → ~/.npm-global/bin"
echo ""
echo "Próximos pasos:"
echo "  1. Reinicia tu terminal o ejecuta: source $SHELL_RC"
echo "  2. Ejecuta 'nvim' para inicializar NvChad"
echo "  3. Configura Claude Code con: claude auth login"
echo "  4. Para usar Claude Code: claude [comando]"
echo ""
print_warning "IMPORTANTE: Reinicia tu terminal o ejecuta 'source $SHELL_RC'"
echo ""
