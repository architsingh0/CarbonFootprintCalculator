//
//  LeaderboardEntry.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import Foundation

struct LeaderboardEntry {
    var id: String
    var userId: String
    var name: String = "Unknown"
    var profileImageUrl: String = ""
    var score: Double
    var milesDriven: Double
    var electricityUsed: Double
}
