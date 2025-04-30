#!/bin/bash

# Definição dos parâmetros diretamente no script
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export TZ=America/Sao_Paulo

# Definição dos parâmetros diretamente no script
BUCKET_NAME="brain-alternative-data-scientists-development"
BUCKET_PATH="/datasets/culture/culture_v01_raw_cropped" #"/datasets/culture/culture_v02"
OUTPUT_LOCAL_PATH="/agrilearn_app/datasets/eopatchs/processed"
OUTPUT_LOG_PATH="/agrilearn_app/output/copy_s3_to_ec2"
CULTURES=("cana") #("corn" "rice" "wheat" "soybean")
SETS=("train" "val" "test")

CURRENT_DATETIME=$(date +"%Y%m%d_%H%M%S")

# Definição dos parâmetros do log
log_file="${OUTPUT_LOG_PATH}/check_s3_to_ec2_${CURRENT_DATETIME}.log"
echo "Monitore o log com o comando: watch -n 1 tail -n 20 $log_file ----"

# Função para verificar a quantidade de arquivos no S3 e localmente
check_files() {
    local culture=$1
    local set=$2
    local s3_path="${BUCKET_PATH}/${culture}/${set}/"
    local local_path="$OUTPUT_LOCAL_PATH/${culture}/${set}/"

    echo "---- Verificando arquivos para cultura [${culture}] e conjunto [${set}] ----" | tee -a "$log_file"

    # Conta o número de arquivos no bucket S3
    TOTAL_FILES_S3=$(aws s3 ls s3://$BUCKET_NAME$s3_path --recursive --summarize | grep "Total Objects:" | awk '{print $3}')
    TOTAL_DIRS_S3=$(aws s3 ls s3://$BUCKET_NAME$s3_path | wc -l)

    # Conta o número de arquivos localmente
    if [ -d "$local_path" ]; then
        TOTAL_FILES_LOCAL=$(find "$local_path" -type f | wc -l)
        TOTAL_DIR_LOCAL=$(find "$local_path" -mindepth 1 -maxdepth 1 -type d | wc -l)
    else
        echo "... $local_path não existe" | tee -a "$log_file"
        TOTAL_FILES_LOCAL=0
        TOTAL_DIR_LOCAL=0
    fi

    echo "... Arquivos no S3/Arquivos Locais: $TOTAL_FILES_S3 / $TOTAL_FILES_LOCAL" | tee -a "$log_file"
    echo "... Diretórios S3/Diretórios Locais: $TOTAL_DIRS_S3 / $TOTAL_DIR_LOCAL" | tee -a "$log_file"

    # Verifica se os números coincidem
    if [ "$TOTAL_FILES_S3" -eq "$TOTAL_FILES_LOCAL" ]; then
        echo "... Todos os arquivos foram copiados com sucesso para ${culture} - ${set} ----" | tee -a "$log_file"
    else
        MISSING_FILES=$(($TOTAL_FILES_S3 - $TOTAL_FILES_LOCAL))
        echo "... Faltam $MISSING_FILES arquivos para ${culture} - ${set} ----" | tee -a "$log_file"
        MISSING_DIR=$(($TOTAL_DIRS_S3 - $TOTAL_DIR_LOCAL))
        echo "... Faltam $MISSING_DIR diretórios para ${culture} - ${set} ----" | tee -a "$log_file"
    fi

    echo -e "\n" | tee -a "$log_file"
}

# Calcula o número total de combinações
TOTAL_COMBINATIONS=$((${#CULTURES[@]} * ${#SETS[@]}))

# Variável para contar as iterações
iteration_count=0

START_TIME=$(date +%s)

for culture in "${CULTURES[@]}"; do
    for set in "${SETS[@]}"; do
        iteration_count=$((iteration_count + 1))
        echo "Verificando o total de arquivos na cultura [${culture^^}] e conjunto [${set^^}] (Iteração $iteration_count de $TOTAL_COMBINATIONS)"
        check_files "$culture" "$set"
        echo
    done
done

END_TIME=$(date +%s)
EXECUTION_TIME=$(($END_TIME - $START_TIME))

HOURS=$(($EXECUTION_TIME / 3600))
MINUTES=$((($EXECUTION_TIME % 3600) / 60))
SECONDS=$(($EXECUTION_TIME % 60))

echo "---- Verificação finalizada ----" | tee -a "$log_file"
echo "... Tempo total de execução: $HOURS horas, $MINUTES minutos e $SECONDS segundos" | tee -a "$log_file"
