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
    
    @EnvironmentObject var instruments: InstrumentsModel
    
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
                    Spacer()
                        .frame(height: 20)
                    RichText("Тикер: \(robot.settings.ticker)")
                    RichText("Последняя цена продажи: \(String(describing: robot.lastPrice))")
                    RichText("Количество на счёте: \(String(describing: robot.portfolioQuantity))")
                    RichText("Средневзвешенная цена: \(String(describing: robot.portfolioPrice))")
                    RichText("Активных заявок (покупка): \(robot.buyOrders.count)")
                    RichText("Активных заявок (продажа): \(robot.sellOrders.count)")
                    Spacer()
                        .frame(height: 20)
                    Text(robot.decisionMessages.suffix(5).joined(separator: "\n"))
                }
                Spacer()
                VStack {
                    ChartView(data: robot.chartData)
                }
                .padding()
                Spacer()
                    #if os(iOS)
                    .frame(height: 100)
                    #elseif os(macOS)
                    .frame(height: 200)
                    #endif
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
                            Image(systemName: "wrench.fill")
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
                if robot.historyOrders.count > 0 && !robot.isActive {
                    List {
                        Section(header: Text("История заявок")) {
                            ForEach(robot.historyOrders, id:\.self) { order in
                                VStack {
                                    Spacer()
                                        .frame(height: 5)
                                    HStack {
                                        if let name = instruments.cached[order.figi] {
                                            Text(name)
                                        } else {
                                            Text(order.figi)
                                                .onAppear() {
                                                    instruments.getInstrument(figi: order.figi)
                                                }
                                        }
                                        Spacer()
                                        Text("\(order.lotsRequested) шт.")
                                    }
                                    Spacer()
                                        .frame(width: 25)
                                    HStack {
                                        Text("\(order.status.stringValue)")
                                        Spacer()
                                        if (order.direction == .buy) {
                                            Text("-\(order.totalOrderAmount)")
                                                .foregroundColor(.red)
                                        } else {
                                            Text("\(order.totalOrderAmount)")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 5)
                                }
                                #if os(macOS)
                                Divider()
                                #endif
                            }
                        }
                        Color(.clear)
                            .frame(height: 30)
                            .listRowBackground(Color.clear)
                    }
                    .refreshable {
                        robot.updateOrders()
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
                    .shadow(radius: 5)
                    .buttonStyle(RoundedButtonStyle())
                    .frame(maxWidth: 400)
                } else {
                    Button("Остановить робота") {
                        robot.stop()
                        robot.updateOrders()
                    }
                    .shadow(radius: 5)
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
