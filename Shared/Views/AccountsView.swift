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
    
    @ObservedObject var accounts: AccountsModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @EnvironmentObject var credentials: Credentials
    
    @State private var showingSettings = false
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            VStack {
                if accounts.real.count > 0 || accounts.sandboxes.count > 0 {
                    List {
                        Section(header: Text("Основные счета")) {
                            ForEach(accounts.real) { account in
                                NavigationLink(destination: AccountView(account: AccountModel(sdk: sdk, account: account, isSandbox: false))) {
                                    Text(account.name)
                                }
                            }
                        }
                        Section(header: Text("Песочница")) {
                            ForEach(accounts.sandboxes) { account in
                                NavigationLink(destination: AccountView(account: AccountModel(sdk: sdk, account: account, isSandbox: true))) {
                                    Text(account.id)
                                }.swipeActions {
                                    Button(role: .destructive) { closeAccount(accountId: account.id) } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Брокерские счета")
                    .navigationViewStyle(.automatic)
                    .toolbar {
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                } else {
                    LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
                }
            }
            .onAppear {
                accounts.fetch()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(accounts)
            }
        }
    }
    
    func closeAccount(accountId: String) {
        accounts.closeSandbox(accountId: accountId)
    }
}
