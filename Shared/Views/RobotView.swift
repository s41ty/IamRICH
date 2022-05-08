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
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @ObservedObject private var robot: RobotModel
    
    @State private var showingOrder = false
    
    // MARK: - Init
    
    init(robot: RobotModel) {
        self.robot = robot
        robot.start()
    }
    
    
    // MARK: - View
    
    var body: some View {
        VStack {
            Text("Забатываю деньги для тебя!")
        }
        .toolbar {
            Button(action: {
                showingOrder.toggle()
            }) {
                Image(systemName: "plus.app.fill")
            }
        }
        .sheet(isPresented: $showingOrder) {
            OrderView(orders: robot.orders)
        }
    }
}
