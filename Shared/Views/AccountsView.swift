//
//  AccountsView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 29.04.2022.
//

import SwiftUI
import TinkoffInvestSDK

struct AccountsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var model: AccountsModel
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @EnvironmentObject var credentials: Credentials
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.accounts) { account in
                    NavigationLink(destination: Text(account.name)) {
                        Text(account.name)
                    }
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                Button(action: {
                    credentials.deleteToken()
                }) {
                    Image(systemName: "trash.fill")
                }
            }
        }
    }
}