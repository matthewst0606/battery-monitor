import os
import pandas as pd
from pathlib import Path
from path_config import DIR, DATA_DIR


def data_file(file_name):
    preferred = DATA_DIR / file_name
    if preferred.exists(): return preferred

    for candidate in (DIR / "data" / file_name, DIR / file_name):
        if candidate.exists(): return candidate

    raise FileNotFoundError(f"Could not find {file_name}")

def read_data_csv(file_name, allow_empty=False):
    dataframe = pd.read_csv(data_file(file_name), skipinitialspace=True)
    if dataframe.empty and not allow_empty:
        raise ValueError(f"{file_name} does not contain any data rows")
    return dataframe
    

class CSVLogger:
    def __init__(self, process_info, powermetrics_info):
        self.system_df = read_data_csv("system_info.csv", allow_empty=True)
        self.battery_df = read_data_csv("battery.csv")
        self.cpu_df = read_data_csv("cpu.csv")
        self.memory_df = read_data_csv("memory.csv")
        self.process_df = self.process_row(process_info)
        self.gpu_df = self.gpu_row(powermetrics_info)
        self.cpu_usage = self.cpu_row(powermetrics_info)

    # returns the data from system_info.csv and adds a new row
    # if the device is on battery power
    # -------------------------------------------------
    def insert_row(self, system_info):
        # create a new row when new data is collected
        new_row = {
            # battery cols
            "Battery_Percent":   self.battery_df["batteryLevel"].iloc[-1],
            "Time_Remaining":    self.battery_df["timeRemaining"].iloc[-1],
            "Battery_Condition": self.battery_df["batteryCondition"].iloc[-1],
            "Maximum_Capacity":  self.battery_df["batteryHealth"].iloc[-1],
            
            "Process_Count": system_info["Process_Count"],
            "Cycle_Count":       self.battery_df["cycleCount"].iloc[-1],
            "Charging":          self.battery_df["isCharging"].iloc[-1],
            "Low_Power_Mode":    self.battery_df["powerMode"].iloc[-1],

            # process cols
            "Process_Power": round(self.process_df["POWER"].sum(), 2),
            "Process_State": self.process_df["STATE"].sum(),

            # new CPU cols
            "CPU_Usage":  self.cpu_df["cpuTotal"].iloc[-1],
            "CPU_User":   self.cpu_df["cpuUser"].iloc[-1],
            "CPU_System": self.cpu_df["cpuSystem"].iloc[-1],
            "CPU_Idle":   self.cpu_df["cpuIdle"].iloc[-1],
            
            # new memory cols
            "Total_Memory":     self.memory_df["totalGB"].iloc[-1],
            "Used_Memory":      self.memory_df["usedGB"].iloc[-1],
            "Cached_Memory":    self.memory_df["cachedGB"].iloc[-1],
            "Available_Memory": self.memory_df["availableGB"].iloc[-1],
            
            # old CPU cols
            "old_CPU_Power":     self.cpu_usage["cpu_power"].iloc[-1],
            "old_CPU_Frequency": self.cpu_usage["active_frequency"].iloc[-1],
            "old_CPU_Residency": self.cpu_usage["active_residency"].iloc[-1],
            "old_CPU_idle":      self.cpu_usage["idle_residency"].iloc[-1],

            "GPU_Power":         self.gpu_df["gpu_power"].iloc[-1],
            "Avg_GPU_Frequency": self.gpu_df["active_frequency"].iloc[-1],
            "Avg_GPU_Residency": self.gpu_df["active_residency"].iloc[-1],
            "Avg_GPU_idle":      self.gpu_df["idle_residency"].iloc[-1],
        }
            
        # adds the new row to the system_info.csv file
        new_df_row = pd.DataFrame([new_row], columns=self.system_df.columns)
        new_df_row.to_csv(
            data_file("system_info.csv"),
            mode="a",
            header=False,
            index=False
        )

        return pd.concat([self.system_df, new_df_row], ignore_index=True)


    # creates the data in data/system_processes
    def process_row(self, process_info):
        rows = []

        for pid, info in process_info.items():
            if pid == "PID": continue
            new_row = {
                "POWER": float(info["power"]),
                "STATE": 1 if info["state"] == "running" else 0
            }
            rows.append(new_row)

        if not rows:
            rows.append({
                "POWER": 0.0,
                "STATE": 0
            })

        process_df = pd.DataFrame(rows)
        process_df.to_csv(data_file("system_processes.csv"), index=False)

        return process_df



    # creates the data in data/cpu_usage
    def cpu_row(self, powermetrics_info):
        rows = []
        if "core Power" not in powermetrics_info["cpu"]:
            return read_data_csv("cpu_usage.csv")

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
    def gpu_row(self, powermetrics_info):
        rows = []
        if "Power" not in powermetrics_info["gpu"]:
            return read_data_csv("gpu_usage.csv")

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
