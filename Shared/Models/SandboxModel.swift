//
//  SandboxModel.swift
//  
//
//  Created by Sergey Yuryev on 30.04.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public class SandboxModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var accounts = Array<Tinkoff_Public_Invest_Api_Contract_V1_Account>()
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    
    // MARK: - Fetch data
    
    public init(sdk: TinkoffInvestSDK) {
        self.sdk = sdk
    }

    public func fetch() {
        sdk.sandboxService.getSandboxAccounts()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("did finish loading getSandboxAccounts")
                }
            } receiveValue: { [weak self] response in
                print(response)
                self?.accounts.removeAll()
                self?.accounts.append(contentsOf: response.accounts)
            }
            .store(in: &cancellableSet)
    }
    
    public func open() {
        sdk.sandboxService.openSandboxAccount()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("did finish loading getSandboxAccounts")
                }
                self?.fetch()
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
    
    public func close(accountId: String) {
        sdk.sandboxService.closeSandboxAccount(accountID: accountId)
            .receive(on: RunLoop.main)
            .sink { [weak self]  completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("did finish loading getSandboxAccounts")
                }
                self?.fetch()
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
    
    public func add(accountId: String, rubAmmount: Int64) {
        var value = Tinkoff_Public_Invest_Api_Contract_V1_MoneyValue()
        value.currency = "RUB"
        value.units = rubAmmount
        sdk.sandboxService.sandboxPayIn(accountID: accountId, ammount: value)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("did finish loading getSandboxAccounts")
                }
                self?.fetch()
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
}
