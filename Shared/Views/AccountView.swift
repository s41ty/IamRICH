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
            } else {
                LoadingIndicator(animation: .threeBalls, color: .blue, size: .medium)
            }
            
        }
        .padding()
        .onAppear {
            account.fetch()
        }
    }
}
