//
//  IamRICHApp.swift
//  Shared
//
//  Created by Sergey Yuryev on 27.04.2022.
//

import SwiftUI

@main
struct IamRICHApp: App {
    
    // MARK: - Properties
    
    @StateObject var credentials = Credentials()
    
    
    // MARK: - App scene
    
    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environmentObject(credentials)
        }
    }
}
