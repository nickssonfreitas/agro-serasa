#!/bin/bash

# Inclui o arquivo fuctions.sh que contém as funções
source /agrilearn_app/scripts/DISK/fuctions.sh #/agrilearn_app/scripts/fuctions.sh

BASE_URL="/agrilearn_app/datasets" #"/agrilearn_app/datasets" 
# Lista de caminhos dos arquivos que serão vinculados
PATHS_LIST=(
    "$BASE_URL/algodao_2022_2023_2023_2023/eopatch/processed"
    "$BASE_URL/arroz_jan_23_24/eopatch/processed"
    "$BASE_URL/base/eopatch/processed"
    "$BASE_URL/soja_2022_2023/eopatch/processed"
    "$BASE_URL/from_test_to_train/eopatch/processed"
)

# Define o diretório onde os links simbólicos serão criados
LINKS_DIR="/agrilearn_app/output/experiment_12/data/eopatch/processed"

# Função para criar lid -ginks simbólicos com barra de progresso usando rsync
create_symlinks_with_progress() {
    local paths_list=("$@")
    local total_paths=${#paths_list[@]}
    local count=0

    for path in "${paths_list[@]}"; do
        count=$((count + 1))
        
        # Usa find para percorrer apenas os primeiros subdiretórios
        echo "Processing directory $path ($count/$total_paths)"
        find "$path" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
            relative_path="${dir#$path/}" # Caminho relativo ao diretório base
            link_name="$LINKS_DIR/$relative_path"
            
            # Cria o diretório pai do link, se necessário
            mkdir -p "$(dirname "$link_name")"
            
            if [ -L "$link_name" ]; then
                echo "Link $link_name already exists. Skipping..."
            else
                echo "Creating symlink for directory $dir"
                ln -s "$dir" "$link_name"
            fi
        done
        
        # Barra de progresso simples
        progress=$((count * 100 / total_paths))
        echo -ne "Progress: ["
        for ((i=0; i<progress; i+=2)); do echo -ne "#"; done
        for ((i=progress; i<100; i+=2)); do echo -ne " "; done
        echo -ne "] $progress% ($count/$total_paths)\r"
    done
    echo
}

# Main script
main() {
    local paths_list=("$@")

    # Verifica se o diretório LINKS_DIR existe, se não, cria-o
    if [ ! -d "$LINKS_DIR" ]; then
        echo "Directory '$LINKS_DIR' does not exist. Creating it now..."
        mkdir -p "$LINKS_DIR"
        echo "Directory '$LINKS_DIR' created."
    fi

    # # Conta e exibe a quantidade de arquivos e links simbólicos antes da criação
    # echo "Before creating symlinks:"
    # count_files_and_links "$LINKS_DIR"

    # Cria os links simbólicos a partir da lista com barra de progresso
    create_symlinks_with_progress "${paths_list[@]}"
    echo "Symbolic links created in '$LINKS_DIR'"

    # Conta e exibe a quantidade de arquivos e links simbólicos depois da criação
    # echo "After creating symlinks:"
    # count_files_and_links "$LINKS_DIR"
}

# Chama a função principal com a lista de caminhos
main "${PATHS_LIST[@]}"