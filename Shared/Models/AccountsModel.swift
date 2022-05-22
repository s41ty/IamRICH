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
    
    @Published public var real = [Tinkoff_Public_Invest_Api_Contract_V1_Account]()
    
    @Published public var sandboxes = [Tinkoff_Public_Invest_Api_Contract_V1_Account]()
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    private var credentials: Credentials
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, credentials: Credentials) {
        self.sdk = sdk
        self.credentials = credentials
    }

    public func fetch() {
        Publishers.Zip(
            sdk.usersService.getAccounts(),
            sdk.sandboxService.getSandboxAccounts()
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    guard let trailingMetadata = error.trailingMetadata else {
                        return
                    }
                    for metadata in trailingMetadata {
                        if metadata.value == "Authentication failed" {
                            print("Authentication failed")
                            print("Token is removed")
                            self?.credentials.deleteToken()
                        }
                    }
                case .finished:
                    print("did finish loading getAccounts and getSandboxAccounts")
                }
            },
            receiveValue: { [weak self] r, s in
                print(r, s)
                self?.real = r.accounts
                self?.sandboxes = s.accounts
            }
        )
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
                    print("did finish loading openSandbox")
                }
                self?.fetch()
            } receiveValue: { response in
//                print(response)
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
                    print("did finish loading closeSandbox")
                }
                self?.fetch()
            } receiveValue: { response in
//                print(response)
            }
            .store(in: &cancellableSet)
    }
}


extension Tinkoff_Public_Invest_Api_Contract_V1_Account: Identifiable {

}
