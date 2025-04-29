# Variáveis para o caminho do Dockerfile, docker-compose.yml e script de instalação NVIDIA
DOCKER_COMPOSE_PATH="docker-compose.yml"
CONTAINER_NAME="jupyter-lab-gpu"
NVIDIA_INSTALL_SCRIPT="install-NVIDIA-Driver-and-Nvidia-Docker.sh"

# Verificação de dependências
check-dependencies:
	@if [ "$$(id -u)" -ne 0 ] && ! groups | grep -q "\bdocker\b"; then \
		echo "Erro: Este comando precisa ser executado como root (use 'sudo') ou o usuário deve estar no grupo 'docker'."; \
		exit 1; \
	fi
	@command -v docker >/dev/null 2>&1 || { echo >&2 "Docker não está instalado. Por favor, instale o Docker."; exit 1; }
	@if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose --version >/dev/null 2>&1; then \
		echo "Docker Compose não está instalado ou configurado corretamente. Por favor, instale o Docker Compose."; \
		exit 1; \
	fi
	@echo "Todas as dependências estão instaladas corretamente."

# Comando para instalar os drivers NVIDIA no host
install-nvidia-drivers: check-dependencies
	@echo "Iniciando a instalação dos drivers NVIDIA no host..."
	@if [ -f ${NVIDIA_INSTALL_SCRIPT} ]; then \
		chmod +x ${NVIDIA_INSTALL_SCRIPT}; \
		sudo ./${NVIDIA_INSTALL_SCRIPT}; \
	else \
		echo "Erro: O script ${NVIDIA_INSTALL_SCRIPT} não foi encontrado."; \
		exit 1; \
	fi
	@echo "Instalação dos drivers NVIDIA concluída com sucesso!"

# Comando para construir a imagem Docker
build: check-dependencies
	@echo "Buildando e iniciando o container..."
	docker-compose -f ${DOCKER_COMPOSE_PATH} up --build -d

# Comando para iniciar o container
start: check-dependencies
	@echo "Iniciando o container..."
	docker-compose -f ${DOCKER_COMPOSE_PATH} up -d

# Comando para parar o container
stop: check-dependencies
	@echo "Verificando contêineres em execução..."
	docker ps
	@echo "Parando o container..."
	docker-compose -f ${DOCKER_COMPOSE_PATH} down
	@echo "Contêiner parado com sucesso!"

# Comando para reconstruir a imagem Docker
rebuild: check-dependencies
	@echo "Reconstruindo a imagem Docker..."
	docker-compose -f ${DOCKER_COMPOSE_PATH} down
	docker-compose -f ${DOCKER_COMPOSE_PATH} up --build -d

# Comando para exibir os logs do container
logs: check-dependencies
	@echo "Exibindo os logs do container..."
	docker-compose -f ${DOCKER_COMPOSE_PATH} logs --follow

# Comando para acessar o shell do container
shell: check-dependencies
	@echo "Verificando se o contêiner está em execução..."
	@if [ "$$(docker ps -q -f name=${CONTAINER_NAME})" = "" ]; then \
		echo "Erro: O contêiner ${CONTAINER_NAME} não está em execução."; \
		exit 1; \
	fi
	@echo "Acessando o shell do container..."
	docker exec -it ${CONTAINER_NAME} /bin/bash

# Comando para limpar todos os recursos relacionados ao projeto
clean-all: check-dependencies
	@echo "Limpando todos os recursos relacionados ao projeto..."
	docker-compose -f ${DOCKER_COMPOSE_PATH} down --volumes --remove-orphans
	docker image prune -f
	docker volume prune -f
	docker network prune -f
	@echo "Limpeza completa concluída!"