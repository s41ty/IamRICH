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
    
    @Published public var isActive: Bool
    
    @Published public var logs = [String]()
    
    @Published public var isSandbox: Bool
    
    @Published public var accountId: String
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    public private(set) var orders: OrdersModel
    
    private let instrumentFigi = "BBG333333333"
    
    private let instrumentTicker = "TMOS"
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, accountId: String, isSandbox: Bool = false, orders: OrdersModel) {
        self.sdk = sdk
        self.isSandbox = isSandbox
        self.accountId = accountId
        self.orders = orders
        self.isActive = false
    }
    
    public func start() {
        isActive = true
        appendLog(message: "Bot is started")
        appendLog(message: "Instrument ticker: \(instrumentTicker)")
        appendLog(message: "Instrument figi: \(instrumentFigi)")
        fetchCandles()
    }
    
    public func stop() {
        isActive = false
        appendLog(message: "Bot is stopped")
    }
    
    private func appendLog(message: String) {
        let dateString = Date.now.formatted(date: .omitted, time: .standard)
        
        self.logs.append("\(dateString): \(message)")
    }
    
    private func fetchCandles() {
        appendLog(message: "Start fetching candles")
        
        let q: TimeInterval = 3 * 24*60*60
        let minutes: TimeInterval = 1 * 26
        let current = Date() - q
        let past = current - minutes
        
        
        sdk.marketDataService.getCandels(
            figi: instrumentFigi,
            from: past.asProtobuf,
            to: current.asProtobuf,
            interval: .candleInterval1Min
        )
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading getCandels")
                }
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
}
