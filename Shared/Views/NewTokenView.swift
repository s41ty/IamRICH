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
            TextField("Пожалуйста добавьте ваш токен здесь", text: $newToken)
                .lineLimit(8)
            Divider().frame(height: 2, alignment: .center)
            Spacer()
            #if !os(tvOS)
            Link("Как получить токен?", destination: URL(string: "https://www.tinkoff.ru/invest/settings/")!)
                .font(.system(size: 12))
            #endif
            Spacer()
                .frame(height: 20)
            Button("Сохранить токен") {
                credentials.saveToken(newToken)
            }
            .shadow(radius: 5)
            .buttonStyle(RoundedButtonStyle())
            .frame(maxWidth: 400)
            .disabled(newToken.count < 1)
        }
        .padding()
    }
}
