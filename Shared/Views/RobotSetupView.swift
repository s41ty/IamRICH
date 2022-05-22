//
//  OrderView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 04.05.2022.
//

import SwiftUI
import Combine

struct RobotSetupView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var robot: RobotModel

    @Environment(\.dismiss) var dismiss
    
    @State var figi: String = "BBG333333333"
    
    @State var ticker: String = "TMOS"
    
    @State var limit: Decimal = 700

    
    // MARK: - View
    
    var body: some View {
        VStack {
            HStack {
                Text("Настройки робота")
                    .font(.system(size: 34, weight: .bold, design: .default))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.gray.opacity(0.7))
                }
                #if !os(tvOS)
                .buttonStyle(BorderlessButtonStyle())
                #endif
            }
            Spacer()
                .frame(height: 30)
            Group {
                HStack {
                    Text("Идентификатора инструмента - figi")
                    Spacer()
                }
                TextField("Идентификатора инструмента - figi", text: $figi)
                    .frame(height: 40)
                    #if !os(tvOS)
                    .textFieldStyle(.roundedBorder)
                    #endif
            }
            Spacer()
                .frame(height: 30)
            Group {
                HStack {
                    Text("Идентификатора инструмента - ticker")
                    Spacer()
                }
                TextField("Идентификатора инструмента - ticker", text: $ticker)
                .frame(height: 40)
                #if !os(tvOS)
                .textFieldStyle(.roundedBorder)
                #endif
                #if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                #endif
            }
            Spacer()
                .frame(height: 30)
            Group {
                HStack {
                    Text("Лимит по инструменту")
                    Spacer()
                }
                TextField("Лимит по инструменту", text: Binding(
                    get: { "\(limit)" },
                    set: { limit = Decimal(string: $0) ?? 0 }
                ))
                .frame(height: 40)
                #if !os(tvOS)
                .textFieldStyle(.roundedBorder)
                #endif
                #if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                #endif
            }
            Spacer()
            #if os(iOS)
            .keyboardType(.numbersAndPunctuation)
            #endif
            Spacer()
            Button("Сохранить") {
                let settings = RobotSettings(figi: figi, ticker: ticker, limit: limit)
                robot.updateSettings(newSettings: settings)
                dismiss()
            }
            .shadow(radius: 5)
            .buttonStyle(RoundedButtonStyle())
            .frame(maxWidth: 400)
        }
        .padding()
        #if os(macOS)
        .frame(width: 400, height: 600)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}
