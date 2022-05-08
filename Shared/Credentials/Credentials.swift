//
//  Credentials.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 29.04.2022.
//

import KeychainAccess
import Combine

private enum Constants {
    static let serviceName = "me.yuryev.rich"
    static let tokenKey = "TinkoffInvestAccessToken"
}

public class Credentials: ObservableObject {
    
    // MARK: - Properties
    
    private let keychain = Keychain(service: Constants.serviceName)
    
    @Published public var accessToken: String?
    
    public init() {
        self.accessToken = loadToken()
    }
    
    
    // MARK: - Keychain methods
    
    public func saveToken(_ newToken: String) {
        accessToken = newToken
        keychain[string: Constants.tokenKey] = newToken
    }
    
    public func deleteToken() {
        accessToken = nil
        keychain[string: Constants.tokenKey] = nil
    }
    
    private func loadToken() -> String? {
        return keychain[string: Constants.tokenKey]
    }
}
