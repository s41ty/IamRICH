//
//  AccountView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 01.05.2022.
//

import SwiftUI
import TinkoffInvestSDK
import SwiftfulLoadingIndicators

struct AccountView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var account: AccountModel
    
    @ObservedObject private var orders: OrdersModel
    
    @EnvironmentObject var accounts: AccountsModel
    
    @EnvironmentObject var instruments: InstrumentsModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @State var selectedTag:Int? = nil
    
    @State var selectedMac = false
    
    
    // MARK: - Init
    
    init(account: AccountModel, orders: OrdersModel) {
        self.account = account
        self.orders = orders
        account.fetch()
        orders.fetch()
    }

    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack {
                if account.totalAmount.count > 0 {
                    List {
                        Section(header: Text("Счёт")) {
                            HStack {
                                Text("Всего средств")
                                Spacer()
                                Text("\(account.totalAmount)")
                                Spacer()
                                    .frame(width: 10)
                            }
                            #if os(macOS)
                            Divider()
                            #endif
                        }
                        Section(header: Text("Состав портфеля")) {
                            ForEach(account.positions, id:\.self) { position in
                                HStack {
                                    if let name = instruments.cached[position.figi] {
                                        Text(name)
                                    } else {
                                        Text(position.figi)
                                            .onAppear() {
                                                instruments.getInstrument(figi: position.figi)
                                            }
                                    }
                                    Spacer()
                                    Text("\(position.quantity)" as String)
                                    Spacer()
                                        .frame(width: 10)
                                }
                                #if os(macOS)
                                Divider()
                                #endif
                            }
                        }
                        Section(header: Text("Активные заявки")) {
                            ForEach(orders.all, id:\.self) { order in
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
                                        .frame(width: 10)
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
                    .navigationTitle(account.accountName)
                    .navigationViewStyle(.automatic)
                    #if os(iOS)
                    .listStyle(SidebarListStyle())
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        if account.isSandbox {
                            Button(action: {
                                account.sandboxPayIn(accountId: account.accountId, rubAmmount: 100000)
                            }) {
                                Image(systemName: "dollarsign.square.fill")
                            }
                        }
                    }
                    .refreshable {
                        account.fetch()
                        orders.fetch()
                    }
                }
                else {
                    LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
                }
            }
            #if os(macOS) || os(tvOS)
            .opacity(selectedMac ? 0 : 1)
            #endif
            VStack {
                Spacer()
                Button("Открыть робота") {
                    #if os(iOS)
                    selectedTag = 1
                    #elseif os(macOS) || os(tvOS)
                    selectedMac = true
                    #endif
                }
                .shadow(radius: 5)
                .buttonStyle(RoundedButtonStyle())
                .frame(maxWidth: 400)
                .background(
                    NavigationLink(
                        destination: RobotView(robot: RobotModel(sdk: sdk, accountId: account.accountId, isSandbox: account.isSandbox), selectedMac: $selectedMac).environmentObject(orders),
                        tag: 1,
                        selection: $selectedTag,
                        label: { EmptyView() }
                    )
                )
            }
            .padding()
            .zIndex(1)
            #if os(macOS) || os(tvOS)
            .opacity(selectedMac ? 0 : 1)
            #endif
            #if os(macOS) || os(tvOS)
            VStack {
                RobotView(robot: RobotModel(sdk: sdk, accountId: account.accountId, isSandbox: account.isSandbox), selectedMac: $selectedMac).environmentObject(orders)
            }
            .zIndex(2)
            .opacity(selectedMac ? 1 : 0)
            #endif
        }
    }
}
