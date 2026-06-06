← [Docker](..)

# Docker

Docker runs applications in isolated containers - useful for packaging AI tools with all their dependencies so they work without environment conflicts.

## Basic Commands

```powershell
# Check version
docker --version

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List downloaded images
docker images
```

## Running a Container

```powershell
docker run -d --name my-app -p 8080:80 image-name
```

- `-d` - run in background (detached)
- `--name` - give it a friendly name
- `-p 8080:80` - map container port 80 to your machine's port 8080

## Common AI Use Cases

**Ollama in Docker:**

```powershell
docker run -d --name ollama -p 11434:11434 ollama/ollama
```

**Stopping and starting:**

```powershell
docker stop ollama
docker start ollama
```

**Persistent data with volumes:**

```powershell
docker run -d --name ollama -v D:\AI_VAULT\ollama:/root/.ollama -p 11434:11434 ollama/ollama
```

The `-v` flag maps a folder on your machine into the container so models survive container updates.

## Docker Compose

For multi-service setups, use a `docker-compose.yml` file:

```yaml
services:
  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - D:\AI_VAULT\ollama:/root/.ollama
```

Then start everything with:

```powershell
docker compose up -d
```

## Cleanup

```powershell
# Remove a stopped container
docker rm container-name

# Remove unused images
docker image prune

# Stop all running containers
docker stop $(docker ps -q)
```
