//
//  AccountsModel.swift
//  
//
//  Created by Sergey Yuryev on 30.04.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public class AccountsModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var real = Array<Tinkoff_Public_Invest_Api_Contract_V1_Account>()
    
    @Published public var sandboxes = Array<Tinkoff_Public_Invest_Api_Contract_V1_Account>()
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK) {
        self.sdk = sdk
    }

    public func fetch() {
        sdk.usersService.getAccounts()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading getAccounts")
                }
            } receiveValue: { [weak self] response in
                print(response)
                self?.real.removeAll()
                self?.real.append(contentsOf: response.accounts)
            }
            .store(in: &cancellableSet)
        
        sdk.sandboxService.getSandboxAccounts()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading getSandboxAccounts")
                }
            } receiveValue: { [weak self] response in
                print(response)
                self?.sandboxes.removeAll()
                self?.sandboxes.append(contentsOf: response.accounts)
            }
            .store(in: &cancellableSet)
    }
    
    public func openSandbox() {
        sdk.sandboxService.openSandboxAccount()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading getSandboxAccounts")
                }
                self?.fetch()
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
    
    public func closeSandbox(accountId: String) {
        sdk.sandboxService.closeSandboxAccount(accountID: accountId)
            .receive(on: RunLoop.main)
            .sink { [weak self]  completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
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


extension Tinkoff_Public_Invest_Api_Contract_V1_Account: Identifiable {

}
