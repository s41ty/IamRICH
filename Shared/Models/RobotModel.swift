//
//  RobotModel.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 05.05.2022.
//

import SwiftUI
import Combine
import Foundation
import TinkoffInvestSDK
import SwiftUICharts

struct Interval {
    var time: Date
    var close: Decimal
    var fast: Decimal
    var slow: Decimal
    var macd: Decimal
    var signal: Decimal
}


public class RobotModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var isActive: Bool
    
    @Published public var isSandbox: Bool
    
    @Published public var accountId: String
    
    @Published public var lastPrice: Decimal = 0
    
    @Published public var portfolioQuantity: Decimal = 0
    
    @Published public var portfolioPrice: Decimal = 0
    
    @Published public var buyOrders = [AccountOrder]()
    
    @Published public var sellOrders = [AccountOrder]()
    
    @Published public var figi = "BBG333333333"
    
    @Published public var ticker = "TMOS"
    
    @Published public var lastChartData = MultiLineChartData(dataSets: MultiLineDataSet(dataSets: []), metadata: ChartMetadata(), xAxisLabels: nil, chartStyle: LineChartStyle(baseline: .minimumWithMaximum(of: -0.005), topLine: .maximum(of: 0.005)), noDataText: Text("Загружаю данные"))
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    private var timer: Timer?
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, accountId: String, isSandbox: Bool = false) {
        self.sdk = sdk
        self.isSandbox = isSandbox
        self.accountId = accountId
        self.isActive = false
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        isActive = true
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    public func stop() {
        isActive = false
        timer = nil
    }
    
    @objc private func fetch() {
        print("==========")
        print("fetching data")
        
        let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let toDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        
        if isSandbox {
            Publishers.Zip3(
                sdk.marketDataService.getCandels(figi: figi, from: fromDate.asProtobuf, to: toDate.asProtobuf, interval: .candleInterval1Min),
                sdk.sandboxService.getSandboxPortfolio(accountID: accountId),
                sdk.sandboxService.getSandboxOrders(accountID: accountId)
            )
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish fetching data")
                }
            } receiveValue: { [weak self] c, p, o in
//                print(response)
                self?.updateData(candles: c.candles, positions: p.positions, orders: o.orders)
            }
            .store(in: &cancellableSet)
        } else {
            Publishers.Zip3(
                sdk.marketDataService.getCandels(figi: figi, from: fromDate.asProtobuf, to: toDate.asProtobuf, interval: .candleInterval1Min),
                sdk.operationsService.getPortfolio(accountID: accountId),
                sdk.ordersService.getOrders(accountID: accountId)
            )
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish fetching data")
                }
            } receiveValue: { [weak self] c, p, o in
//                print(response)
                self?.updateData(candles: c.candles, positions: p.positions, orders: o.orders)
            }
            .store(in: &cancellableSet)
        }
    }
    
    private func updateData(candles: [Tinkoff_Public_Invest_Api_Contract_V1_HistoricCandle], positions: [Tinkoff_Public_Invest_Api_Contract_V1_PortfolioPosition], orders: [Tinkoff_Public_Invest_Api_Contract_V1_OrderState]) {
        
        let accountPositions = positions.filter { position in
            return position.figi == figi
        }.map { position in
//                averagePositionPriceFifo ???
            return AccountPosition(figi: position.figi, type: position.instrumentType, quantity: position.quantity.asDecimal, value: position.averagePositionPrice.asString, average: position.averagePositionPrice.asDecimal)
        }
        buyOrders = orders.filter { order in
            return order.figi == figi && order.direction == .buy
        }.map { order in
            return AccountOrder(figi: order.figi)
        }
        sellOrders = orders.filter { order in
            return order.figi == figi && order.direction == .sell
        }.map { order in
            return AccountOrder(figi: order.figi)
        }
        
        let intervals = calculateIntervals(candles: candles)
        prepareChartData(intervals: intervals)
        
        makeDecision(intervals: intervals, positions: accountPositions, buyOrders: buyOrders, sellOrders: sellOrders)
    }
    
    private func makeDecision(intervals: [Interval], positions: [AccountPosition], buyOrders: [AccountOrder], sellOrders: [AccountOrder]) {
        if let lastInterval = intervals.last {
            lastPrice = lastInterval.close
        }
        if let lastPosition = positions.last {
            portfolioQuantity = lastPosition.quantity
            portfolioPrice = lastPosition.average
        }
        
        let lastTwo = intervals.suffix(2)
        
        guard lastTwo.count > 1 else {
            return
        }
        guard let previous = lastTwo.first,
            let last = lastTwo.last
        else {
            return
        }
        
        let lastClose = last.close
        let previousMACD = previous.macd
        let lastMACD = last.macd
        let previousSignal = previous.signal
        let lastSignal = last.signal
        
        print("making decision")
        
        if previousSignal < previousMACD && lastSignal > lastMACD {
            print("trying to sell...")
            let price = portfolioPrice
//            let round = Double(round(1000 * NSDecimalNumber(decimal: price).doubleValue) / 1000)
//            let fix = Decimal(floatLiteral: round)
            let quantity = NSDecimalNumber(decimal: portfolioQuantity).int64Value
            if lastClose > price {
                addOrder(figi: figi, quantity: quantity, price: price, direction: .sell)
                print("selling quantity:\(quantity) price:\(price)")
            }
            else {
                print("price is not good")
            }
        } else if previousSignal > previousMACD && lastSignal < lastMACD {
            print("trying to buy...")
            let price = lastClose
//            let round = Double(round(1000 * NSDecimalNumber(decimal: price).doubleValue) / 1000)
//            let fix = Decimal(floatLiteral: round)
            let quantity: Int64 = 40
            addOrder(figi: figi, quantity: quantity, price: price, direction: .buy)
            print("buying quantity:\(quantity) price:\(price)")
//            addOrder(figi: figi, quantity: quantity, price: fix, direction: .buy)
//            print("buying quantity:\(quantity) price:\(fix)")
        } else {
            print("waiting with potfolio quantity:\(portfolioQuantity) average price:\(portfolioPrice), last price:\(lastPrice)")
        }
    }
    
    public func addOrder(
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
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    case .finished:
                        print("did finish loading postSandboxOrder")
                    }
                } receiveValue: { response in
//                    print(response)
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
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    case .finished:
                        print("did finish loading postOrder")
                    }
                } receiveValue: { response in
//                    print(response)
                }
                .store(in: &cancellableSet)
        }
    }
    
    private func calculateIntervals(candles: [Tinkoff_Public_Invest_Api_Contract_V1_HistoricCandle]) -> [Interval] {
        var intervals = [Interval]()
        let fastWeightingMultiplier: Decimal = 2 / (12 + 1)   // ~ 0,154
        let slowWeightingMultiplier: Decimal = 2 / (26 + 1)  // ~ 0,07
        let signalWeightingMultiplier: Decimal = 2 / (9 + 1) // ~ 0,20
        var sum12: Decimal = 0
        var sum26: Decimal = 0
        var sum9: Decimal = 0
        var previousFast: Decimal = 0
        var previousSlow: Decimal = 0
        var previousSignal: Decimal = 0
        var currentClose: Decimal = 0
        var currentFast: Decimal = 0
        var currentSlow: Decimal = 0
        var currentMACD: Decimal = 0
        var currentSignal: Decimal = 0
        
        for (index, candle) in candles.enumerated() {
            currentClose = candle.close.asDecimal
            
            if index < 11 {
                sum12 += currentClose
                sum26 += currentClose
            } else if index == 11 {
                sum12 += currentClose
                sum26 += currentClose
                currentFast = sum12 / 12
            } else if index < 25 {
                sum26 += currentClose
                currentFast = (currentClose - previousFast) * fastWeightingMultiplier + previousFast
            } else if index == 25 {
                sum26 += currentClose
                currentSlow = sum26 / 26
                currentFast = (currentClose - previousFast) * fastWeightingMultiplier + previousFast
                currentMACD = currentFast - currentSlow
                sum9 += currentMACD
            } else if index < 33 {
                currentFast = (currentClose - previousFast) * fastWeightingMultiplier + previousFast
                currentSlow = (currentFast - previousSlow) * slowWeightingMultiplier + previousSlow
                currentMACD = currentFast - currentSlow
                sum9 += currentMACD
            } else if index == 33 {
                currentFast = (currentClose - previousFast) * fastWeightingMultiplier + previousFast
                currentSlow = (currentFast - previousSlow) * slowWeightingMultiplier + previousSlow
                currentMACD = currentFast - currentSlow
                currentSignal = sum9 / 9
            } else {
                currentFast = (currentClose - previousFast) * fastWeightingMultiplier + previousFast
                currentSlow = (currentFast - previousSlow) * slowWeightingMultiplier + previousSlow
                currentMACD = currentFast - currentSlow
                currentSignal = (currentMACD - previousSignal) * signalWeightingMultiplier + previousSignal
            }
            
            previousFast = currentFast
            previousSlow = currentSlow
            previousSignal = currentSignal
            
            let interval = Interval(time: candle.time.asDate, close: currentClose, fast: currentFast, slow: currentSlow, macd: currentMACD, signal: currentSignal)
            intervals.append(interval)
        }
        return intervals
    }
    
    private func prepareChartData(intervals: [Interval]) {
        let lastIntervals = intervals.suffix(30)
        var macdData = [LineChartDataPoint]()
        var signalData = [LineChartDataPoint]()
        for interval in lastIntervals {
            let macd = NSDecimalNumber(decimal: interval.macd).doubleValue
            let signal = NSDecimalNumber(decimal: interval.signal).doubleValue
            macdData.append(LineChartDataPoint(value: macd, date: interval.time))
            signalData.append(LineChartDataPoint(value: signal, date: interval.time))
        }
        lastChartData.dataSets = MultiLineDataSet(dataSets: [
            LineDataSet(dataPoints: macdData,
                        legendTitle: "MACD",
                        pointStyle: PointStyle(pointType: .outline, pointShape: .circle),
                        style: LineStyle(
                            lineColour: ColourStyle(colour: .blue),
                            lineType: .curvedLine,
                            strokeStyle: Stroke(lineWidth: 2)
                        )),
            LineDataSet(dataPoints: signalData,
                        legendTitle: "Signal",
                        pointStyle: PointStyle(pointType: .outline, pointShape: .circle),
                        style: LineStyle(
                            lineColour: ColourStyle(colour: .red),
                            lineType: .curvedLine,
                            strokeStyle: Stroke(lineWidth: 2)
                        )),
        ])
    }
}
