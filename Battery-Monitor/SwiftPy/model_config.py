# battery_config.py

FEATURE_COLUMNS = [
    "Battery_Percent",
    "Maximum_Capacity",
    "Process_Count",
    "Cycle_Count",
    "Charging",
    "Low_Power_Mode",
    "Process_Power",
    "Process_State",
    "CPU_Usage",
    "CPU_User",
    "CPU_System",
    "CPU_Idle",
    "Total_Memory",
    "Used_Memory",
    "Cached_Memory",
    "Available_Memory",
    "old_CPU_Power",
    "old_CPU_Frequency",
    "old_CPU_Residency",
    "old_CPU_idle",
    "GPU_Power",
    "Avg_GPU_Frequency",
    "Avg_GPU_Residency",
    "Avg_GPU_idle"
]
TARGET_COLUMN = ["Time_Remaining"] # (in minutes)