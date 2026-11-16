lazy import logging
import pandas as pd
from pathlib import Path


root= Path(__file__).resolve().parent.parent
raw_path = root / "data" / "appointments.csv"
required_columns = ["appt_date", "status"]
log = logging.getLogger(__name__)


def load_data(path: Path) -> pd.DataFrame:
    try:
        data = pd.read_csv(path)
        return data
    except Exception as e:
        log.error(f"Error loading data: {e}")
        return pd.DataFrame()


def checking_stats(data: pd.DataFrame) -> None:
    if data.empty:
        log.warning("DataFrame is empty.")
        return

    missing_columns = [col for col in required_columns if col not in data.columns]
    if missing_columns:
        log.warning(f"Missing required columns: {missing_columns}")

    missing_values = data.isnull().sum()
    log.info(f"Missing values per column:\n{missing_values}")

    duplicate_rows = data.duplicated().sum()
    log.info(f"Number of duplicate rows: {duplicate_rows}")

    log.info(f"Shape: {data.shape}; Crux: \n{data.info()}")


def drop_duplicates(data: pd.DataFrame) -> pd.DataFrame:
    initial_shape = data.shape
    data = data.drop_duplicates()
    log.info(f"Dropped {initial_shape[0] - data.shape[0]} duplicate rows.")
    return data

def clean_booking_channel(data: pd.DataFrame) -> pd.DataFrame:
    if "booking_channel" in data.columns:
        data["booking_channel"] = data.booking_channel.str.strip().str.title()
        log.info(f"Unique booking channels: {data.booking_channel.value_counts()}")
    else:
        log.warning("Column 'booking_channel' not found in DataFrame.")
    return data

def convert_dates(data: pd.DataFrame) -> pd.DataFrame:
    if "appt_date" in data.columns:
        data["appt_date"] = pd.to_datetime(data.appt_date, errors='coerce')
        log.info(f"Converted 'appt_date' to datetime. Null values: {data['appt_date'].isnull().sum()}")
    else:
        log.warning("Column 'appt_date' not found in DataFrame.")

    if "booked_on" in data.columns:
        data["booked_on"] = pd.to_datetime(data.booked_on, errors='coerce')
        log.info(f"Converted 'booked_on' to datetime. Null values: {data['booked_on'].isnull().sum()}")
    else:
        log.warning("Column 'booked_on' not found in DataFrame.")

    return data


def drop_unsuable_rows(data: pd.DataFrame) -> pd.DataFrame:
    initial_shape = data.shape
    data = data.dropna(subset=required_columns)
    log.info(f"Dropped {initial_shape[0] - data.shape[0]} rows with missing required values.")
    return data


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    data = load_data(raw_path)
    checking_stats(data)
    data = drop_duplicates(data)
    data = clean_booking_channel(data)
    data = convert_dates(data)
    data = drop_unsuable_rows(data)
    checking_stats(data)