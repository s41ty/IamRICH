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

public struct RobotSettings {
    var figi: String
    var ticker: String
    var limit: Decimal
}


public class RobotModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var isActive: Bool
    
    @Published public var isSandbox: Bool
    
    @Published public var accountId: String
    
    @Published public var lastPrice: Decimal = 0
    
    @Published public var portfolioQuantity: Decimal = 0
    
    @Published public var portfolioPrice: Decimal = 0
    
    @Published public var decisionMessages = [String]()
    
    @Published public var settings = RobotSettings(figi: "BBG333333333", ticker: "TMOS", limit: 700)
    
    @Published public var buyOrders = [AccountOrder]()
    
    @Published public var sellOrders = [AccountOrder]()
    
    @Published public var historyOrders = [AccountOrder]()
    
    @Published public var chartData = MultiLineChartData(dataSets: MultiLineDataSet(dataSets: []), metadata: ChartMetadata(), xAxisLabels: nil, chartStyle: LineChartStyle(baseline: .minimumValue, topLine: .maximumValue), noDataText: Text("Загружаю данные"))
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK
    
    private var timer: Timer?
    
    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK, accountId: String, isSandbox: Bool = false) {
        self.sdk = sdk
        self.isSandbox = isSandbox
        self.accountId = accountId
        self.isActive = false
        loadOrdersHistory()
        updateOrders()
    }
    
    deinit {
        stop()
    }
    
    
    // MARK: - Settings
    
    public func updateSettings(newSettings: RobotSettings) {
        stop()
        settings = newSettings
        start()
    }
    
    // MARK: - Timer
    
    public func start() {
        isActive = true
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    public func stop() {
        isActive = false
        timer = nil
    }
    
    
    // MARK: - Data loading
    
    @objc private func fetch() {
        print("==========")
        print("fetching data")
        
        let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let toDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        
        if isSandbox {
            Publishers.Zip3(
                sdk.marketDataService.getCandels(figi: settings.figi, from: fromDate.asProtobuf, to: toDate.asProtobuf, interval: .candleInterval1Min),
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
                sdk.marketDataService.getCandels(figi: settings.figi, from: fromDate.asProtobuf, to: toDate.asProtobuf, interval: .candleInterval1Min),
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
            return position.figi == settings.figi
        }.map { position in
//                averagePositionPriceFifo ???
            return AccountPosition(figi: position.figi, type: position.instrumentType, quantity: position.quantity.asDecimal, value: position.averagePositionPrice.asString, average: position.averagePositionPrice.asDecimal)
        }
        buyOrders = orders.filter { order in
            return order.figi == settings.figi && order.direction == .buy
        }.map { order in
            return AccountOrder(figi: order.figi, orderId: order.orderID, accountId: self.accountId, isSandbox: self.isSandbox, direction: order.direction, status: order.executionReportStatus, totalOrderAmount: order.totalOrderAmount.asString, lotsRequested: order.lotsRequested)
        }
        sellOrders = orders.filter { order in
            return order.figi == settings.figi && order.direction == .sell
        }.map { order in
            return AccountOrder(figi: order.figi, orderId: order.orderID, accountId: self.accountId, isSandbox: self.isSandbox, direction: order.direction, status: order.executionReportStatus, totalOrderAmount: order.totalOrderAmount.asString, lotsRequested: order.lotsRequested)
        }
        
        let intervals = calculateIntervals(candles: candles)
        prepareChartData(intervals: intervals)
        
        makeDecision(intervals: intervals, positions: accountPositions, buyOrders: buyOrders, sellOrders: sellOrders)
    }
    
    
    // MARK: - Decision maker
    
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
        
        print("making decision")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: Date())
        
        if previous.signal < previous.macd && last.signal > last.macd {
            print("trying to sell...")
            let price = last.close * 0.999
            let round = Double(round(1000 * NSDecimalNumber(decimal: price).doubleValue) / 1000)
            let fix = Decimal(floatLiteral: round)
            let quantity = NSDecimalNumber(decimal: portfolioQuantity).int64Value
            if fix > portfolioPrice {
                addOrder(figi: settings.figi, quantity: quantity, price: fix, direction: .sell)
                print("selling quantity:\(quantity) price:\(fix)")
                decisionMessages.append("\(currentTime) Заявка на продажу:\(quantity) по цене:\(fix)")
            }
            else {
                print("last price is not good")
                decisionMessages.append("\(currentTime) Заявка на продажу не создана - низкая цена")
            }
        } else if previous.signal > previous.macd && last.signal < last.macd {
            print("trying to buy...")
            let price = last.close * 1.001
            let round = Double(round(1000 * NSDecimalNumber(decimal: price).doubleValue) / 1000)
            let fix = Decimal(floatLiteral: round)
            let quantity: Int64 = 30
            addOrder(figi: settings.figi, quantity: quantity, price: fix, direction: .buy)
            print("buying quantity:\(quantity) price:\(fix)")
            decisionMessages.append("\(currentTime) Заявка на покупку:\(quantity) по цене:\(fix)")
            addOrder(figi: settings.figi, quantity: quantity, price: last.close, direction: .buy)
            print("buying quantity:\(quantity) price:\(last.close)")
            decisionMessages.append("(currentTime) Заявка на покупку:\(quantity) по цене:\(last.close)")
        } else {
            print("waiting with potfolio quantity:\(portfolioQuantity) average price:\(portfolioPrice), last price:\(lastPrice)")
            decisionMessages.append("\(currentTime) Ожидаю следующего обновления...")
        }
    }

    
    // MARK: - MACD and signal
    
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
    
    
    // MARK: - Chart data
    
    private func prepareChartData(intervals: [Interval]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        let lastIntervals = intervals.suffix(30)
        var macdData = [LineChartDataPoint]()
        var signalData = [LineChartDataPoint]()
        for interval in lastIntervals {
            let macd = NSDecimalNumber(decimal: interval.macd).doubleValue
            let signal = NSDecimalNumber(decimal: interval.signal).doubleValue
            let mins = formatter.string(from: interval.time)
            macdData.append(LineChartDataPoint(value: macd, xAxisLabel: mins))
            signalData.append(LineChartDataPoint(value: signal, xAxisLabel: mins))
        }
        
        chartData = MultiLineChartData(dataSets: MultiLineDataSet(
            dataSets: [
                LineDataSet(dataPoints: macdData, legendTitle: "MACD", pointStyle: PointStyle(pointType: .outline, pointShape: .circle),
                            style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .curvedLine, strokeStyle: Stroke(lineWidth: 2))),
                LineDataSet(dataPoints: signalData, legendTitle: "Signal", pointStyle: PointStyle(pointType: .outline, pointShape: .circle),
                            style: LineStyle(lineColour: ColourStyle(colour: .red), lineType: .curvedLine, strokeStyle: Stroke(lineWidth: 2))),
                ]),
            metadata: ChartMetadata(),
            xAxisLabels: nil,
            chartStyle: LineChartStyle(baseline: .minimumValue, topLine: .maximumValue),
            noDataText: Text("Загружаю данные"))
    }
    
    
    // MARK: - History
    
    public func addOrderToHistory(order: AccountOrder) {
        historyOrders.append(order)
        saveOrdersHistory()
    }
    
    private func loadOrdersHistory() {
        if let data = UserDefaults.standard.data(forKey: "ordersHistory") {
            do {
                historyOrders = try JSONDecoder().decode([AccountOrder].self, from: data)
            } catch {
                print(error)
            }
        }
//        historyOrders.append(AccountOrder(figi: "BBG333333333", orderId: "1122334455", accountId: self.accountId, isSandbox: self.isSandbox, direction: .buy, status: .executionReportStatusUnspecified, totalOrderAmount: "1024 rub", lotsRequested: 100))
//        historyOrders.append(AccountOrder(figi: "BBG333333333", orderId: "1122334455", accountId: self.accountId, isSandbox: self.isSandbox, direction: .buy, status: .executionReportStatusUnspecified, totalOrderAmount: "1024 rub", lotsRequested: 50))
    }
    
    private func saveOrdersHistory() {
        do {
            let data = try JSONEncoder().encode(historyOrders)
            UserDefaults.standard.set(data, forKey: "ordersHistory")
        } catch  {
            print(error)
        }
    }
    
    
    // MARK: - Orders
    
    public func updateOrders() {
        for order in historyOrders {
            fetchOrders(order: order)
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
                } receiveValue: { [weak self] order in
//                    print(response)
                    guard let self = self else { return }
                    self.addOrderToHistory(order: AccountOrder(figi: order.figi, orderId: order.orderID, accountId: self.accountId, isSandbox: self.isSandbox, direction: order.direction, status: order.executionReportStatus, totalOrderAmount: order.totalOrderAmount.asString, lotsRequested: order.lotsRequested))
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
                } receiveValue: { [weak self] order in
//                    print(response)
                    guard let self = self else { return }
                    self.addOrderToHistory(order: AccountOrder(figi: order.figi, orderId: order.orderID, accountId: self.accountId, isSandbox: self.isSandbox, direction: order.direction, status: order.executionReportStatus, totalOrderAmount: order.totalOrderAmount.asString, lotsRequested: order.lotsRequested))
                }
                .store(in: &cancellableSet)
        }
    }
    
    private func fetchOrders(order: AccountOrder) {
        if order.isSandbox {
            sdk.sandboxService.getSandboxOrderState(accountID: order.accountId, orderID: order.orderId)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    case .finished:
                        print("did finish loading getSandboxOrderState")
                    }
                } receiveValue: { [weak self] order in
//                    print(order)
                    guard let self = self else { return }
                    let indexOfOrder = self.historyOrders.firstIndex { historyOrder in
                        return order.orderID == historyOrder.orderId
                    }
                    guard let index = indexOfOrder else { return }
                    self.historyOrders.modifyElement(atIndex: index) {
                        $0.status = order.executionReportStatus
                    }
                }
                .store(in: &cancellableSet)
        } else {
            sdk.ordersService.getOrderState(accountID: order.accountId, orderID: order.orderId)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                    case .finished:
                        print("did finish loading getOrderState")
                    }
                } receiveValue: { [weak self] order in
//                    print(order)
                    guard let self = self else { return }
                    let indexOfOrder = self.historyOrders.firstIndex { historyOrder in
                        return order.orderID == historyOrder.orderId
                    }
                    guard let index = indexOfOrder else { return }
                    self.historyOrders.modifyElement(atIndex: index) {
                        $0.status = order.executionReportStatus
                    }
                }
                .store(in: &cancellableSet)
        }
    }
}
