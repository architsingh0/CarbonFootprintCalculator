//
//  DashboardViewModel.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import Foundation
import Combine
import HealthKit
import SwiftUI
import Firebase

class DashboardViewModel: ObservableObject {
    @Published var milesDriven : Double = 0.0
    @Published var electricityUsed : Double = 0.0
    @Published var currentScore: Double?
    @Published var entryExists = false
    @Published var errorMessage = ""
    
    private var db = Firestore.firestore()
    private var healthStore = HKHealthStore()

    init() {
        fetchTodayEntry()
    }

    func fetchTodayEntry() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        db.collection("entries").whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: today)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    let scores = documents.compactMap { try? $0.data(as: DailyEntry.self) }
                    if let score = scores.first {
                        self.currentScore = score.score
                        self.entryExists = true
                    }
                }
            }
    }

    func submitEntry() {
        guard let userId = Auth.auth().currentUser?.uid
        else {
            self.errorMessage = "Invalid input data. Please check and try again."
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        let entry = DailyEntry(userId: userId, date: today, milesDriven: milesDriven, electricityUsed: electricityUsed, runningDistance: 0, walkingDistance: 0, score: calculateScore(milesDriven: milesDriven, electricityUsed: electricityUsed))
        
        do {
            try db.collection("entries").addDocument(from: entry)
            self.currentScore = entry.score
            self.entryExists = true
        } catch {
            self.errorMessage = "Error saving entry: \(error.localizedDescription)"
        }
    }

    private func calculateScore(milesDriven: Double, electricityUsed: Double) -> Double {
        let milesScore = milesDriven * 0.79  // EPA estimate: 0.79 kg CO2 per mile driven
        let electricityScore = electricityUsed * 0.85  // EPA estimate: 0.85 kg CO2 per kWh
        return milesScore + electricityScore
    }

    func fetchHealthKitData() {
        let readTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            guard success else {
                self.errorMessage = "HealthKit permission denied."
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let sum = result?.sumQuantity() {
                    let distance = sum.doubleValue(for: HKUnit.meter())
                    let km = distance / 1000
                    DispatchQueue.main.async {
                        self.updateScore(with: km)
                    }
                }
            }
            
            self.healthStore.execute(query)
        }
    }

    private func updateScore(with runningKm: Double) {
        if var score = self.currentScore {
            score += runningKm * 0.1
            self.currentScore = score
        }
    }
    
    func resetData(){
        milesDriven = 0.0
        electricityUsed = 0.0
        currentScore = nil
        entryExists = false
        errorMessage = ""
        fetchTodayEntry()
    }
}
