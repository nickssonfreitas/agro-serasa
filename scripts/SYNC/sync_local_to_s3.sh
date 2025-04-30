#!/bin/bash

# Definição dos parâmetros diretamente no script
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export TZ=America/Sao_Paulo
export AWS_DEFAULT_REGION="us-east-1"

LOG_PATH="/home/ec2-user/efs"
CURRENT_DATETIME=$(date +"%Y%m%d_%H%M%S")

log_file="${LOG_PATH}/sync_ec2_to_s3_${CURRENT_DATETIME}.log"
error_log_file="${LOG_PATH}/sync_ec2_to_s3_errors_${CURRENT_DATETIME}.log"
echo "Monitore o log com o comando: watch -n 1 tail -n 20 $log_file ----"

# Verificar se os parâmetros foram fornecidos
if [ $# -ne 2 ]; then
    echo "Uso: $0 <LOCAL_PATH> <BUCKET_PATH>"
    exit 1
fi

LOCAL_PATH="$1"
BUCKET_PATH="$2"

# Verificar se o LOCAL_PATH existe
if [ ! -d "$LOCAL_PATH" ]; then
    echo "Erro: O caminho local '$LOCAL_PATH' não existe."
    exit 1
fi

# Verificar se o BUCKET_PATH existe
aws s3 ls "$BUCKET_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Erro: O caminho do bucket S3 '$BUCKET_PATH' não existe ou não é acessível."
    exit 1
fi

# Função para sincronizar arquivos do disco local para o S3
sync_files() {
    local local_path="${LOCAL_PATH}"
    local s3_path="${BUCKET_PATH}"

    echo
    echo "---- Copiando arquivos do $local_path para o $s3_path ..." | tee -a "$log_file"
    echo "... Monitore o log usando watch -n 1 tail -n 20 $log_file ----" | tee -a "$log_file"

    START_TIME=$(date +%s)

    echo "... Iniciando a sincronização em $(date) ---- " | tee -a "$log_file"

    # Sincronizar arquivos e capturar a saída e erros
    sync_output=$(aws s3 sync "$local_path" "$s3_path" 2>&1)
    sync_exit_code=$?

    if [ $sync_exit_code -eq 0 ]; then
        echo "$sync_output" | tee -a "$log_file"
        echo "... Sincronização concluída com sucesso em $(date) ---" | tee -a "$log_file"
    else
        echo "$sync_output" | tee -a "$log_file"
        echo "$sync_output" >"$error_log_file"
        echo "... Erro na sincronização em $(date)" | tee -a "$log_file"
        echo "O arquivo do log de erros está em $error_log_file ----"
    fi

    END_TIME=$(date +%s)
    EXECUTION_TIME=$(($END_TIME - $START_TIME))

    HOURS=$(($EXECUTION_TIME / 3600))
    MINUTES=$((($EXECUTION_TIME % 3600) / 60))
    SECONDS=$(($EXECUTION_TIME % 60))

    echo "... Tempo total de execução: $HOURS horas, $MINUTES minutos e $SECONDS segundos" | tee -a "$log_file"

    echo "O arquivo do log está em $log_file ----"
}

sync_files
