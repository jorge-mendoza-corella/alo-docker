# 🦜 Alo Docker - Sistema Multi-Agente Portable

Clona **TODO** (código + infraestructura) y ejecuta en cualquier VPS Ubuntu virgen.

```bash
git clone git@github.com:tu-usuario/alo-docker.git
cd alo-docker
chmod +x deploy.sh
./deploy.sh
```

**Eso es todo.** En 10 minutos tienes:
- Dashboard (Next.js) en puerto 3000
- 9 Agentes IA ejecutándose
- Conectados a Supabase
- Alo sigue aquí en Telegram via OpenClaw (servidor base)

## 📋 Requisitos

- Docker 20.10+
- Docker Compose 2.0+
- SSH key de GitHub en `ssh-key`
- Credenciales de Bitwarden

## 🏗️ Arquitectura

```
VPS Ubuntu
├── OpenClaw (servidor base)
│   ├── Alo (yo, Claude API + Telegram)
│   └── Conecta a Docker
│
└── Docker (alo-docker)
    ├── agentes-dashboard (puerto 3000)
    ├── agentes-infra (puertos 8000-8001)
    ├── agentes_lineas_de_negocio
    └── Clona workspace completo automáticamente
```

## 🚀 Deploy Rápido

### Opción 1: Script automático (recomendado)
```bash
chmod +x deploy.sh
./deploy.sh
```

Configura todo: descarga SSH key, clona workspace, instala dependencias, inicia servicios.

### Opción 2: Manual
```bash
# Clonar
git clone git@github.com:tu-usuario/alo-docker.git
cd alo-docker

# Configurar
cp .env.example .env
# Edita .env con tus valores

# Construir
docker-compose build --build-arg GITHUB_USER=tu-usuario

# Iniciar
docker-compose up -d
```

## ⚙️ Configurar .env

Edita `.env` antes de ejecutar:

```bash
GITHUB_USER=tu-usuario-github
BW_MASTER_PASSWORD=tu_contraseña_maestra
BW_CLIENTID=tu_client_id
BW_CLIENTSECRET=tu_client_secret
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_KEY=tu_api_key
OPENCLAW_HOST=localhost
OPENCLAW_PORT=18789
```

## 📁 Estructura

```
alo-docker/
├── Dockerfile                  # Imagen con Node.js + agentes
├── docker-compose.yml          # Orquestación
├── deploy.sh                   # Script de deploy automático
├── setup.sh                    # Comandos útiles (logs, shell, restart)
├── .dockerignore              # Archivos a ignorar
├── .env.example               # Template de variables
├── .gitignore                 # Git ignore (protege secretos)
├── ssh-key                    # SSH key de GitHub (NO commitear)
└── README.md                  # Este archivo
```

Cuando el Docker inicia:
- Clona `openclaw-workspace` completo
- Instala dependencias (npm install en cada sub-proyecto)
- Dashboard listo en puerto 3000
- Agentes listos en puertos 8000-8001


## 🔐 Seguridad

### SSH Key
- Se usa solo para clonar el workspace en el build
- **NO se commitea** a Git
- Protegida en `.gitignore`
- La obtienes de Bitwarden: `ssh-key-github-personal-vps-clone-2026`

### Secretos
- `.env` nunca se commitea (en `.gitignore`)
- Solo `.env.example` es público
- Bitwarden password maestra se inyecta en runtime
- Workspace clonado y credenciales gestionadas dentro del Docker

## 📊 Puertos Expuestos

| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| 3000 | Dashboard | Next.js UI para agentes |
| 8000 | Agentes API | API principal |
| 8001 | Agentes API alt | API secundaria |

**OpenClaw + Alo:** Corriendo en servidor base (fuera del Docker)  
**Base de datos:** Supabase (via `SUPABASE_URL` y `SUPABASE_KEY`)

## 🛠️ Comandos Útiles

### Con setup.sh (recomendado)
```bash
./setup.sh start      # Iniciar
./setup.sh stop       # Detener
./setup.sh logs       # Ver logs
./setup.sh shell      # Entrar al contenedor
./setup.sh restart    # Reiniciar
./setup.sh status     # Ver estado
```

### Con docker-compose directo
```bash
docker-compose up -d              # Iniciar
docker-compose down               # Detener
docker-compose logs -f alo-agentes # Ver logs
docker-compose exec alo-agentes bash # Shell
docker-compose restart            # Reiniciar
```

## 🔄 Actualizar

```bash
# Traer cambios del workspace
docker-compose exec alo-agentes bash
cd workspace
git pull origin main

# O reconstruir todo
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
