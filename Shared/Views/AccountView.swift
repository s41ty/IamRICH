//
//  AccountView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 01.05.2022.
//

import SwiftUI
import TinkoffInvestSDK

struct AccountView: View {
    
    // MARK: - Properties
    
    @ObservedObject var data: AccountModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    var body: some View {
        VStack {
            Spacer()
            Text("На вашем счету \(data.accountName):")
            Text("\(data.account.totalAmountCurrencies.units) \(data.account.totalAmountCurrencies.currency)")
            Spacer()
            Button("Поднять бабла") {
                print("make me rich")
            }
            .buttonStyle(RoundedButtonStyle())
        }
        .padding()
        
    }
}
