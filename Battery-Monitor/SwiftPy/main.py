import sys
import torch
import json
import joblib
from battery_data import GetBatteryData
from csv_logger import CSVLogger
from battery_model import BatteryModel
from model_config import FEATURE_COLUMNS, TARGET_COLUMN
from path_config import MODEL_DIR

# file paths
model_path = MODEL_DIR/"battery_model.pt"
x_path = MODEL_DIR/"x_scaler.pkl"
y_path = MODEL_DIR/"y_scaler.pkl"

def file_exists():
    if (
        not model_path.exists() or 
        not x_path.exists() or
        not y_path.exists()
        ):
        result = {
            "error": "Model requirements missing!"
        }
        print(json.dumps(result))
        sys.exit(1)


# get data
data = GetBatteryData()
system_info, process_info, powermetrics_info = data.get_info()

# access the dataframe, and insert a new row
logger = CSVLogger(process_info, powermetrics_info)
df = logger.insert_row(system_info)



# drop each row that is missing data from the feature columns
df = df.dropna(subset=FEATURE_COLUMNS + TARGET_COLUMN)


# load the .pkl files
x = joblib.load(MODEL_DIR / "x_scaler.pkl")
y = joblib.load(MODEL_DIR / "y_scaler.pkl")

# load the model
b_model = BatteryModel()
b_model.load(MODEL_DIR / "battery_model.pt")
b_model.model.eval()


# predict current battery time from the newest row
current_x = df[FEATURE_COLUMNS].iloc[[-1]].values
current_x_scaled = x.transform(current_x)


current_tensor = torch.tensor(
    current_x_scaled,
    dtype=torch.float32
).to(b_model.device)


with torch.no_grad():
    current_prediction_scaled = b_model.model(current_tensor)
    current_prediction = y.inverse_transform(
        current_prediction_scaled.cpu().numpy()
    )


features = df[FEATURE_COLUMNS].iloc[-1].to_dict()
prediction = max(0, int(current_prediction[0][0]))

result = {
    "features": features,
    "prediction": prediction
}
print (json.dumps(result))
sys.exit(0)
