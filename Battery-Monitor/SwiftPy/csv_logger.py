import os
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
CONFIGURED_DATA_DIR = os.environ.get("BATTERY_MONITOR_DATA_DIR")

if CONFIGURED_DATA_DIR: DATA_DIR = Path(CONFIGURED_DATA_DIR).expanduser()
else: DATA_DIR = BASE_DIR / "data" if (BASE_DIR / "data").is_dir() else BASE_DIR

DATA_DIR.mkdir(parents=True, exist_ok=True)

def data_file(file_name):
    preferred = DATA_DIR / file_name
    if preferred.exists(): return preferred

    for candidate in (BASE_DIR / "data" / file_name, BASE_DIR / file_name):
        if candidate.exists(): return candidate

    raise FileNotFoundError(f"Could not find {file_name}")

def read_data_csv(file_name):
    dataframe = pd.read_csv(data_file(file_name), skipinitialspace=True)
    if dataframe.empty:
        raise ValueError(f"{file_name} does not contain any data rows")
    return dataframe

# returns the data from system_info.csv and adds a new row
# if the device is on battery power
# -------------------------------------------------
def insert_row(system_info, process_df, cpu_usage, gpu_df):
    # read current data from system_info.csv
    system_df = read_data_csv("system_info.csv")
    battery_df = read_data_csv("battery.csv")
    
    
    cpu_df = read_data_csv("cpu.csv")
    memory_df = read_data_csv("memory.csv")
    
    # create a new row when new data is collected
    new_row = {
        "Battery_Percent": battery_df["batteryLevel"].iloc[-1],
        "Time_Remaining": battery_df["timeRemaining"].iloc[-1],
        "Battery_Condition": battery_df["batteryCondition"].iloc[-1],
        "Maximum_Capacity": battery_df["batteryHealth"].iloc[-1],
        "Cycle_Count": battery_df["cycleCount"].iloc[-1],
        "Charging": battery_df["isCharging"].iloc[-1],
        "Low_Power_Mode": battery_df["powerMode"].iloc[-1],

        "Process_Count": system_info["Process_Count"],
        "Process_Power": round(process_df["POWER"].sum(), 2),
        "Process_State": process_df["STATE"].sum(),


        # new CPU cols
        "CPU_Usage": cpu_df["cpuTotal"].iloc[-1],
        "CPU_User": cpu_df["cpuUser"].iloc[-1],
        "CPU_System": cpu_df["cpuSystem"].iloc[-1],
        "CPU_Idle": cpu_df["cpuIdle"].iloc[-1],
        
        # new memory cols
        "Total_Memory": memory_df["totalGB"].iloc[-1],
        "Used_Memory": memory_df["usedGB"].iloc[-1],
        "Cached_Memory": memory_df["cachedGB"].iloc[-1],
        "Available_Memory": memory_df["availableGB"].iloc[-1],
        
        
        # old CPU cols
        "old_CPU_Power": cpu_usage["cpu_power"].iloc[-1],
        "old_CPU_Frequency": cpu_usage["active_frequency"].iloc[-1],
        "old_CPU_Residency": cpu_usage["active_residency"].iloc[-1],
        "old_CPU_idle": cpu_usage["idle_residency"].iloc[-1],

        "GPU_Power": gpu_df["gpu_power"].iloc[-1],
        "Avg_GPU_Frequency": gpu_df["active_frequency"].iloc[-1],
        "Avg_GPU_Residency": gpu_df["active_residency"].iloc[-1],
        "Avg_GPU_idle": gpu_df["idle_residency"].iloc[-1],
    }
        
    # adds the new row to the system_info.csv file
    new_df_row = pd.DataFrame([new_row])
    pd.DataFrame([new_row]).to_csv(
        data_file("system_info.csv"),
        mode="a",
        header=False,
        index=False
    )

    return pd.concat([system_df, new_df_row], ignore_index=True)







# creates the data in data/system_processes
def process_row(process_info):
    rows = []

    for pid, info in process_info.items():
        if pid == "PID": continue
        new_row = {
            "POWER": float(info["power"]),
            "STATE": 1 if info["state"] == "running" else 0
        }
        rows.append(new_row)

        process_df = pd.DataFrame(rows)
        process_df.to_csv(data_file("system_processes.csv"), index=False)

    return process_df








# creates the data in data/cpu_usage
def cpu_row(powermetrics_info):
    rows = []
    cpu_power = float(powermetrics_info["cpu"]["core Power"][0][2])

    for name, info in powermetrics_info['cpu'].items():
        if name == "core Power": continue
        new_row = {
            'core': int(info[0][1]),
            'active_frequency': float(info[0][3]),
            'active_residency': float(info[1][4].strip('%')),
            'idle_residency': float(info[2][4].strip('%')),
            'cpu_power': cpu_power
        }
        rows.append(new_row)

    powermetrics_df = pd.DataFrame(rows)
    powermetrics_df.to_csv(data_file("cpu_usage.csv"), index=False)

    return powermetrics_df

# creates the data in data/gpu_usage
def gpu_row(powermetrics_info):
    rows = []
    gpu_power =  powermetrics_info['gpu']['Power'][0][2]
    active_frequency =  powermetrics_info['gpu']['HW'][0][4]
    active_residency = powermetrics_info['gpu']['HW'][1][4]
    idle_residency = powermetrics_info['gpu']['idle'][0][3]

    new_row = {
        "gpu_power": float(gpu_power),
        "active_frequency": float(active_frequency),
        "active_residency": float(active_residency.strip('%')),
        "idle_residency": float(idle_residency.strip('%'))
    }
    rows.append(new_row)

    powermetrics_df = pd.DataFrame(rows)
    powermetrics_df.to_csv(data_file("gpu_usage.csv"), index=False)

    return powermetrics_df
