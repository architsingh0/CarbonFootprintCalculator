//
//  DashboardView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @State private var showingTransportationPopup = false
    @State private var showingElectricityPopup = false

    var body: some View {
        NavigationView {
            Form{
                if viewModel.entryExists, let score = viewModel.currentScore {
                    Section{
                        VStack{
                            Image("globe")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                            Text("Your score for today is:\n\(score, specifier: "%.2f") points")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                    }
                } else {
                    VStack {
                        Text("Share Your Footprint")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Image("globe")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        VStack {
                            Text("Transportation (Miles Driven)")
                            Slider(value: $viewModel.milesDriven, in: 0.0...100.0) {
                                Text("Transportation")
                            } onEditingChanged: { editing in
                                showingTransportationPopup = editing
                            }
                            .padding()
                            if showingTransportationPopup {
                                Text("\(viewModel.milesDriven, specifier: "%.1f")")
                                    .transition(.scale)
                            }
                        }
                        
                        VStack {
                            Text("Electricity (kWh)")
                            Slider(value: $viewModel.electricityUsed, in: 0...100) {
                                Text("Electricity")
                            } onEditingChanged: { editing in
                                showingElectricityPopup = editing
                            }
                            .padding()
                            if showingElectricityPopup {
                                Text("\(viewModel.electricityUsed, specifier: "%.1f")")
                                    .transition(.scale)
                            }
                        }
                    }
                    Section(){
                        Button("Calculate Score") {
                            viewModel.fetchHealthKitData()  // Fetch health data after submitting entry
                            viewModel.submitEntry()
                            
                        }
                    }
                }
            
            
                
                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Dashboard")
            .onAppear(perform: viewModel.fetchTodayEntry)
        }
    }
}


#Preview {
    DashboardView()
}
