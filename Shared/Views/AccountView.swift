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
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @State var selectedTag:Int? = nil
    
    @State var selectedMac = false
    
    
    // MARK: - Init
    
    init(account: AccountModel) {
        self.account = account;
        self.account.fetch()
    }
    
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack {
                if selectedMac {
                    RobotView(robot: RobotModel(sdk: sdk, accountId: account.accountId, isSandbox: account.isSandbox))
                }
                else if account.totalAmount.count > 0 {
                    List {
                        Section(header: Text("Счёт")) {
                            NavigationLink(destination:Text("Всего средств: \(account.totalAmount)")) {
                                Text("Всего средств: \(account.totalAmount)")
                            }
                        }
                        Section(header: Text("Позиции")) {
                            ForEach(account.positions) { position in
                                NavigationLink(destination:Text(position.figi)) {
                                    Text(position.figi)
                                }
                            }
                        }
                        Color(.clear)
                            .frame(height: 30)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(SidebarListStyle())
                    .navigationTitle(account.accountName)
                    .navigationViewStyle(.automatic)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        if account.isSandbox {
                            Button(action: {
                                print("add money")
                                account.sandboxPayIn(accountId: account.accountId, rubAmmount: 100000)
                            }) {
                                Text("Пополнить")
                            }
                        }
                    }
                    .refreshable {
                        account.fetch()
                    }
                } else {
                    LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
                }
            }
            VStack {
                Spacer()
                Button("Поднять бабла") {
                    print("make me rich")
                    #if os(iOS)
                    selectedTag = 1
                    #elseif os(macOS)
                    selectedMac = true
                    #endif
                }
                .buttonStyle(RoundedButtonStyle())
                .frame(maxWidth: 400)
                .background(
                    NavigationLink(
                        destination: RobotView(robot: RobotModel(sdk: sdk, accountId: account.accountId, isSandbox: account.isSandbox)),
                        tag: 1,
                        selection: $selectedTag,
                        label: { EmptyView() }
                    )
                )
            }
            .padding()
            .zIndex(1)
        }
    }
}
