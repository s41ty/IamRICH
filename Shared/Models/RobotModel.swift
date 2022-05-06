//
//  RobotModel.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 05.05.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public class RobotModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var isSandbox: Bool
    
    @Published public var accountId: String
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    public private(set) var orders: OrdersModel
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, accountId: String, isSandbox: Bool = false) {
        self.sdk = sdk
        self.isSandbox = isSandbox
        self.accountId = accountId
        self.orders = OrdersModel(sdk: sdk, accountId: accountId, isSandbox: isSandbox)
    }
    
    public func start() {

    }
    
    public func stop() {
        
    }
}
