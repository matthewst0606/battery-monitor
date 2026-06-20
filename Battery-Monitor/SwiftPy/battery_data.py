
import psutil
import datetime
import platform
import subprocess

class GetBatteryData:
    def __init__(self):
        self.system_info = {}
        self.battery_dict = {}
        self.process_dict = {}
        self.powermetrics_dict = {}

        self.system_info = self.get_system_info()
        self.battery_dict = self.get_battery_info()
        self.process_dict = self.get_process_info()
        self.powermetrics_dict = self.get_powermetrics_info()


    # a dictionary containing general system info
    # ----------------------------------------------------
    def get_system_info(self):
        memory = psutil.virtual_memory()
        self.system_info['CPU_Usage'] = psutil.cpu_percent()
        self.system_info['Process_Count'] = len(psutil.pids())
        return self.system_info

    # gets battery info from the system and add each
    # item to a dictionary
    # ----------------------------------------------------
    def get_battery_info(self):
        # get output from command
        battery = subprocess.getoutput("system_profiler SPPowerDataType")

        # add each item from the output into the dictionary
        for index in battery.splitlines():
            if ":" in index:
                key, value = index.split(":", 1)
                key, value = key.strip(), value.strip()
                self.battery_dict[key] = value


        battery_condition = self.battery_dict["Condition"]
        cycle_count = self.battery_dict["Cycle Count"]

        # another command (previous doesnt have time remaining)
        battery_info = subprocess.getoutput("pmset -g batt")
        batteryInfo_list = battery_info.split()

        time_remaining = batteryInfo_list[9].replace(":", "")


        # wait for the system to calculate the estimated remaining time
        if time_remaining == "(no": return None

        # return a dictionary
        return {
            "cycle_count": int(cycle_count),
            "battery_condition": battery_condition,
        }

    def get_process_info(self):
        processes = subprocess.getoutput("""
            top -l 2 -s 1 -o power -stats pid,command,state,power |
            awk '
            /^PID[[:space:]]+COMMAND[[:space:]]+STATE[[:space:]]+POWER/ {
                seen++
                if (seen == 2) {
                    print
                    show = 1
                    next
                }
            }
            show && /^[[:space:]]*[0-9]+/ {
                print
                count++
                    if (count == 12) exit
                }'        
        """)

        process_dict = {}
        for index in processes.splitlines():
            if " " in index:
                pid, rest = index.split(" ", 1)
                pid, rest = pid.strip(), rest.strip()

                parts = rest.rsplit(None, 2)
                state = parts[1]
                power = parts[2]


                process_dict[pid] = {
                    "state": state,
                    "power": power
                }
        return process_dict
    

    def get_powermetrics_info(self):
        powermetrics = subprocess.getoutput("" \
            "sudo -n powermetrics --samplers cpu_power,gpu_power,thermal,battery,tasks --show-process-energy -n 1" \
        "")

        powermetrics_dict = {
            "cpu": {},
            "gpu": {},
            "power": {},
            "processes": {}
        }
        currentSection = ""


        for index in powermetrics.splitlines():

            if "*" in index:
                currentSection = index.strip("*")
                currentSection.strip()
                continue

            elif " " in index:
                name,rest = index.split(" ", 1)
                name,rest = name.strip(), rest.strip()
                parts = rest.rsplit(None, len(rest))


                if parts == 0: continue
                else:
                    if index.startswith("CPU"):
                        parts = index.split()
                        core = f"core {parts[1].rstrip(':')}"
                        if core not in powermetrics_dict['cpu']:
                            powermetrics_dict['cpu'][core] = []
                        powermetrics_dict['cpu'][core].append(parts)
                            
                    elif index.startswith("GPU"):
                        parts = index.split()
                        core = f"{parts[1].rstrip(':')}"
                        if core not in powermetrics_dict['gpu']:
                            powermetrics_dict['gpu'][core] = []
                        powermetrics_dict['gpu'][core].append(parts)

                    elif index.startswith("ALL_TASKS"):
                        parts = index.split()
                        task = f"{parts[1].rstrip(':')}"
                        if f"{task}" not in powermetrics_dict['processes']:
                            powermetrics_dict['processes'][f"{task}"] = []

                        powermetrics_dict['processes'][f"{task}"].append(parts)

        return powermetrics_dict
