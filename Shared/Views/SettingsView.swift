//
//  SettingsView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 01.05.2022.
//

import SwiftUI
import TinkoffInvestSDK

struct SettingsView: View {
    
    @EnvironmentObject var sdk: TinkoffInvestSDK
    
    @EnvironmentObject var accounts: AccountsModel
    
    @EnvironmentObject var credentials: Credentials
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Настройки")
                    .font(.system(size: 34, weight: .bold, design: .default))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(Color(.systemGray4))
                }
            }
            Spacer()
            Button("Добавить счет в песочнице") {
                print("add sandbox account")
                accounts.openSandbox()
            }
            .buttonStyle(RoundedButtonStyle(color: .blue))
            Button("Удалить токен") {
                print("delete token")
                credentials.deleteToken()
                dismiss()
            }
            .buttonStyle(RoundedButtonStyle(color: .red))
        }
        .padding()
        #if os(macOS)
        .frame(width: 400, height: 600)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}

