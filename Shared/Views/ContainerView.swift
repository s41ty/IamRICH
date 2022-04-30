//
//  ContainerView.swift
//  Shared
//
//  Created by Sergey Yuryev on 27.04.2022.
//

import Combine
import SwiftUI
import TinkoffInvestSDK

struct ContainerView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var credentials: Credentials
    
    
    // MARK: - View
    
    var body: some View {
        VStack {
            if let token = credentials.accessToken {
                let config = TinkoffInvestConfig(token: token, appName: "s41ty")
                let sdk = TinkoffInvestSDK(config: config)
                AccountsView(data: AccountsModel(sdk: sdk))
                    .environmentObject(sdk)
            }
            else {
                NewTokenView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
