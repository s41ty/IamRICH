//
//  NewTokenView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 29.04.2022.
//

import SwiftUI

struct NewTokenView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var credentials: Credentials

    
    // MARK: - States
    
    @State private var newToken: String = ""
    
    
    // MARK: - View
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Please add access token here", text: $newToken)
                .lineLimit(8)
            Divider().frame(height: 2, alignment: .center)
            Spacer()
            Link("Get token", destination: URL(string: "https://www.tinkoff.ru/invest/settings/")!)
                .font(.system(size: 12))
            Spacer()
                .frame(height: 20)
            Button("Save token") {
                credentials.saveToken(newToken)
            }
            .buttonStyle(RoundedButtonStyle())
            .disabled(newToken.count < 1)
        }
        .padding()
    }
}
