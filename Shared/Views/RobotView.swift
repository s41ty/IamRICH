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
    
    @State private var showingSettings = false
    
    
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
                    Text("Тикер: \(robot.settings.ticker)")
                    Text("Последняя цена продажи: \(String(describing: robot.lastPrice))")
                    Text("Количество на счёте: \(String(describing: robot.portfolioQuantity))")
                    Text("Средневзвешенная цена: \(String(describing: robot.portfolioPrice))")
                    Text("Активных заявок (покупка): \(robot.buyOrders.count)")
                    Text("Активных заявок (продажа): \(robot.sellOrders.count)")
                }
                Spacer()
                VStack {
                    ChartView(data: robot.chartData)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Робот")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                        Button(action: {
                            showingOrder.toggle()
                        }) {
                            Image(systemName: "plus.app.fill")
                        }
                    }
                }
            }
            .zIndex(3)
            .opacity(robot.isActive ? 1 : 0)
            VStack {
                if robot.historyOrders.count > 0 {
                    List {
                        Section(header: Text("История заявок")) {
                            ForEach(robot.historyOrders, id:\.self) { order in
                                Text(order.orderId)
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("Результаты робота.\n\nЗдесь будут отображаться заявки созданные роботом.")
                        .padding()
                    Spacer()
                }
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
        .sheet(isPresented: $showingSettings) {
            RobotSetupView()
                .environmentObject(robot)
        }
        .onDisappear {
            robot.stop()
        }
    }
}
