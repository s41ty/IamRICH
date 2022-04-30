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
    
    @ObservedObject var model: AccountModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    var body: some View {
        VStack {
            Spacer()
            Text("На вашем счету \(model.accountName):")
            Text("\(model.account.totalAmountCurrencies.units) \(model.account.totalAmountCurrencies.currency)")
            Spacer()
            Button("Поднять бабла") {
                print("make me rich")
            }
            .buttonStyle(RoundedButtonStyle())
        }
        .padding()
        
    }
}
