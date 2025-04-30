import os
import pandas as pd
import geopandas as gpd
from tqdm import tqdm
import logging
from shapely.geometry import Polygon, MultiPolygon
from agrilearn.crop_classification import geom_utils

# Configuração dos parâmetros
BASE_URL = "/agrilearn_app/datasets"
EXPERIMENT_NAME = "experiment_12"
GEOPACKAGE_PATHS = [
    f"{BASE_URL}/arroz_jan_23_24/geopackage/raw/arroz_jan_670.gpkg",
    f"{BASE_URL}/algodao_2022_2023_2023_2023/geopackage/raw/algodao_jan_4751.gpkg",
    f"{BASE_URL}/base/geopackage/processed/CORN_73080_SOYBEAN_29670_COTTON_1632_RICE_1172.gpkg",
    f"{BASE_URL}/base/geopackage/processed/SUGAR_CANE_35276_SOYBEAN_29670_CORN_5710_COTTON_1639_RICE_1173.gpkg",
    f"{BASE_URL}/from_test_to_train/geopackage/processed/SOYBEAN_1367_CORN_400_COTTON_216_RICE_62.gpkg",
    f"{BASE_URL}/soja_2022_2023/geopackage/raw/soja_mar_66835.gpkg",
    f"{BASE_URL}/base/geopackage/raw/wheat_train_v3.gpkg",
    f"{BASE_URL}/base/geopackage/raw/wheat_val_v3.gpkg",
    f"{BASE_URL}/base/geopackage/raw/wheat_test_v3.gpkg"
]
GEOPACKAGE_ENDO_SOJA = [f"{BASE_URL}/other/meso-soja/ref_edf_soja_processed.gpkg"]
OUTPUT_GPKG_PATH = f"{BASE_URL}/{EXPERIMENT_NAME}/processed/merged_geopackage.gpkg"
REPORTS_DIR = f"{BASE_URL}/{EXPERIMENT_NAME}/reports"

# Configuração do logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def read_and_concatenate_geopackages(paths):
    gdfs = []
    for path in paths:
        logging.info(f"Lendo geopackage: {path}")
        gdf = gpd.read_file(path)
        gdf['dataset_source'] = path  # Adiciona a coluna de origem
        gdfs.append(gdf)
    if gdfs:
        df = gpd.GeoDataFrame(pd.concat(gdfs, ignore_index=True))
        logging.info(f"Dataset final possui {df.shape[0]} linhas")
        return df
    else:
        logging.warning("Nenhum GeoDataFrame válido encontrado.")
        return None

def clean_data(df):
    datetime_columns = ['start_season', 'end_season', 'peak_start', 'peak_end', 'start_of_season', 'peak_of_season', 'end_of_season', 'planting_start', 'planting_end', 'start_of_cycle', 'end_of_cycle']
    for col in datetime_columns:
        if col in df.columns:
            try:
                df[col] = pd.to_datetime(df[col])
                logging.info(f"Coluna {col} formatada para datetime.")
            except Exception as e:
                logging.error(f"Erro ao formatar a coluna {col}: {e}")
        else:
            logging.warning(f"A coluna '{col}' não existe no DataFrame.")
    
    shape_before = df.shape[1]
    df.dropna(axis=1, how='all', inplace=True)
    logging.info(f"Removed Columns: {shape_before - df.shape[1]}, Percentage: {(shape_before - df.shape[1]) / shape_before * 100:.2f}%")

    df_check_NaN = pd.concat([df.isna().sum(), df.isna().sum() / df.shape[0] * 100], axis=1)
    df_check_NaN.columns = ['Null Count', 'NaN percentage']
    df_check_NaN.sort_values('NaN percentage', ascending=False, inplace=True)

    columns_to_delete = list(df_check_NaN[df_check_NaN['NaN percentage'] > 50].index)
    df.drop(columns=columns_to_delete, inplace=True)
    logging.info(f"Colunas removidas devido a mais de 50% de valores NaN: {columns_to_delete}")

    df['geometry_type'] = df['geometry'].apply(lambda geom: 'Polygon' if isinstance(geom, Polygon) else 'MultiPolygon')
    df['geometry'] = df['geometry'].apply(lambda geom: MultiPolygon([geom]) if isinstance(geom, Polygon) else geom)
    df['geometry_type'] = df['geometry'].apply(lambda geom: 'Polygon' if isinstance(geom, Polygon) else 'MultiPolygon')
    logging.info(f"Tipos de geometria após conversão: {df['geometry_type'].value_counts().to_dict()}")

    df_check_duplicated = df[df.duplicated(subset=['geometry', 'period'], keep=False)].copy()
    df_check_duplicated['id_duplicado'] = (df_check_duplicated.groupby(['geometry', 'period']).ngroup() + 1)
    df_check_duplicated.sort_values('id_duplicado', inplace=True)
    logging.info(f"Registros duplicados encontrados: {df_check_duplicated.shape[0]}")

    return df

def generate_reports(df, report_dir):
    if not os.path.exists(report_dir):
        os.makedirs(report_dir)

    columns_to_group = ['safra', 'edf', 'monitoring_class']
    report_distribuition = df.groupby(columns_to_group).agg(count=('eopath_location', 'count')).reset_index()
    total_count = len(df)
    report_distribuition['percentage'] = (report_distribuition['count'] / total_count) * 100
    report_distribuition.to_csv(os.path.join(report_dir, 'report_distribuition.csv'), index=False)
    logging.info(f"Relatório de distribuição salvo em: {os.path.join(report_dir, 'report_distribuition.csv')}")

    df['monitoring_class'].value_counts().to_csv(os.path.join(report_dir, 'monitoring_class_counts.csv'))
    logging.info(f"Contagem de classes de monitoramento salva em: {os.path.join(report_dir, 'monitoring_class_counts.csv')}")

    df['state'].value_counts().to_csv(os.path.join(report_dir, 'state_counts.csv'))
    logging.info(f"Contagem de estados salva em: {os.path.join(report_dir, 'state_counts.csv')}")

def add_features(df, df_edf):
    df = geom_utils.add_edf_feature(df_target=df, df_edf=df_edf, label_edf="edf")
    df['safra'] = df['period'].apply(lambda x: 'safrinha' if x.split('/')[0] == x.split('/')[1] else 'safra')
    logging.info("Novas features adicionadas: 'edf' e 'safra'")
    return df

def main():
    df = read_and_concatenate_geopackages(GEOPACKAGE_PATHS)
    if df is not None:
        df = clean_data(df)
        generate_reports(df, REPORTS_DIR)

        df_edf = read_and_concatenate_geopackages(GEOPACKAGE_ENDO_SOJA)
        if df_edf is not None:
            df = add_features(df, df_edf)

        df.to_file(OUTPUT_GPKG_PATH, driver="GPKG")
        logging.info(f"Arquivo geopackage salvo em: {OUTPUT_GPKG_PATH}")

if __name__ == "__main__":
    main()