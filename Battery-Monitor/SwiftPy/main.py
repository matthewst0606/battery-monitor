import sys
import pandas as pd
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

file_exists()


def format_minutes(minutes):
    minutes = max(0, int(round(minutes)))
    hours = minutes // 60
    remainder = minutes % 60

    if hours > 0: return f"{hours}h {remainder}m"
    return f"{remainder}m"


def model_confidence(scaled_values):
    avg_distance = float(abs(scaled_values).mean())

    if avg_distance < 0.75:  level = "High"
    elif avg_distance < 1.5: level = "Medium"
    else: level = "Low"

    return {
        "level": level,
        "reason": f"Average scaled feature distance is {avg_distance:.2f}.",
        "distanceFromTrainingData": avg_distance,
    }


def prediction_details(features, scaled_values, prediction, df):
    battery_percent = max(0.0, float(features.get("Battery_Percent", 0.0)))
    drain_percent_per_hour = 0.0
    full_runtime_minutes = 0



    valid_rows = df[df["Time_Remaining"] > 0]


    if prediction > 0 and battery_percent > 0:
        drain_percent_per_hour = battery_percent / (prediction / 60.0)
        avg_percent_per_hour = (valid_rows["Battery_Percent"] / (valid_rows["Time_Remaining"] / 60)).mean()
        full_runtime_minutes = int(round(prediction * (100.0 / battery_percent)))

    summary = f"Estimated {format_minutes(prediction)} remaining"
    if drain_percent_per_hour > 0:
        summary += f" at ~{drain_percent_per_hour:.1f}% per hour"

    return {
        "summary": summary,
        "confidence": model_confidence(scaled_values),
        "details": {
            "drainPercentPerHour": drain_percent_per_hour,
            "fullRuntimeMinutes": full_runtime_minutes,
            "avgDrainPerHour": avg_percent_per_hour,

        },
    }


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
details = prediction_details(features, current_x_scaled, prediction, df)

result = {
    "features": features,
    "prediction": prediction,
    **details
}
print (json.dumps(result))
sys.exit(0)
