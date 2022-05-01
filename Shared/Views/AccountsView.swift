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
    
    @ObservedObject var data: AccountsModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @EnvironmentObject var credentials: Credentials
    
    @State private var showingSettings = false
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            VStack {
                if data.accounts.count > 0 {
                    List {
                        Section(header: Text("Основные счета")) {
                            ForEach(data.accounts) { account in
                                NavigationLink(destination: AccountView(data: AccountModel(sdk: sdk, account: account))) {
                                    Text(account.name)
                                }
                            }
                        }
                        Section(header: Text("Песочница")) {
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
                data.fetch()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}
