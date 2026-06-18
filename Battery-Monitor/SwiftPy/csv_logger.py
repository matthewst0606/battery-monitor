import pandas as pd
# returns the data from system_info.csv and adds a new row
# if the device is on battery power
# -------------------------------------------------
def insert_row(system_info, process_df, cpu_usage, gpu_df, battery_info, encoded_battery_info):
    # read current data from system_info.csv
    battery_df = pd.read_csv("data/system_info.csv")
    
    cpu_df = pd.read_csv("../Services/Data/cpu.csv")
    memory_df = pd.read_csv("../Services/Data/memory.csv")
    

    # create a new row when new data is collected
    new_row = {
        "Battery_Percent": battery_info["battery_percent"],
        "Time_Remaining": battery_info["time_remaining"],

        "Battery_Condition": battery_info["battery_condition"],
        "Maximum_Capacity": battery_info["maximum_capacity"],
        
        "Cycle_Count": battery_info["cycle_count"],
        "Charging": encoded_battery_info["charging"],
        "Low_Power_Mode": encoded_battery_info["low_power_mode"],

        "Process_Count": system_info["Process_Count"],
        "Process_Power": round(process_df["POWER"].sum(), 2),
        "Process_State": process_df["STATE"].sum(),


        # new CPU cols
        "CPU_Usage": cpu_df[" cpuTotal"].iloc[-1],
        "CPU_User": cpu_df[" cpuUser"].iloc[-1],
        "CPU_System": cpu_df[" cpuSystem"].iloc[-1],
        "CPU_Idle": cpu_df[" cpuIdle"].iloc[-1],
        
        # new memory cols
        "Total_Memory": memory_df[" totalGB"].iloc[-1],
        "Used_Memory": memory_df[" usedGB"].iloc[-1],
        "Cached_Memory": memory_df[" cachedGB"].iloc[-1],
        "Available_Memory": memory_df[" availableGB"].iloc[-1],
        
        
        # old CPU cols
        "old_CPU_Power": cpu_usage["cpu_power"].iloc[-1],
        "old_CPU_Frequency": cpu_usage["active_frequency"].iloc[-1],
        "old_CPU_Residency": cpu_usage["active_residency"].iloc[-1],
        "old_CPU_idle": cpu_usage["idle_residency"].iloc[-1],

        "GPU_Power": gpu_df["gpu_power"].iloc[0],
        "Avg_GPU_Frequency": gpu_df["active_frequency"].iloc[0],
        "Avg_GPU_Residency": gpu_df["active_residency"].iloc[0],
        "Avg_GPU_idle": gpu_df["idle_residency"].iloc[0],
    }
        
    # adds the new row to the system_info.csv file
    battery_df = pd.concat([battery_df, pd.DataFrame([new_row])], ignore_index=True)
    battery_df.to_csv("data/system_info.csv", index=False)

    return battery_df


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
        process_df.to_csv("data/system_processes.csv", index=False)

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
    powermetrics_df.to_csv("data/cpu_usage.csv", index=False)

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
    powermetrics_df.to_csv("data/gpu_usage.csv", index=False)

    return powermetrics_df
