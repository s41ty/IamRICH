//
//  RoundedButtonStyle.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 29.04.2022.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) var isEnabled
    
    var color: Color = .blue
    
    public func makeBody(configuration: RoundedButtonStyle.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(.blue)
            .opacity(isEnabled ? 1.0 : 0.5)
            .foregroundColor(.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
