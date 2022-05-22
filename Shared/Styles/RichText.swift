//
//  RichText.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 21.05.2022.
//

import SwiftUI

struct RichText: View {
    
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        #if os(iOS)
        Text(text)
            .font(.title3)
            .fontWeight(.medium)
        #elseif os(macOS)
        Text(text)
            .font(.title2)
            .fontWeight(.medium)
        #elseif os(tvOS)
        Text(text)
            .font(.subheadline)
            .fontWeight(.medium)
        #endif
    }
}
