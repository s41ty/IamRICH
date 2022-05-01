//
//  AccountsModel.swift
//  
//
//  Created by Sergey Yuryev on 30.04.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public class AccountModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var account = Tinkoff_Public_Invest_Api_Contract_V1_PortfolioResponse()
    
    @Published public var accountName: String
    
    @Published public var accountId: String
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    
    // MARK: - Fetch data
    
    public init(sdk: TinkoffInvestSDK, account: Tinkoff_Public_Invest_Api_Contract_V1_Account) {
        self.sdk = sdk
        self.accountId = account.id
        self.accountName = account.name
    }

    public func fetch() {
        sdk.operationsService.getPortfolio(accountID: accountId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("did finish loading getAccounts")
                }
            } receiveValue: { [weak self] response in
                print(response)
                self?.account = response
            }
            .store(in: &cancellableSet)
    }
}
