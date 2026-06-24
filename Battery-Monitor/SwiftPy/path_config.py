

import os
from pathlib import Path

# SwiftPy folder directory
DIR = Path(__file__).resolve().parent

# data directory
CONFIGURED_DATA_DIR = os.environ.get("BATTERY_MONITOR_DATA_DIR")
data_folder = DIR / "data"

if CONFIGURED_DATA_DIR:
    DATA_DIR = Path(CONFIGURED_DATA_DIR).expanduser()
elif data_folder.is_dir():
    DATA_DIR = data_folder
else:
    DATA_DIR = DIR


#DATA_DIR.mkdir(parents=True, exist_ok=True)

# Swiftpy/models directory
models_folder = DIR / "models"


if models_folder.is_dir():
    MODEL_DIR = models_folder
else:
    MODEL_DIR = DIR


