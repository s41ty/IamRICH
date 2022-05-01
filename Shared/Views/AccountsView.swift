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
                    .navigationViewStyle(.stack)
                    .toolbar {
                        Button(action: {
                            credentials.deleteToken()
                        }) {
                            Image(systemName: "trash.fill")
                        }
                    }
                } else {
                    LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
                }
            }
            .onAppear {
                data.fetch()
            }
        }
    }
}
