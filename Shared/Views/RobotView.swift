//
//  RobotView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 04.05.2022.
//

import SwiftUI
import TinkoffInvestSDK


struct RobotView: View {
    
    // MARK: - Properties
    
    @Binding var selectedMac: Bool
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @ObservedObject private var robot: RobotModel
    
    @State private var showingOrder = false
    
    
    // MARK: - Init
    
    init(robot: RobotModel,selectedMac: Binding<Bool>) {
        self.robot = robot
        _selectedMac = selectedMac
    }
    
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack {
                Group {
                    Text("Тикер: \(robot.instrumentTicker)")
                    Text("Последняя цена продажи: \(String(describing: robot.lastPrice))")
                    Text("Количество на брокерском счёте: \(String(describing: robot.portfolioQuantity))")
                    Text("Средняя цена на брокерском счёте: \(String(describing: robot.portfolioPrice))")
                    Text("Количество заявок купить: \(robot.buyQuantity)")
                    Text("Количество заявок продать: \(robot.sellQuantity)")
                }
                Spacer()
                    .frame(height: 150)
                VStack {
                    ChartView(data: robot.lastChartData)
                        .frame(minHeight: 0, maxHeight: 100)
                    Spacer()
                        .frame(height: 100)
                    HStack {
                        Text("MACD")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                        Text("Signal")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                .padding()
                Spacer()
                    .frame(height: 100)
            }
            .navigationTitle("Робот")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                Button(action: {
                    showingOrder.toggle()
                }) {
                    Image(systemName: "plus.app.fill")
                }
            }
            .zIndex(3)
            .opacity(robot.isActive ? 1 : 0)
            VStack {
                Spacer()
                Text("Результаты робота")
                Spacer()
            }
            .zIndex(4)
            .opacity(robot.isActive ? 0 : 1)
            VStack {
                Spacer()
                if !robot.isActive {
                    Button("Запустить робота") {
                        robot.start()
                    }
                    .buttonStyle(RoundedButtonStyle())
                    .frame(maxWidth: 400)
                } else {
                    Button("Остановить робота") {
                        robot.stop()
                    }
                    .buttonStyle(RoundedButtonStyle(color: .red))
                    .frame(maxWidth: 400)
                }
            }
            .padding()
            .zIndex(5)
        }
        .sheet(isPresented: $showingOrder) {
            OrderView()
        }
        .onDisappear {
            robot.stop()
        }
    }
}
