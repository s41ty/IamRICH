//
//  SettingsView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 01.05.2022.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var accounts: AccountsModel
    
    @EnvironmentObject var credentials: Credentials
    
    @Environment(\.dismiss) var dismiss
    
    @State private var deleteToken = false
    
    
    // MARK: - View
    
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
                        .foregroundColor(.gray.opacity(0.7))
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            Spacer()
            Button("Добавить счет в песочнице") {
                accounts.openSandbox()
            }
            .buttonStyle(RoundedButtonStyle(color: .blue))
            .frame(maxWidth: 400)
            Button("Удалить токен") {
                deleteToken = true
                dismiss()
            }
            .buttonStyle(RoundedButtonStyle(color: .red))
            .frame(maxWidth: 400)
        }
        .padding()
        #if os(macOS)
        .frame(width: 400, height: 600)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
        .onDisappear {
            if deleteToken {
                credentials.deleteToken()
            }
        }
    }
}

