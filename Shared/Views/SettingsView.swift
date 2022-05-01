//
//  SettingsView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 01.05.2022.
//

import SwiftUI

struct SettingsView: View {
    
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
                    Image(systemName: "xmark.circle").imageScale(.large)
                }
            }
            Spacer()
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

