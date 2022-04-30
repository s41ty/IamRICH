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
    
    @Published public var accounts = Array<Tinkoff_Public_Invest_Api_Contract_V1_Account>()
    
    private var cancellableSet = Set<AnyCancellable>()

    
    // MARK: - Init

    public init(sdk: TinkoffInvestSDK) {
        sdk.userService.getAccounts()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("did finish loading getAccounts")
                }
            } receiveValue: { [weak self] response in
                self?.accounts.append(contentsOf: response.accounts)
            }
            .store(in: &cancellableSet)
    }
}


extension Tinkoff_Public_Invest_Api_Contract_V1_Account: Identifiable {

}
