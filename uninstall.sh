#!/bin/bash

# Script de desinstalación de Neovim, NvChad y Claude Code
# Autor: Script automatizado
# Fecha: 2025

# No usar set -e para permitir que el script continúe si algunos elementos no existen

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
echo "  Desinstalador de Neovim + NvChad + Claude Code"
echo "================================================"
echo ""

print_warning "Este script eliminará:"
echo "  • Neovim de /opt/nvim"
echo "  • NvChad de ~/.config/nvim"
echo "  • Claude Code (npm global)"
echo "  • Configuración de Claude Code (~/.claude)"
echo "  • Caché de Claude Code (~/.cache/claude)"
echo "  • Datos de Claude Code (~/.local/share/claude)"
echo "  • Configuración de npm global"
echo ""

read -p "¿Deseas continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_info "Desinstalación cancelada"
    exit 0
fi

# 1. DESINSTALAR CLAUDE CODE
print_info "Desinstalando Claude Code..."
if command -v npm &> /dev/null; then
    if npm list -g @anthropic-ai/claude-code &> /dev/null; then
        npm uninstall -g @anthropic-ai/claude-code
        print_success "Claude Code desinstalado"
    else
        print_info "Claude Code no estaba instalado"
    fi
else
    print_warning "npm no encontrado, omitiendo desinstalación de Claude Code"
fi

# Eliminar directorios de configuración y datos de Claude Code
print_info "Eliminando configuración y datos de Claude Code..."

if [ -d "$HOME/.claude" ]; then
    rm -rf "$HOME/.claude"
    print_success "Configuración de Claude Code eliminada (~/.claude)"
else
    print_info "No se encontró ~/.claude"
fi

if [ -d "$HOME/.cache/claude" ]; then
    rm -rf "$HOME/.cache/claude"
    print_success "Caché de Claude Code eliminada (~/.cache/claude)"
else
    print_info "No se encontró ~/.cache/claude"
fi

if [ -d "$HOME/.local/share/claude" ]; then
    rm -rf "$HOME/.local/share/claude"
    print_success "Datos de Claude Code eliminados (~/.local/share/claude)"
else
    print_info "No se encontró ~/.local/share/claude"
fi

# 2. ELIMINAR NVCHAD Y CONFIGURACIÓN DE NEOVIM
print_info "Eliminando NvChad y configuración de Neovim..."

if [ -d "$HOME/.config/nvim" ]; then
    rm -rf "$HOME/.config/nvim"
    print_success "Configuración de NvChad eliminada"
else
    print_info "No se encontró ~/.config/nvim"
fi

if [ -d "$HOME/.local/share/nvim" ]; then
    rm -rf "$HOME/.local/share/nvim"
    print_success "Datos de Neovim eliminados"
else
    print_info "No se encontró ~/.local/share/nvim"
fi

if [ -d "$HOME/.local/state/nvim" ]; then
    rm -rf "$HOME/.local/state/nvim"
    print_success "Estado de Neovim eliminado"
else
    print_info "No se encontró ~/.local/state/nvim"
fi

if [ -d "$HOME/.cache/nvim" ]; then
    rm -rf "$HOME/.cache/nvim"
    print_success "Caché de Neovim eliminada"
else
    print_info "No se encontró ~/.cache/nvim"
fi

# 3. DESINSTALAR NEOVIM
print_info "Desinstalando Neovim..."

if [ -L "/usr/local/bin/nvim" ] || [ -f "/usr/local/bin/nvim" ]; then
    sudo rm -f /usr/local/bin/nvim
    print_success "Enlace simbólico de Neovim eliminado"
fi

if [ -d "/opt/nvim" ]; then
    sudo rm -rf /opt/nvim
    print_success "Neovim eliminado de /opt/nvim"
else
    print_info "No se encontró /opt/nvim"
fi

# 4. LIMPIAR CONFIGURACIÓN DE NPM GLOBAL
print_info "Limpiando configuración de npm global..."

if [ -d "$HOME/.npm-global" ]; then
    print_warning "Directorio ~/.npm-global encontrado"
    read -p "¿Deseas eliminar ~/.npm-global? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        rm -rf "$HOME/.npm-global"
        print_success "Directorio ~/.npm-global eliminado"

        # Eliminar línea del PATH en .bashrc
        if [ -f ~/.bashrc ] && grep -q '.npm-global/bin' ~/.bashrc; then
            print_info "Eliminando configuración de PATH en ~/.bashrc..."
            sed -i '/\.npm-global\/bin/d' ~/.bashrc
            print_success "PATH actualizado en ~/.bashrc"
        fi
    else
        print_info "Se conservó ~/.npm-global"
    fi
else
    # Si ~/.npm-global no existe pero la línea está en .bashrc, limpiarla
    if [ -f ~/.bashrc ] && grep -q '.npm-global/bin' ~/.bashrc; then
        print_info "Eliminando configuración de PATH obsoleta en ~/.bashrc..."
        sed -i '/\.npm-global\/bin/d' ~/.bashrc
        print_success "PATH actualizado en ~/.bashrc"
    fi
fi

# 5. VERIFICAR BACKUPS
print_info "Buscando backups creados durante la instalación..."

# Habilitar nullglob para que el glob no devuelva el patrón literal si no hay matches
shopt -s nullglob
BACKUPS_FOUND=0
for backup in "$HOME/.config/nvim.backup."* "$HOME/.local/share/nvim.backup."*; do
    if [ -e "$backup" ]; then
        echo "  → $backup"
        BACKUPS_FOUND=$((BACKUPS_FOUND + 1))
    fi
done
shopt -u nullglob

if [ $BACKUPS_FOUND -gt 0 ]; then
    print_warning "Se encontraron $BACKUPS_FOUND backup(s)"
    echo "Puedes eliminarlos manualmente si no los necesitas"
else
    print_info "No se encontraron backups"
fi

# RESUMEN FINAL
echo ""
echo "================================================"
print_success "¡Desinstalación completada!"
echo "================================================"
echo ""
echo "Elementos eliminados:"
echo "  • Neovim de /opt/nvim"
echo "  • NvChad y configuración de Neovim"
echo "  • Claude Code y todos sus datos"
echo ""

if grep -q '.npm-global/bin' ~/.bashrc 2>/dev/null; then
    print_warning "IMPORTANTE: Reinicia tu terminal o ejecuta 'source ~/.bashrc'"
    echo ""
fi

# Mostrar paquetes del sistema instalados
echo "Nota: Los siguientes paquetes del sistema NO fueron eliminados:"
echo "  • nodejs, npm, git, curl, wget, ripgrep, fd-find"
echo ""
echo "Si deseas eliminarlos, ejecuta manualmente:"

if command -v apt-get &> /dev/null; then
    echo "  sudo apt-get remove nodejs npm ripgrep fd-find"
elif command -v dnf &> /dev/null; then
    echo "  sudo dnf remove nodejs npm ripgrep fd-find"
elif command -v pacman &> /dev/null; then
    echo "  sudo pacman -R nodejs npm ripgrep fd"
fi

echo ""
