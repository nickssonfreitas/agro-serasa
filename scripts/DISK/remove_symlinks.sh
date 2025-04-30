#!/bin/bash

# Configuração do caminho onde os links simbólicos serão removidos
TARGET_DIRECTORY="/agrilearn_app/datasets/base/eopatch/processed/"


# Verifica se o diretório alvo está configurado
if [ -z "$TARGET_DIRECTORY" ]; then
    echo "Por favor, configure a variável TARGET_DIRECTORY no script."
    exit 1
fi

echo "Contando links simbólicos em: $TARGET_DIRECTORY"
total_before=$(count_symlinks "$TARGET_DIRECTORY")
echo "Total de links simbólicos antes: $total_before"

remove_symlinks "$TARGET_DIRECTORY"

total_after=$(count_symlinks "$TARGET_DIRECTORY")
echo "Total de links simbólicos depois: $total_after"
#!/bin/bash


# Diretório alvo passado como argumento
directory=$1

if [ -z "$directory" ]; then
    echo "Uso: $0 <diretório>"
    exit 1
fi

echo "Contando links simbólicos em: $directory"
total_before=$(count_symlinks "$directory")
echo "Total de links simbólicos antes: $total_before"

remove_symlinks "$directory"

total_after=$(count_symlinks "$directory")
echo "Total de links simbólicos depois: $total_after"
#!/bin/bash

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

# Diretório alvo passado como argumento
directory=$1

if [ -z "$directory" ]; then
    echo "Uso: $0 <diretório>"
    exit 1
fi

echo "Contando links simbólicos em: $directory"
total_before=$(count_symlinks "$directory")
echo "Total de links simbólicos antes: $total_before"

remove_symlinks "$directory"

total_after=$(count_symlinks "$directory")
echo "Total de links simbólicos depois: $total_after"
#!/bin/bash

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

# Diretório alvo passado como argumento
directory=$1

if [ -z "$directory" ]; then
    echo "Uso: $0 <diretório>"
    exit 1
fi

echo "Contando links simbólicos em: $directory"
total_before=$(count_symlinks "$directory")
echo "Total de links simbólicos antes: $total_before"

remove_symlinks "$directory"

total_after=$(count_symlinks "$directory")
echo "Total de links simbólicos depois: $total_after"
