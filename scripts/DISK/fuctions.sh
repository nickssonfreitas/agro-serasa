# Função para contar links simbólicos em um diretório
count_symlinks() {
    local directory=$1
    find "$directory" -type l | wc -l
}

# Função para remover links simbólicos em um diretório
remove_symlinks() {
    local directory=$1
    find "$directory" -type l -exec rm -v {} \;
}
# Função para contar arquivos e links simbólicos em um diretório
count_files_and_links() {
    local dir=$1
    local file_count=$(find "$dir" -type f | wc -l)
    local link_count=$(find "$dir" -type l | wc -l)
    echo "Files: $file_count, Links: $link_count"
}

# Função para criar links simbólicos a partir de uma lista de caminhos
create_symlinks_from_list() {
    local paths_list=("$@")
    local links_dir=$LINKS_DIR

    # Cria o diretório de links se não existir
    mkdir -p "$links_dir"

    for src_path in "${paths_list[@]}"; do
        echo "Creating links for dataset: $(basename $(dirname $(dirname $src_path)))"
        if [ -d "$src_path" ]; then
            for file in "$src_path"/*; do
                link_name=$(basename "$file")
                ln -s "$file" "$links_dir/$link_name"
            done
        else
            echo "Source path '$src_path' does not exist or is not a directory."
        fi
    done
}