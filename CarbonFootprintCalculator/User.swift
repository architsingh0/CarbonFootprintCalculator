//
//  User.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var name: String
    var email: String
    var profileImageUrl: String?
}
