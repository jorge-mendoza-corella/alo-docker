#!/bin/bash

# Deploy Script para Alo - Sistema Multi-Agente
# Automatiza el setup completo en un VPS virgen
# Uso: ./deploy.sh

set -e

COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${COLOR_BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${COLOR_GREEN}✓${NC} $1"; }
log_error() { echo -e "${COLOR_RED}✗${NC} $1"; exit 1; }
log_warning() { echo -e "${COLOR_YELLOW}⚠${NC} $1"; }

# Header
clear
echo -e "${COLOR_GREEN}"
echo "╔════════════════════════════════════════╗"
echo "║   🦜 ALO - Deploy en Docker            ║"
echo "║   Sistema Multi-Agente IA              ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Verificar requisitos
log_info "Verificando requisitos..."

if ! command -v docker &> /dev/null; then
    log_error "Docker no está instalado. Instálalo primero: https://docs.docker.com/install/"
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose no está instalado"
fi

log_success "Docker y Docker Compose disponibles"
echo ""

# Verificar SSH key
log_info "Verificando SSH key para GitHub..."
if [ ! -f "ssh-key" ]; then
    log_warning "SSH key no encontrada en ssh-key"
    log_info "Esta debe estar en: $(pwd)/ssh-key"
    log_info "Obtén la SSH key de Bitwarden con tu alteza"
    read -p "¿Continuar sin SSH key? (requiere autenticación Git manual): (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    log_success "SSH key encontrada"
fi
echo ""

# Verificar .env
log_info "Verificando configuración (.env)..."
if [ ! -f ".env" ]; then
    log_warning ".env no encontrado"
    log_info "Creando .env desde .env.example..."
    cp .env.example .env
    log_warning "⚠ IMPORTANTE: Edita .env con tus valores ANTES de continuar"
    echo ""
    echo "Variables requeridas:"
    echo "  GITHUB_USER           - Tu usuario de GitHub"
    echo "  BW_MASTER_PASSWORD    - Contraseña maestra de Bitwarden"
    echo "  BW_CLIENTID           - Client ID de Bitwarden"
    echo "  BW_CLIENTSECRET       - Client Secret de Bitwarden"
    echo "  SUPABASE_URL          - URL de tu proyecto Supabase"
    echo "  SUPABASE_KEY          - API Key de Supabase"
    echo ""
    read -p "Presiona Enter cuando hayas configurado .env..."
fi

# Cargar .env
if [ -f ".env" ]; then
    export $(cat .env | xargs)
    log_success ".env cargado"
else
    log_error ".env no encontrado después de crear"
fi
echo ""

# Validar variables críticas
log_info "Validando variables..."
if [ -z "$GITHUB_USER" ]; then
    log_error "GITHUB_USER no está configurado en .env"
fi
if [ -z "$BW_MASTER_PASSWORD" ]; then
    log_warning "BW_MASTER_PASSWORD no está configurado (opcional si tienes credenciales cached)"
fi
log_success "Variables validadas"
echo ""

# Build
log_info "Construyendo imagen Docker..."
log_info "Esto puede tomar 5-10 minutos..."
if docker-compose build --build-arg GITHUB_USER=$GITHUB_USER; then
    log_success "Imagen construida exitosamente"
else
    log_error "Fallo al construir imagen. Verifica SSH key y GITHUB_USER"
fi
echo ""

# Start
log_info "Iniciando servicios..."
if docker-compose up -d; then
    log_success "Servicios iniciados"
else
    log_error "Fallo al iniciar servicios"
fi
echo ""

# Wait
log_info "Esperando a que los servicios se estabilicen..."
sleep 10

# Status
echo ""
echo -e "${COLOR_GREEN}════════════════════════════════════════${NC}"
echo -e "${COLOR_GREEN}      ✓ DEPLOY COMPLETADO${NC}"
echo -e "${COLOR_GREEN}════════════════════════════════════════${NC}"
echo ""

log_info "Estado de servicios:"
docker-compose ps
echo ""

log_info "URLs de acceso:"
echo -e "  ${COLOR_BLUE}📊 Dashboard:${NC}     http://localhost:3000"
echo -e "  ${COLOR_BLUE}🤖 Agentes API:${NC}    http://localhost:8000"
echo -e "  ${COLOR_BLUE}🔄 API Alt:${NC}        http://localhost:8001"
echo ""

log_info "Próximos pasos:"
echo "  1. Verifica logs: docker-compose logs -f alo-agentes"
echo "  2. Entra al contenedor: docker-compose exec alo-agentes bash"
echo "  3. Alo seguirá aquí en Telegram via OpenClaw (servidor base)"
echo ""

log_info "Comandos útiles:"
echo "  ./setup.sh logs          - Ver logs en vivo"
echo "  ./setup.sh shell         - Entrar al contenedor"
echo "  ./setup.sh restart       - Reiniciar servicios"
echo "  ./setup.sh status        - Ver estado"
echo "  docker-compose down      - Detener servicios"
echo ""

echo -e "${COLOR_YELLOW}Nota:${NC} OpenClaw sigue corriendo en el servidor base"
echo -e "${COLOR_YELLOW}      Alo (yo) me comunico contigo por Telegram desde ahí"
echo ""
