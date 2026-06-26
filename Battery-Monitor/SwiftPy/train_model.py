
import joblib
import numpy as np
import pandas as pd
import torch
from model_config import FEATURE_COLUMNS, TARGET_COLUMN
from path_config import MODEL_DIR, DATA_DIR
from sklearn.preprocessing import StandardScaler
from battery_model import BatteryModel

df = pd.read_csv(DATA_DIR / "system_info.csv")
df = df.dropna(subset=FEATURE_COLUMNS + TARGET_COLUMN)
df = df[df["Time_Remaining"] > 0]

# --- initialize scalers ---
def init_scalers():
    x = StandardScaler()
    y = StandardScaler()
    x_scaled = x.fit_transform(df[FEATURE_COLUMNS].values)
    y_scaled = y.fit_transform(df[TARGET_COLUMN].values)
    
    # save scalers to .pkl files
    joblib.dump(x, MODEL_DIR/"x_scaler.pkl")
    joblib.dump(y, MODEL_DIR/"y_scaler.pkl")
    return x, y, x_scaled, y_scaled

x, y, x_scaled, y_scaled = init_scalers()


# --- traning_data = x; target_data = y ---
b_model = BatteryModel()
def init_tensors():
    training_data = torch.tensor(
        x_scaled,
        dtype=torch.float32
    ).to(b_model.device)
    target_data = torch.tensor(
        y_scaled,
        dtype=torch.float32
    ).to(b_model.device)
    
    return training_data, target_data
    
training_data, target_data = init_tensors()


# for a given x (training_data),
# the model tries to predict y (target_data)
# --------------------------------------------------
def init_indices():
    # get, shuffle, and split all indices
    all_idx = np.arange(len(df))  
    np.random.shuffle(all_idx)            
    split = int(len(df) * 0.8)            

    # define training and validation indices
    training_idx = all_idx[0:split]       
    validation_idx = all_idx[split:len(df)] 

    # first 80% of the data for training
    x_train = training_data[training_idx]
    y_train = target_data[training_idx]

    # last 20% of the data for validation
    x_val = training_data[validation_idx]
    y_val = target_data[validation_idx]

    return x_train, y_train, x_val, y_val

x_train, y_train, x_val, y_val = init_indices()

# using the model
# --------------------------------------------------
# running and evaluating the model results on validation data
def use_model():
    b_model.run_model(x_train, y_train)
    actual_y, predicted_y, val_loss = b_model.evaluate_model(
        x_val, y_val, y
    )
    return actual_y, predicted_y, val_loss
    
    


if __name__ == "__main__":
    actual_y, predicted_y, val_loss = use_model()
    b_model.save(MODEL_DIR / "battery_model.pt")

    print(f"Validation Loss: {val_loss.item():.4f}")
