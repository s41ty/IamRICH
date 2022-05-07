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
                AccountsView(accounts: AccountsModel(sdk: sdk))
                    .environmentObject(sdk)
                    .environmentObject(InstrumentsModel(sdk: sdk))
            } else {
                NewTokenView()
            }
        }
        .onAppear {
        }
        #if os(macOS)
        .frame(minWidth: 1024, idealWidth: 1024, maxWidth: .infinity, minHeight: 768, idealHeight: 768, maxHeight: .infinity, alignment: .center)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}
