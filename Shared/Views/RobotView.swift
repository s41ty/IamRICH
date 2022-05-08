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
        robot.start()
    }
    
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    Section(header: Text("Логи")) {
                        ForEach(robot.logs, id:\.self) { log in
                            NavigationLink(destination: Text(log)) {
                                Text(log)
                            }
                        }
                    }
                }
                .navigationTitle("Робот")
                .navigationViewStyle(.automatic)
                #if os(iOS)
                .listStyle(SidebarListStyle())
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    Button(action: {
                        showingOrder.toggle()
                    }) {
                        Image(systemName: "plus.app.fill")
                    }
                }
            }
            VStack {
                Spacer()
                Button("Остановить робота") {
                    #if os(iOS)
                    robot.stop()
                    self.mode.wrappedValue.dismiss()
                    #elseif os(macOS)
                    robot.stop()
                    selectedMac.toggle()
                    #endif
                }
                .buttonStyle(RoundedButtonStyle(color: .red))
                .frame(maxWidth: 400)
            }
            .padding()
            .zIndex(1)
        }
        .sheet(isPresented: $showingOrder) {
            OrderView(orders: robot.orders)
        }
    }
}
