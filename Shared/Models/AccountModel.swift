//
//  AccountsModel.swift
//  
//
//  Created by Sergey Yuryev on 30.04.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public struct AccountPosition {
    var figi: String
    var type: String
    var quantity: Decimal
    var value: String
}

extension AccountPosition: Identifiable {
    public var id: String { figi }
}

public class AccountModel: ObservableObject {

    // MARK: - Properties
    
    @Published public var totalAmount = ""
    
    @Published public var positions = [AccountPosition]()
    
    @Published public var hasTotalAmountCurrencies: Bool
    
    @Published public var isSandbox: Bool
    
    @Published public var accountName: String
    
    @Published public var accountId: String
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, account: Tinkoff_Public_Invest_Api_Contract_V1_Account, isSandbox: Bool = false) {
        self.sdk = sdk
        self.hasTotalAmountCurrencies = false
        self.isSandbox = isSandbox
        self.accountId = account.id
        if account.name.count < 1 {
            self.accountName = String(account.id.split(separator: "-").first ?? "")
        } else {
            self.accountName = account.name
        }
    }

    public func fetch() {
        if isSandbox {
            sdk.sandboxService.getSandboxPortfolio(accountID: accountId)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    case .finished:
                        print("did finish loading getSandboxPortfolio")
                    }
                } receiveValue: { [weak self] response in
                    print(response)
                    self?.totalAmount = response.totalAmountCurrencies.asString
                    self?.positions.removeAll()
                    self?.positions.append(contentsOf: response.positions.map { position in
                        return AccountPosition(figi: position.figi, type: position.instrumentType, quantity: position.quantity.asDecimal, value: position.averagePositionPrice.asString)
                    })
                }
                .store(in: &cancellableSet)
        } else {
            sdk.operationsService.getPortfolio(accountID: accountId)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    case .finished:
                        print("did finish loading getPortfolio")
                    }
                } receiveValue: { [weak self] response in
                    print(response)
                    self?.totalAmount = response.totalAmountCurrencies.asString
                    self?.positions.removeAll()
                    self?.positions.append(contentsOf: response.positions.map { position in
                        return AccountPosition(figi: position.figi, type: position.instrumentType, quantity: position.quantity.asDecimal, value: position.averagePositionPrice.asString)
                    })
                }
                .store(in: &cancellableSet)
        }
    }
    
    public func sandboxPayIn(accountId: String, rubAmmount: Int64) {
        guard isSandbox else { return }
        var value = Tinkoff_Public_Invest_Api_Contract_V1_MoneyValue()
        value.currency = "RUB"
        value.units = rubAmmount
        sdk.sandboxService.sandboxPayIn(accountID: accountId, ammount: value)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading sandboxPayIn")
                }
                self?.fetch()
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
}
