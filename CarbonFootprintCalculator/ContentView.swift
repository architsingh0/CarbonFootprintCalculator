//
//  ContentView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        if viewModel.signedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
