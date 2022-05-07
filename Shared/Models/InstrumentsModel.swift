//
//  InstrumentsModel.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 07.05.2022.
//

import Combine
import Foundation
import TinkoffInvestSDK

public class InstrumentsModel: ObservableObject {
    
    // MARK: - Properties

    @Published public var cached = [String: String]()
    
    private var cancellableSet = Set<AnyCancellable>()

    private var sdk: TinkoffInvestSDK

    
    // MARK: - Init
    
    public init(sdk: TinkoffInvestSDK) {
        self.sdk = sdk
    }
    
    public func getInstrument(figi: String) {
        if self.cached[figi] != nil {
            return
        } else if figi == "FG0000000000" {
            self.cached[figi] = "Российский рубль"
            return
        }
        
        sdk.instrumentsService.getInstrumentBy(figi: figi)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading getInstrumentBy")
                }
            } receiveValue: { [weak self] response in
                print(response)
                self?.cached[response.instrument.figi] = response.instrument.name
            }
            .store(in: &cancellableSet)
    }
    
    public func getEfts() {
        sdk.instrumentsService.etfs()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading etfs")
                }
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
    
    public func getBonds() {
        sdk.instrumentsService.bonds()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading bonds")
                }
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
    
    public func getShares() {
        sdk.instrumentsService.shares()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading shares")
                }
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
    
    public func getCurrencies() {
        sdk.instrumentsService.currencies()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("\(error.localizedDescription) \(String(describing: error.trailingMetadata))")
                case .finished:
                    print("did finish loading currencies")
                }
            } receiveValue: { response in
                print(response)
            }
            .store(in: &cancellableSet)
    }
}
