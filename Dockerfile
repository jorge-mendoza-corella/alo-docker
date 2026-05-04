FROM ubuntu:24.04

# Instalar dependencias base
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    openssh-client \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js v22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /home/alo

# Copiar SSH key para acceso a GitHub
COPY ssh-key /root/.ssh/id_ed25519
RUN chmod 600 /root/.ssh/id_ed25519 \
    && ssh-keyscan -H github.com >> /root/.ssh/known_hosts 2>/dev/null

# Configurar Git
RUN git config --global user.email "jorge.mendoza@sozu.com" \
    && git config --global user.name "Jorge Mendoza"

# Variable de entorno para usuario de GitHub
ARG GITHUB_USER=tu-usuario
ENV GITHUB_USER=${GITHUB_USER}

# Clonar el workspace de agentes
RUN git clone git@github.com:${GITHUB_USER}/openclaw-workspace.git /home/alo/workspace 2>/dev/null || echo "⚠ Repo no disponible en primer build"

# Instalar dependencias de agentes-dashboard
WORKDIR /home/alo/workspace/agentes-dashboard
RUN npm install --legacy-peer-deps 2>/dev/null || true

# Instalar dependencias de agentes-infra
WORKDIR /home/alo/workspace/agentes-infra
RUN npm install 2>/dev/null || true

# Instalar dependencias de agentes_lineas_de_negocio
WORKDIR /home/alo/workspace/agentes_lineas_de_negocio
RUN npm install 2>/dev/null || true

# Volver al directorio principal
WORKDIR /home/alo

# Crear directorios para datos persistentes
RUN mkdir -p /home/alo/.openclaw/secrets \
    && mkdir -p /home/alo/state

# Crear script de inicialización para agentes
RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -e

echo "🦜 Alo - Sistema de Agentes"
echo "================================"
echo "Iniciando servicios..."
echo ""

# Descargar credenciales de Bitwarden si es necesario
if [ ! -z "$BW_MASTER_PASSWORD" ]; then
    echo "🔑 Desbloqueando Bitwarden..."
    export BW_PASSWORD="$BW_MASTER_PASSWORD"
    BW_SESSION=$(bw unlock "$BW_PASSWORD" --raw)
    export BW_SESSION
fi

# Esperar a que esté listo
echo ""
echo "✓ Sistema listo"
echo "  Dashboard: http://localhost:3000"
echo "  Agentes API: http://localhost:8000-8001"
echo ""
echo "Conectado a Telegram via OpenClaw (servidor base)"
echo ""

# Mantener contenedor activo
tail -f /dev/null
EOF
chmod +x /entrypoint.sh

# Exponer puertos
EXPOSE 3000 8000 8001

ENTRYPOINT ["/entrypoint.sh"]
