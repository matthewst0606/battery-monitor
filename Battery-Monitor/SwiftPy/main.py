import sys
import numpy as np
import torch
import joblib
import json
from sklearn.preprocessing import StandardScaler
from battery_data import GetBatteryData
from encoder import encode
from csv_logger import insert_row, process_row, gpu_row, cpu_row

from battery_model import BatteryModel

# more potential features
#-------------------------------
# 1. better automatic brightness adjustment based on current system data/usage.
# e.g. say like a user wants to get n hours out of their battery, the model can adjust
# brightness levels and other system factors to try and adjust to that request
# 2. Battery drain rate


data = GetBatteryData()
system_info = data.system_info
battery_info = data.battery_dict
if battery_info == None:
    print("Error occured: battery_info is missing...")
    sys.exit()


process_info = data.process_dict
if process_info == None:
    print("Error occured: process_info is missing...")
    sys.exit()


powermetrics_info = data.powermetrics_dict
if powermetrics_info == None:
    print("Error occured: powermetrics_info is missing...")
    sys.exit()


encoded_battery_info = encode(battery_info)
if encoded_battery_info == None:
    print("Error occured: encoded_battery_info is missing...")
    sys.exit()


# access the dataframe
process_df = process_row(process_info)
cpu_df = cpu_row(powermetrics_info)
gpu_df = gpu_row(powermetrics_info)
df = insert_row(
    system_info,
    process_df,
    cpu_df,
    gpu_df,
    battery_info,
    encoded_battery_info
)


## selecting device (M series chip) if available
#if torch.backends.mps.is_available(): device = 'mps'
#else: device = 'cpu'


#changed to cpu (better for battery)
# might add user preference later...
device = 'cpu'

feature_columns = [
    "Battery_Percent",
    "Maximum_Capacity",
    "Process_Count",
    "CPU_Usage",
    "Total_Memory",
    "Used_Memory",
    "Cycle_Count",
    "Charging",
    "Low_Power_Mode",
    "Process_Power",
    "Process_State",
    "Avg_CPU_Frequency",
    "Avg_CPU_Residency",
    "Avg_CPU_Idle",
    "CPU_Power",
    "GPU_Power",
    "Avg_GPU_Frequency",
    "Avg_GPU_Residency",
    "Avg_GPU_idle"
]
target_column = ["Time_Remaining"]


# drop each row that is missing data from the
# feature columns
df = df.dropna(subset=feature_columns + target_column)

# initialize scalers
x_scaler = StandardScaler()
y_scaler = StandardScaler()

x_scaled = x_scaler.fit_transform(df[feature_columns].values)
y_scaled = y_scaler.fit_transform(df[target_column].values)


# traning_data = x; target_data = y
training_data = torch.tensor(
    x_scaled,
    dtype=torch.float32
).to(device)

target_data = torch.tensor(
    y_scaled,
    dtype=torch.float32
).to(device)


# for a given x (training_data),
# the model tries to predict y (target_data)
# --------------------------------------------------
all_idx = np.arange(len(df))
np.random.shuffle(all_idx)

split = int(len(df) * 0.8)
# # training and validation indices
training_idx = all_idx[0:split]
validation_idx = all_idx[split:len(df)]

# first 80% of the data for training
x_train = training_data[training_idx]
y_train = target_data[training_idx]

# last 20% of the data for validation
x_val = training_data[validation_idx]
y_val = target_data[validation_idx]


# using the model
# --------------------------------------------------
b_model = BatteryModel(device) # initialize the model and optimizer
print('\n')
#b_model.run_model(x_train, y_train) # running the model

# --- evaluate model results on validation data ---
#actual_y, predicted_y, val_loss = b_model.evaluate_model(device, x_val, y_val, y_scaler)



# predict current battery time from the newest row
current_x = df[feature_columns].iloc[[-1]].values
current_x_scaled = x_scaler.transform(current_x)

current_tensor = torch.tensor(
    current_x_scaled,
    dtype=torch.float32
).to(device)


b_model.model.load_state_dict(
    torch.load("battery_model.pt")
)

b_model.model.eval()
with torch.no_grad():
    current_prediction_scaled = b_model.model(current_tensor)
    current_prediction = y_scaler.inverse_transform(
        current_prediction_scaled.cpu().numpy()
    )




features = df[feature_columns].iloc[-1].to_dict()
prediction = int(current_prediction[0][0])

result = {
    "features": features,
    "prediction": prediction
}

print (json.dumps(result))
