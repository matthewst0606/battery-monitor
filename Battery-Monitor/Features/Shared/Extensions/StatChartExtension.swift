//
//  StatChartExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import SwiftUI


extension StatChart {
    
    // ------------ Battery charts ------------
    static let batteryLevel = StatChart(
        id: "battery.level",
        fileName: "battery.csv",
        valueColumn: 1,
        yAxisLabel: "Percent",
        yAxisDomain: 0...100,
        color: .secondary,
    )

    static let batteryTimeRemaining = StatChart(
        id: "battery.timeRemaining",
        fileName: "battery.csv",
        valueColumn: 4,
        yAxisLabel: "Hours Remaining",
        yAxisDomain: 0...20,
        color: .secondary,
        valueTransform: { $0 / 60 }
    )

    static let batteryTemperature = StatChart(
        id: "battery.temperature",
        fileName: "battery.csv",
        valueColumn: 8,
        yAxisLabel: "Temperature",
        yAxisDomain: 0...100,
        color: .secondary
    )

    // ------------ CPU charts ------------
    static let cpuTotal = cpuChart(
        id: "cpu.total",
        valueColumn: 1,
        color: .secondary
    )

    static let cpuUser = cpuChart(
        id: "cpu.user",
        valueColumn: 2,
        color: .secondary
    )

    static let cpuSystem = cpuChart(
        id: "cpu.system",
        valueColumn: 3,
        color: .orange
    )

    static let cpuIdle = cpuChart(
        id: "cpu.idle",
        valueColumn: 4,
        color: .green
    )

    // ------------ Memory charts ------------
    static func memoryTotal(maxGB: Double) -> StatChart {
        memoryChart(
            id: "memory.total",
            valueColumn: 1,
            maxGB: maxGB,
            color: .secondary
        )
    }

    static func memoryUsed(maxGB: Double) -> StatChart {
        memoryChart(
            id: "memory.used",
            valueColumn: 2,
            maxGB: maxGB,
            color: .secondary
        )
    }

    static func memoryCached(maxGB: Double) -> StatChart {
        memoryChart(
            id: "memory.cached",
            valueColumn: 3,
            maxGB: maxGB,
            color: .secondary
        )
    }

    static func memoryAvailable(maxGB: Double) -> StatChart {
        memoryChart(
            id: "memory.available",
            valueColumn: 4,
            maxGB: maxGB,
            color: .blue
        )
    }

    private static func cpuChart(
        id: String,
        valueColumn: Int,
        color: Color
    ) -> StatChart {
        StatChart(
            id: id,
            fileName: "cpu.csv",
            valueColumn: valueColumn,
            yAxisLabel: "Percent",
            yAxisDomain: 0...100,
            color: color
        )
    }

    private static func memoryChart(
        id: String,
        valueColumn: Int,
        maxGB: Double,
        color: Color
    ) -> StatChart {
        let domainMax = max(1, ceil(maxGB))

        return StatChart(
            id: id,
            fileName: "memory.csv",
            valueColumn: valueColumn,
            yAxisLabel: "GB",
            yAxisDomain: 0...domainMax,
            color: color
        )
    }
}
