//
//  OrderView.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 04.05.2022.
//

import SwiftUI
import Combine

struct OrderView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var orders: OrdersModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var figi: String = "BBG333333333"
    
    @State var quantity: Int64 = 1
    
    @State var price: Decimal = 4.5

    
    // MARK: - View
    
    var body: some View {
        VStack {
            HStack {
                Text("Заявка")
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
                    Text("Количество")
                    Spacer()
                }
                TextField("Количество", text: Binding(
                    get: { String(quantity) },
                    set: { quantity = Int64($0) ?? 0 }
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
                .frame(height: 30)
            Group {
                HStack {
                    Text("Цена")
                    Spacer()
                }
                TextField("Цена", text: Binding(
                    get: { "\(price)" },
                    set: { price = Decimal(string: $0) ?? 0 }
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
            Button("Купить") {
                print("buy \(figi) \(quantity) \(price)")
                orders.add(figi: figi, quantity: quantity, price: price, direction: .buy)
                dismiss()
            }
            .shadow(radius: 5)
            .buttonStyle(RoundedButtonStyle())
            .frame(maxWidth: 400)
            Button("Продать") {
                print("sell \(figi) \(quantity) \(price)")
                orders.add(figi: figi, quantity: quantity, price: price, direction: .sell)
                dismiss()
            }
            .shadow(radius: 5)
            .buttonStyle(RoundedButtonStyle(color: .red))
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
