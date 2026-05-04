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
    docker.io \
    systemctl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js v22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instalar Bitwarden CLI
RUN curl -L https://github.com/bitwarden/clients/releases/download/cli-v2024.12.0/bw-linux-x64.zip \
    -o /tmp/bw.zip \
    && unzip /tmp/bw.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/bw \
    && rm /tmp/bw.zip

# Crear directorio de trabajo
WORKDIR /home/alo

# Copiar SSH key para acceso a GitHub
COPY ssh-key /root/.ssh/id_ed25519
RUN chmod 600 /root/.ssh/id_ed25519 \
    && ssh-keyscan -H github.com >> /root/.ssh/known_hosts 2>/dev/null

# Configurar Git
RUN git config --global user.email "jorge.mendoza@sozu.com" \
    && git config --global user.name "Jorge Mendoza"

# Clonar el workspace de agentes
RUN git clone git@github.com:tu-usuario/openclaw-workspace.git . 2>/dev/null || echo "Repo no disponible en primer build"

# Instalar dependencias de agentes-dashboard
WORKDIR /home/alo/agentes-dashboard
RUN npm install --legacy-peer-deps 2>/dev/null || true

# Instalar dependencias de agentes-infra
WORKDIR /home/alo/agentes-infra
RUN npm install 2>/dev/null || true

# Instalar dependencias de agentes_lineas_de_negocio
WORKDIR /home/alo/agentes_lineas_de_negocio
RUN npm install 2>/dev/null || true

# Volver al directorio principal
WORKDIR /home/alo

# Crear directorios para datos persistentes
RUN mkdir -p /home/alo/.openclaw/secrets \
    && mkdir -p /home/alo/state

# Exponer puertos
EXPOSE 3000 8000 8001 18789

# Script de inicialización
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Inyectar contraseña maestra de Bitwarden si existe\n\
if [ ! -z "$BW_MASTER_PASSWORD" ]; then\n\
    export BW_PASSWORD="$BW_MASTER_PASSWORD"\n\
fi\n\
\n\
# Desbloquear Bitwarden y obtener credenciales\n\
if [ ! -z "$BW_PASSWORD" ]; then\n\
    BW_SESSION=$(bw unlock "$BW_PASSWORD" --raw)\n\
    export BW_SESSION\n\
fi\n\
\n\
# Iniciar servicios\n\
echo "Iniciando Alo..."\n\
echo "Dashboard en http://localhost:3000"\n\
echo "Agentes en http://localhost:8000 y http://localhost:8001"\n\
\n\
# Mantener el contenedor corriendo\n\
tail -f /dev/null\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
