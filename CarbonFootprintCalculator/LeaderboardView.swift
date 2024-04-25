//
//  LeaderboardView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

import SwiftUI
import FirebaseFirestore

struct LeaderboardView: View {
    @State private var entries: [LeaderboardEntry] = []
    @State private var selectedDate = Date()
    @State private var selectedMetric: Metric = .score
    @State private var showingDate = false
    
    enum Metric: String, CaseIterable, Identifiable {
        case score = "Score"
        case milesDriven = "Miles Driven"
        case electricityUsed = "Electricity Used"
        
        var id: String { self.rawValue }
        var firestoreField: String {
            switch self {
            case .score:
                return "score"
            case .milesDriven:
                return "milesDriven"
            case .electricityUsed:
                return "electricityUsed"
            }
        }
    }

    var body: some View {
        NavigationView {
            List(entries, id: \.id) { entry in
                HStack {
                    AsyncImage(url: URL(string: entry.profileImageUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(entry.name).bold()
                        Text("\(selectedMetric.rawValue): \(entry.value(for: selectedMetric), specifier: "%.1f")").font(.subheadline)
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .onChange(of: selectedDate) { _ in fetchLeaderboard() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Select Metric", selection: $selectedMetric) {
                        ForEach(Metric.allCases) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                    .onChange(of: selectedMetric) { _ in fetchLeaderboard() }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .refreshable {
                fetchLeaderboard()
            }
            .onAppear(perform: fetchLeaderboard)
        }
    }

    private func fetchLeaderboard() {
        self.entries = [] // Clear existing entries
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        Firestore.firestore().collection("entries")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .order(by: selectedMetric.firestoreField, descending: selectedMetric == .score)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching leaderboard entries: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                for document in documents {
                    let userId = document.data()["userId"] as? String ?? ""
                    let entry = LeaderboardEntry(document: document)
                    fetchUserDetails(entry: entry)
                }
            }
    }

    private func fetchUserDetails(entry: LeaderboardEntry) {
        Firestore.firestore().collection("users").document(entry.userId).getDocument { userSnapshot, userError in
            if let userData = userSnapshot?.data(), userError == nil {
                let name = userData["name"] as? String ?? "Unknown"
                let profileImageUrl = userData["profileImageUrl"] as? String ?? ""
                
                DispatchQueue.main.async {
                    var updatedEntry = entry
                    updatedEntry.name = name
                    updatedEntry.profileImageUrl = profileImageUrl
                    self.entries.append(updatedEntry)
                }
            } else {
                print("Failed to fetch user details: \(userError?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

extension LeaderboardEntry {
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        self.userId = data["userId"] as? String ?? ""
        self.score = data["score"] as? Double ?? 0
        self.milesDriven = data["milesDriven"] as? Double ?? 0
        self.electricityUsed = data["electricityUsed"] as? Double ?? 0
    }
    
    func value(for metric: LeaderboardView.Metric) -> Double {
        switch metric {
        case .score:
            return score
        case .milesDriven:
            return milesDriven
        case .electricityUsed:
            return electricityUsed
        }
    }
}

#Preview {
    LeaderboardView()
}
