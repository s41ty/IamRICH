//
//  OrdersModel.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 02.05.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public class OrdersModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var isSandbox: Bool
    
    @Published public var accountId: String
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, accountId: String, isSandbox: Bool = false) {
        self.sdk = sdk
        self.isSandbox = isSandbox
        self.accountId = accountId
    }
    
    public func fetch() {
        if isSandbox {
            sdk.sandboxService.getSandboxOrders(accountID: accountId)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("did finish loading getSandboxAccounts")
                    }
                } receiveValue: { response in
                    print(response)
                }
                .store(in: &cancellableSet)
        } else {
            sdk.ordersService.getOrders(accountID: accountId)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("did finish loading getOrders")
                    }
                } receiveValue: { response in
                    print(response)
                }
                .store(in: &cancellableSet)
        }
    }
    
    public func remove(orderID: String) {
        if isSandbox {
            sdk.sandboxService.cancelSandboxOrder(accountID: accountId, orderID: orderID)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("did finish loading cancelSandboxOrder")
                    }
                    self?.fetch()
                } receiveValue: { response in
                    print(response)
                }
                .store(in: &cancellableSet)
        } else {
            sdk.ordersService.cancelOrder(accountID: accountId, orderID: orderID)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("did finish loading cancelOrder")
                    }
                    self?.fetch()
                } receiveValue: { response in
                    print(response)
                }
                .store(in: &cancellableSet)
        }
    }
    
    public func add(
        figi: String,
        quantity: Int64,
        price: Decimal,
        direction: Tinkoff_Public_Invest_Api_Contract_V1_OrderDirection
    ) {
        if isSandbox {
            sdk.sandboxService.postSandboxOrder(
                accountID: accountId,
                figi: figi,
                quantity: quantity,
                price: price.asQuotation,
                direction: direction,
                orderType: .limit
            )
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("did finish loading postSandboxOrder")
                    }
                    self?.fetch()
                } receiveValue: { response in
                    print(response)
                }
                .store(in: &cancellableSet)
        } else {
            sdk.ordersService.postOrder(
                accountID: accountId,
                figi: figi,
                quantity: quantity,
                price: price.asQuotation,
                direction: direction,
                orderType: .limit
            )
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("did finish loading postOrder")
                    }
                    self?.fetch()
                } receiveValue: { response in
                    print(response)
                }
                .store(in: &cancellableSet)
        }
    }
}
