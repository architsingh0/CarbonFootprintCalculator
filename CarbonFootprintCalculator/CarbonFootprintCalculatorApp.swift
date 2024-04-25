//
//  CarbonFootprintCalculatorApp.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct CarbonFootprintCalculatorApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var dashboardViewModel = DashboardViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(appViewModel)
                    .environmentObject(dashboardViewModel)
            }
        }
    }
}
