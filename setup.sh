#!/bin/bash

# Setup Script para Alo Docker
# Uso: ./setup.sh <accion>
# Acciones: init, build, start, stop, logs, clean

set -e

COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="alo"

log_info() {
    echo -e "${COLOR_BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${COLOR_RED}✗${NC} $1"
}

log_warning() {
    echo -e "${COLOR_YELLOW}⚠${NC} $1"
}

check_requirements() {
    log_info "Verificando requisitos..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose no está instalado"
        exit 1
    fi

    if [ ! -f ".env" ]; then
        log_warning ".env no encontrado"
        log_info "Creando .env desde .env.example..."
        cp .env.example .env
        log_warning "⚠ Por favor edita .env con tus valores antes de continuar"
        exit 0
    fi

    log_success "Requisitos OK"
}

init() {
    log_info "Inicializando Alo Docker..."
    check_requirements
    log_success "Inicialización completada"
    log_info "Próximo paso: ./setup.sh build"
}

build() {
    log_info "Construyendo imagen Docker..."
    check_requirements
    docker-compose build --no-cache
    log_success "Imagen construida"
}

start() {
    log_info "Iniciando servicios..."
    check_requirements
    docker-compose up -d

    log_success "Servicios iniciados"
    log_info "Esperando a que los servicios se estabilicen..."
    sleep 5

    log_info "Estado de servicios:"
    docker-compose ps

    echo ""
    log_info "URLs de acceso:"
    echo -e "  ${COLOR_BLUE}Dashboard:${NC} http://localhost:3000"
    echo -e "  ${COLOR_BLUE}Agentes API:${NC} http://localhost:8000"
    echo -e "  ${COLOR_BLUE}OpenClaw:${NC} http://localhost:18789"
    echo -e "  ${COLOR_BLUE}PostgreSQL:${NC} localhost:5432"
}

stop() {
    log_info "Deteniendo servicios..."
    docker-compose down
    log_success "Servicios detenidos"
}

logs() {
    log_info "Mostrando logs (Ctrl+C para salir)..."
    docker-compose logs -f "$@"
}

clean() {
    log_warning "Esto eliminará todos los datos (volúmenes, contenedores)"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Limpiando..."
        docker-compose down -v
        log_success "Limpieza completada"
    else
        log_info "Cancelado"
    fi
}

restart() {
    log_info "Reiniciando servicios..."
    docker-compose restart
    log_success "Servicios reiniciados"
}

status() {
    log_info "Estado de servicios:"
    docker-compose ps
    echo ""
    docker-compose logs --tail=20
}

shell() {
    log_info "Abriendo shell en contenedor Alo..."
    docker-compose exec alo bash
}

# Main
case "${1:-help}" in
    init)
        init
        ;;
    build)
        build
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        shift
        logs "$@"
        ;;
    status)
        status
        ;;
    shell)
        shell
        ;;
    clean)
        clean
        ;;
    help)
        cat << HELPTEXT
${COLOR_GREEN}🦜 Alo Docker - Script de Setup${NC}

${COLOR_BLUE}Uso:${NC}
  ./setup.sh <accion>

${COLOR_BLUE}Acciones:${NC}
  init       Inicializar (crear .env)
  build      Construir imagen Docker
  start      Iniciar servicios
  stop       Detener servicios
  restart    Reiniciar servicios
  status     Ver estado de servicios
  logs       Ver logs en vivo
  shell      Abrir shell en contenedor
  clean      Limpiar datos (PELIGRO: elimina volúmenes)
  help       Mostrar esta ayuda

${COLOR_BLUE}Ejemplos:${NC}
  ./setup.sh init          # Primer paso
  ./setup.sh build         # Construir imagen
  ./setup.sh start         # Iniciar servicios
  ./setup.sh logs alo      # Ver logs del servicio alo
  ./setup.sh shell         # Conectarse al contenedor

HELPTEXT
        ;;
    *)
        log_error "Acción desconocida: $1"
        echo "Usa './setup.sh help' para ver opciones"
        exit 1
        ;;
esac
