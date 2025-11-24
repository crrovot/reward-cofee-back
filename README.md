# Reward Coffee Backend

Backend API para Reward Coffee construido con Rails en modo API.

## 🚀 Inicio Rápido

### Prerrequisitos
- Docker
- Docker Compose

### Desarrollo Local

1. Copiar archivo de variables de entorno:
```bash
cp .env.example .env
```

2. Construir y levantar los contenedores:
```bash
docker compose build
docker compose up
```

El servidor estará disponible en `http://localhost:3000`

### Comandos Útiles

#### Crear la base de datos
```bash
docker compose exec web rails db:create
```

#### Ejecutar migraciones
```bash
docker compose exec web rails db:migrate
```

#### Ejecutar seeds
```bash
docker compose exec web rails db:seed
```

#### Abrir consola de Rails
```bash
docker compose exec web rails console
```

#### Ejecutar tests
```bash
docker compose exec web rspec
```

#### Ver logs
```bash
docker compose logs -f web
```

## 🏗️ Estructura de Docker

- **Dockerfile**: Imagen base para desarrollo
- **Dockerfile.prod**: Imagen optimizada para producción
- **docker-compose.yml**: Configuración base de servicios
- **docker-compose.override.yml**: Configuración específica para desarrollo (se aplica automáticamente)
- **docker-compose.prod.yml**: Configuración para producción

### Desarrollo
```bash
docker compose up
```

### Producción
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build
```

## 🔌 Conexión con Next.js

El backend está configurado para aceptar peticiones CORS desde tu aplicación Next.js.

Configura la variable `ALLOWED_ORIGINS` en tu archivo `.env`:
```
ALLOWED_ORIGINS=http://localhost:3001,http://localhost:3002
```

## 📦 Servicios

- **web**: Aplicación Rails API (Puerto 3000)
- **db**: PostgreSQL 15 (Puerto 5432)
- **redis**: Redis 7 (Puerto 6379)

## 🔐 Variables de Entorno

Ver `.env.example` para todas las variables disponibles.

## 📝 Licencia

MIT
