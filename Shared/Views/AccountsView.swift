//
//  AccountsView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 29.04.2022.
//

import SwiftUI
import TinkoffInvestSDK
import SwiftfulLoadingIndicators

struct AccountsView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var accounts: AccountsModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @State private var showingSettings = false
    
    
    // MARK: - Init
    
    init(accounts: AccountsModel) {
        self.accounts = accounts;
    }
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            VStack {
                if accounts.real.count > 0 || accounts.sandboxes.count > 0 {
                    List {
                        Section(header: Text("Основные счета")) {
                            ForEach(accounts.real, id:\.self) { account in
                                NavigationLink(destination: AccountView(account: AccountModel(sdk: sdk, account: account, isSandbox: false), orders: OrdersModel(sdk: sdk, accountId: account.id, isSandbox: false)).environmentObject(accounts)) {
                                    Text(account.name)
                                }
                            }
                        }
                        Section(header: Text("Песочница")) {
                            ForEach(accounts.sandboxes, id:\.self) { account in
                                NavigationLink(destination: AccountView(account: AccountModel(sdk: sdk, account: account, isSandbox: true), orders: OrdersModel(sdk: sdk, accountId: account.id, isSandbox: true)).environmentObject(accounts)) {
                                    Text(account.id)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        accounts.closeSandbox(accountId: account.id)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .navigationTitle("Брокерские счета")
                    .navigationViewStyle(.automatic)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    .refreshable {
                        self.accounts.fetch()
                    }
                } else {
                    LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(accounts)
            }
            #if os(macOS)
            // fix collision between table items and navigation bar
            .padding(1)
            #endif
        }
        .onAppear(perform: {
            accounts.fetch()
        })
    }
}
