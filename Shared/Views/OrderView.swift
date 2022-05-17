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
    
    @State var price: Decimal = 7

    
    // MARK: - View
    
    var body: some View {
        VStack {
            HStack {
                Text("Купить|продать")
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
            TextField("Идентификатора инструмента", text: $figi)
            TextField("Количество", text: Binding(
                get: { String(quantity) },
                set: { quantity = Int64($0) ?? 0 }
            ))
                #if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                #endif
            
            TextField("Цена", text: Binding(
                get: { "\(price)" },
                set: { price = Decimal(string: $0) ?? 0 }
            ))
                #if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                #endif
            Spacer()
            Button("Купить") {
                print("buy \(figi) \(quantity) \(price)")
                orders.add(figi: figi, quantity: quantity, price: price, direction: .buy)
            }
            .buttonStyle(RoundedButtonStyle())
            .frame(maxWidth: 400)
            Button("Продать") {
                print("sell \(figi) \(quantity) \(price)")
                orders.add(figi: figi, quantity: quantity, price: price, direction: .sell)
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
    }
}
