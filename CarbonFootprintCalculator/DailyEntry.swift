//
//  DailyEntry.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import Foundation

struct DailyEntry: Codable {
    var userId: String
    var date: Date
    var milesDriven: Double
    var electricityUsed: Double
    var runningDistance: Double
    var walkingDistance: Double
    var score: Double
}
