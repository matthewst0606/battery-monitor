//
//  ProcessService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/23/26.
//
import Combine
import Foundation


class ProcessService: ObservableObject {
    @Published var info: RunningProcess?
    @Published var processes: [RunningProcess] = []

    private let timerService = TimerService()
    
    init() {
        fetchProcesses()
        
        timerService.createTimer {
            self.fetchProcesses()
        }
    }
    
    
    
    private static func runShellCommand(_ command: String) -> String {
        
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
    
    
    
    
    private static func runTopProcessesCommand() -> String {
        let command = """
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
        """
        
        let result = runShellCommand(command)
        return result
    }
    


    
    private static func parseLine(_ line: String) -> RunningProcess? {
        let parts = line.split(separator: " ", omittingEmptySubsequences: true)
        guard parts.count >= 4,
              let pid = Int(parts[0]) else { return nil }
        
        
        return RunningProcess(
            pid: String(pid),
            command: String(parts[1]),
            state: String(parts[2]),
            power: String(parts[3])
        )
    }

    private static func fetchProcessesRaw() -> [RunningProcess] {
        let raw = runTopProcessesCommand()
        return raw.components(separatedBy: "\n").compactMap { parseLine($0) }
    }
    
    
    func fetchProcesses() {
        DispatchQueue.global(qos: .background).async {
            let newProcesses = Self.fetchProcessesRaw()

            DispatchQueue.main.async {
                self.processes = newProcesses
            }
        }
    }

}
