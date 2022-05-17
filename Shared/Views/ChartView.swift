//
//  ChartView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 16.05.2022.
//

import SwiftUI
import SwiftUICharts

struct ChartView: View {
    
    @State var data : MultiLineChartData
            
    var body: some View {
        VStack {
            MultiLineChart(chartData: data)
                .id(data.id)
                .padding(.horizontal)
        }
    }
}
