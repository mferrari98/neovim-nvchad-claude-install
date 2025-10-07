#!/bin/bash

# Script de instalación de Neovim, NvChad y Claude Code
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
echo "================================================"
echo ""

# 1. INSTALAR DEPENDENCIAS
print_info "Instalando dependencias del sistema..."

# Detectar el gestor de paquetes
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    print_info "Sistema detectado: Debian/Ubuntu"
    sudo apt-get update
    
    # Instalar dependencias básicas (incluyendo wget como alternativa a curl)
    sudo apt-get install -y curl wget git tar gzip ripgrep fd-find ca-certificates
    
    # Verificar si Node.js ya está instalado
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js ya está instalado: $NODE_VERSION"
        
        # Verificar si npm está instalado
        if ! command -v npm &> /dev/null; then
            print_info "Instalando npm usando el gestor de Node.js..."
            # Instalar npm usando npm (viene con nodesource)
            curl -qL https://www.npmjs.com/install.sh | sudo bash
        else
            NPM_VERSION=$(npm --version)
            print_success "npm ya está instalado: v$NPM_VERSION"
        fi
    else
        print_info "Instalando Node.js y npm..."
        sudo apt-get install -y nodejs npm
    fi
    
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    print_info "Sistema detectado: Fedora/RHEL"
    sudo dnf install -y curl git tar gzip nodejs npm ripgrep fd-find
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    print_info "Sistema detectado: Arch Linux"
    sudo pacman -Sy --noconfirm curl git tar gzip nodejs npm ripgrep fd
else
    print_error "Gestor de paquetes no soportado"
    exit 1
fi

print_success "Dependencias del sistema instaladas"

# 2. INSTALAR NEOVIM
print_info "Descargando Neovim v0.11.4..."

cd /tmp

# Limpiar descargas previas
rm -f nvim-linux-x86_64.tar.gz

# URL de descarga
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz"

# Intentar descargar con wget primero (más confiable para GitHub)
if command -v wget &> /dev/null; then
    print_info "Descargando con wget..."
    if wget --tries=3 --timeout=30 --continue -O nvim-linux-x86_64.tar.gz "$NVIM_URL"; then
        print_success "Descarga completada con wget"
    else
        print_error "Fallo la descarga con wget"
        exit 1
    fi
else
    # Fallback a curl si wget no está disponible
    print_info "wget no disponible, usando curl..."
    MAX_RETRIES=3
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        print_info "Intento de descarga $((RETRY_COUNT + 1)) de $MAX_RETRIES..."
        
        if curl -L --retry 3 --retry-delay 2 --connect-timeout 30 -o nvim-linux-x86_64.tar.gz "$NVIM_URL"; then
            print_success "Descarga completada con curl"
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                print_warning "Descarga fallida, reintentando en 3 segundos..."
                sleep 3
            else
                print_error "No se pudo descargar Neovim después de $MAX_RETRIES intentos"
                print_info "Intenta descargar manualmente desde:"
                print_info "$NVIM_URL"
                exit 1
            fi
        fi
    done
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

print_info "Clonando NvChad..."
git clone https://github.com/NvChad/starter "$HOME/.config/nvim"

print_success "NvChad instalado correctamente"
print_info "La primera vez que abras Neovim, se instalarán los plugins automáticamente"

# 4. INSTALAR CLAUDE CODE
print_info "Instalando Claude Code..."

# Instalar Claude Code globalmente con npm
sudo npm install -g @anthropic-ai/claude-code

print_success "Claude Code instalado correctamente"
print_info "Verifica la instalación con: claude --version"

# RESUMEN FINAL
echo ""
echo "================================================"
print_success "¡Instalación completada exitosamente!"
echo "================================================"
echo ""
echo "Resumen de instalaciones:"
echo "  • Neovim v0.11.4 → /opt/nvim"
echo "  • NvChad → ~/.config/nvim"
echo "  • Claude Code → instalado globalmente"
echo ""
echo "Próximos pasos:"
echo "  1. Ejecuta 'nvim' para inicializar NvChad"
echo "  2. Configura Claude Code con: claude auth login"
echo "  3. Para usar Claude Code: claude [comando]"
echo ""
print_warning "IMPORTANTE: Reinicia tu terminal o ejecuta 'source ~/.bashrc'"
echo ""
