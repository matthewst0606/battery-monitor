//
//  ChartMetricRow.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI
import Charts
import Combine

struct MetricRow: Identifiable {
    let id: String
    let title: String
    let value: String
    let color: Color
    let chart: StatChart?
    let visibilityKey: String?

    init(
        id: String? = nil,
        title: String,
        value: String,
        color: Color = .primary,
        chart: StatChart? = nil,
        visibilityKey: String? = nil
    ) {
        self.id = id ?? title
        self.title = title
        self.value = value
        self.color = color
        self.chart = chart
        self.visibilityKey = visibilityKey
    }

    var isVisible: Bool {
        guard let visibilityKey else { return true }
        return UserDefaults.standard.object(forKey: visibilityKey) as? Bool ?? true
    }
}

struct MetricChart {
    var selectedChart: Binding<StatChart?>
    var chartPoints: Binding<[MetricChartPoint]>

    func row(title: String, value: String, color: Color, chart: StatChart) -> some View {
        ChartableMetricRow(
            title: title,
            value: value,
            color: color,
            chart: chart,
            selectedChart: selectedChart,
            chartPoints: chartPoints
        )
    }

    @ViewBuilder
    func row(_ metric: MetricRow) -> some View {
        if metric.isVisible {
            if let chart = metric.chart {
                ChartableMetricRow(
                    title: metric.title,
                    value: metric.value,
                    color: metric.color,
                    chart: chart,
                    selectedChart: selectedChart,
                    chartPoints: chartPoints
                )
            }
            else {
                ListItem(
                    title: metric.title,
                    value: metric.value,
                    color: metric.color
                )
            }
        }
    }
}


// A row that can expand to show its chart.
// e.g. battery level, cpu usage, etc.
struct ChartableMetricRow: View {
    let title: String
    let value: String
    let color: Color
    let chart: StatChart

    @Binding var selectedChart: StatChart?
    @Binding var chartPoints: [MetricChartPoint]

    var body: some View {
        Button { toggleChart() }
        label: {
            HStack {
                Text(title)
                Spacer()
                Text(value).standard().foregroundStyle(color)
            }
            .standardPadding()

        }
        .buttonStyle(.accessoryBar)
        .listRowSeparatorTint(.primary.opacity(0.2))
        .listRowBackground(Color.clear)


        
        if selectedChart == chart { chartView }
    }

    // displays the chart
    private var chartView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Chart(chartPoints) { point in
                
                AreaMark( // the visible shading under the chart
                    x: .value("Time", point.time),
                    y: .value(chart.yAxisLabel, chart.chartValue(point.val))
                )
                .foregroundStyle(chart.color.opacity(0.25))
                
                
                LineMark( // the visible line on the chart
                    x: .value("Time", point.time),
                    y: .value(chart.yAxisLabel, chart.chartValue(point.val))
                )
                .foregroundStyle(chart.color)
            }
            .frame(height: 160)
            .chartYScale(domain: chart.yAxisDomain)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
        }
    }

    
    
    // hides the chart if the same one is selected twice
    // else display the new selected chart
    private func toggleChart() {
        if selectedChart == chart { selectedChart = nil }
        else {
            selectedChart = chart
            chartPoints = loadChart(
                chart.fileName,
                columnIndex: chart.valueColumn
            )
        }
    }
}



struct ChartMetricScope<Content: View>: View {
    @State private var selectedChart: StatChart? = nil
    @State private var chartPoints: [MetricChartPoint] = []
    let refresh: AnyPublisher<Void, Never>
    
    @ViewBuilder var content: (MetricChart) -> Content
    var body: some View {
        content(
            MetricChart(
                selectedChart: $selectedChart,
                chartPoints: $chartPoints
            )
        )
        .onAppear {
            reloadSelectedChart()
        }
        .onReceive(refresh) { _ in
            reloadSelectedChart()
        }
    }

    private func reloadSelectedChart() {
        guard let selectedChart else { return }

        chartPoints = loadChart(
            selectedChart.fileName,
            columnIndex: selectedChart.valueColumn
        )
    }
}
