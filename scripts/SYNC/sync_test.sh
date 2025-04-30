# Caminho fornecido
path="start_2023-04-01_end_2024-01-01_monitoring_class_WHEAT_epsg4326_minxymaxxy_-53dot26103336391809_-23dot13754744695287_-53dot25680128208265_-23dot128384631054846"

# Extrair o ano após 'start_'
start_year=$(echo $path | grep -oP '(?<=start_)\d{4}')

# Extrair o ano após 'end_'
end_year=$(echo $path | grep -oP '(?<=end_)\d{4}')

# Concatenar os anos com '_'
result="${start_year}_${end_year}"
echo $result