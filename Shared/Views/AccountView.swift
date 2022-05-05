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
    
    
    // MARK: - Init
    
    init(account: AccountModel) {
        self.account = account;
        self.account.fetch()
    }
    
    
    // MARK: - View
    
    var body: some View {
        VStack {
            if account.totalAmount.count > 0 {
                Spacer()
                Text("На вашем счету \(account.accountName):")
                Text("\(account.totalAmount)")
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
        .navigationTitle(account.accountName)
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
    }
}
