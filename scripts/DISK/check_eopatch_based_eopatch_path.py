import geopandas as gpd
import pandas as pd
import os
from tqdm import tqdm
from eolearn.core import EOPatch

def check_eopatches_based_geopackage(gdf: pd.DataFrame, eopatch_path: str, label_monitoring_class: str = 'monitoring_class', label_eopatch_path: str = 'eopath_location') -> pd.DataFrame:
    """
    Verifica se a classe do eopatch está correta de acordo com o geopackage.

    Este script verifica se a classe do eopatch está correta de acordo com o geopackage.
    Ele percorre cada linha do GeoDataFrame, carrega o eopatch correspondente e verifica
    a classe de monitoramento. Retorna um DataFrame com as classes de monitoramento e quaisquer erros encontrados durante o processo.

    Parâmetros
    ----------
    gdf : GeoDataFrame
        Geodataframe do geopandas.
    eopatch_path : str
        Caminho para o eopatch no disco.
    label_monitoring_class : str, opcional
        Nome da coluna que contém a classe de monitoramento. O padrão é 'monitoring_class'.
    label_eopatch_path : str, opcional
        Nome da coluna que contém o caminho do eopatch. O padrão é 'eopath_location'.

    Retorna
    -------
    DataFrame
        DataFrame com classes de monitoramento e erros.
    """
    results = []

    # Itera sobre cada linha do DataFrame
    for index, row in tqdm(gdf.iterrows(), total=gdf.shape[0]):
        eopatch_location_id = row[label_eopatch_path]
        monitoring_class = row[label_monitoring_class]
        
        final_eopatch_path = os.path.join(eopatch_path, eopatch_location_id, "eopatch_0_col-0_row-0")

        try:
            eopatch = EOPatch.load(final_eopatch_path)
            labels = np.array(eopatch.meta_info['LABELS'])
            loaded_class = np.unique(labels)[0]
            load_class = True
            error = None
        except Exception as e:
            loaded_class = None
            load_class = False
            error = str(e)

        results.append({
            'eopath_location': eopatch_location_id,
            'monitoring_class': monitoring_class,
            'loaded_class': loaded_class,
            'load_class': load_class,
            'error': error
        })

    # Cria DataFrame para resultados
    df_results = pd.DataFrame(results)

    return df_results

if __name__ == "__main__":
    # Definindo os caminhos
    GEOPACKAGE_PATH = "/agrilearn_app/datasets/experiment_12/geopackage/SOYBEAN_48248_CORN_33784_SUGAR_CANE_17636_WHEAT_4224_COTTON_3166_RICE_917_train.gpkg"
    EOPATCH_PATH = "/agrilearn_app/datasets/experiment_12/eopatch/input_model/"

    # Carregando o geopackage
    gdf = gpd.read_file(GEOPACKAGE_PATH)

    # Verificando os eopatches
    df_results = check_eopatches_based_geopackage(gdf, EOPATCH_PATH)

    # Salvando o dataframe em um arquivo CSV
    df_results.to_csv('eopatch_results.csv', index=False)

    print("Processamento concluído. Verifique o arquivo 'eopatch_results.csv' para os resultados.")


    