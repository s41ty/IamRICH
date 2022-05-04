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
    
    @ObservedObject var account: AccountModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    var body: some View {
        VStack {
            if account.hasTotalAmountCurrencies {
                Spacer()
                Text("На вашем счету \(account.accountName):")
                Text("\(account.totalAmountCurrencies.units) \(account.totalAmountCurrencies.currency)")
                Spacer()
                Button("Поднять бабла") {
                    print("make me rich")
                }
                .buttonStyle(RoundedButtonStyle())
                .frame(maxWidth: 400)
            } else {
                LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
            }
        }
        .navigationTitle(account.accountName.count > 0 ? account.accountName : account.accountId)
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
        .padding()
        .onAppear {
            account.fetch()
        }
    }
}
