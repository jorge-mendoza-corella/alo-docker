# 🦜 Alo Docker - Infraestructura Portable

Este repositorio contiene la configuración de Docker para desplegar **Alo** (agente de IA multi-agente) de manera portable en cualquier servidor Ubuntu.

## 📋 Requisitos

- Docker 20.10+
- Docker Compose 2.0+
- SSH key configurada para acceso a GitHub
- Credenciales de Bitwarden (contraseña maestra)

## 🚀 Quick Start

### 1. Clonar el repositorio
```bash
git clone git@github.com:tu-usuario/alo-docker.git
cd alo-docker
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env
```

Edita `.env` con:
- `BW_MASTER_PASSWORD`: Contraseña maestra de Bitwarden
- `BW_CLIENTID` y `BW_CLIENTSECRET`: Credenciales de Bitwarden
- `POSTGRES_PASSWORD`: Contraseña para PostgreSQL

### 3. Copiar SSH key de GitHub (si no está en el sistema)
```bash
mkdir -p ~/.ssh
cp ssh-key ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```

### 4. Construir e iniciar
```bash
docker-compose up -d --build
```

### 5. Verificar estado
```bash
docker-compose ps
docker-compose logs alo
```

## 📁 Estructura

```
alo-docker/
├── Dockerfile                  # Imagen de Alo
├── docker-compose.yml          # Orquestación de servicios
├── .dockerignore              # Archivos a ignorar en build
├── .env.example               # Template de variables
├── .gitignore                 # Git ignore
├── ssh-key                    # SSH key privada para GitHub (NO commitear)
└── README.md                  # Este archivo
```

## 🔐 Seguridad

### SSH Key
- La SSH key se usa **SOLO** durante el build para clonar el repositorio
- **NO** debe commiterse a Git
- Se ignora automáticamente vía `.gitignore`

### Secretos
- Contraseña maestra de Bitwarden se inyecta via `.env`
- Nunca comitear `.env` (solo `.env.example`)
- Bitwarden CLI desbloquea credenciales dentro del contenedor

## 📊 Puertos Expuestos

- `3000`: Dashboard (Next.js)
- `8000`: Agentes API
- `8001`: Agentes API alternativo
- `18789`: OpenClaw Gateway
- `5432`: PostgreSQL

## 🛠️ Comandos Útiles

### Iniciar servicios
```bash
docker-compose up -d
```

### Ver logs
```bash
docker-compose logs -f alo
```

### Detener servicios
```bash
docker-compose down
```

### Reconstruir imagen
```bash
docker-compose up -d --build
```

### Ejecutar comando en el contenedor
```bash
docker-compose exec alo bash
```

### Acceder a PostgreSQL
```bash
docker-compose exec postgres psql -U alo -d agentes
```

## 🔄 Actualizar Alo

```bash
docker-compose down
docker-compose up -d --build
```

## ❌ Troubleshooting

### "Docker daemon not running"
```bash
sudo systemctl start docker
```

### "Permission denied while trying to connect to Docker daemon"
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### "Failed to clone repository"
- Verifica que la SSH key sea correcta
- Confirma acceso a GitHub: `ssh -T git@github.com`

### "Bitwarden unlock failed"
- Verifica que `BW_MASTER_PASSWORD` sea correcta
- Comprueba credenciales de Bitwarden en `.env`

## 📞 Contacto

Desarrollado para Jorge Mendoza (su alteza) - Sistemas de Agentes IA

---

**Última actualización:** 2026-05-04
**Versión:** 1.0
