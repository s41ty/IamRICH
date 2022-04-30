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
    
    @Published public var accountName = String()
    
    private var cancellableSet = Set<AnyCancellable>()

    
    // MARK: - Init

    public init(sdk: TinkoffInvestSDK, account: Tinkoff_Public_Invest_Api_Contract_V1_Account) {
        accountName = account.name
        sdk.operationsService.getPortfolio(accountID: account.id)
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
