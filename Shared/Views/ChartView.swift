//
//  ChartView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 16.05.2022.
//

import SwiftUI
import SwiftUICharts

struct ChartView: View {
    
    @ObservedObject var data : MultiLineChartData
            
    var body: some View {
        VStack {
            MultiLineChart(chartData: data)
                .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
                .id(data.id)
                .padding(.horizontal)
                .frame(minWidth: 75, idealWidth: 75, maxWidth: 600, minHeight: 150, idealHeight: 150, maxHeight: 300, alignment: .center)
        }
    }
}
