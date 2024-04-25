//
//  HistoryView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI
import Charts
import FirebaseFirestore
import FirebaseAuth

import SwiftUI
import FirebaseFirestore

struct HistoryView: View {
    @State private var scoreDataPoints: [(String, Double)] = []
    @State private var milesDataPoints: [(String, Double)] = []
    @State private var electricityDataPoints: [(String, Double)] = []

    var body: some View {
        ScrollView {
            VStack {
                Text("Your Environmental Impact")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                ChartSection(title: "Score History", dataPoints: scoreDataPoints)
                ChartSection(title: "Miles Driven", dataPoints: milesDataPoints)
                ChartSection(title: "Electricity Used", dataPoints: electricityDataPoints)
            }
            .onAppear {
                loadScoreData()
                loadMilesData()
                loadElectricityData()
            }
            .padding()
        }
    }

    private func loadScoreData() {
        Firestore.firestore().collection("entries")
            .whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    self.scoreDataPoints = snapshot.documents.compactMap { doc -> (String, Double)? in
                        let data = doc.data()
                        if let timestamp = data["date"] as? Timestamp,
                           let score = data["score"] as? Double {
                            let date = timestamp.dateValue()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yyyy"
                            return (formatter.string(from: date), score)
                        }
                        return nil
                    }
                } else if let error = error {
                    print("Error fetching score data: \(error.localizedDescription)")
                }
            }
    }

    private func loadMilesData() {
        Firestore.firestore().collection("entries")
            .whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    self.milesDataPoints = snapshot.documents.compactMap { doc -> (String, Double)? in
                        let data = doc.data()
                        if let timestamp = data["date"] as? Timestamp,
                           let milesDriven = data["milesDriven"] as? Double {
                            let date = timestamp.dateValue()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yyyy"
                            return (formatter.string(from: date), milesDriven)
                        }
                        return nil
                    }
                } else if let error = error {
                    print("Error fetching miles data: \(error.localizedDescription)")
                }
            }
    }

    private func loadElectricityData() {
        Firestore.firestore().collection("entries")
            .whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    self.electricityDataPoints = snapshot.documents.compactMap { doc -> (String, Double)? in
                        let data = doc.data()
                        if let timestamp = data["date"] as? Timestamp,
                           let electricityUsed = data["electricityUsed"] as? Double {
                            let date = timestamp.dateValue()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yyyy"
                            return (formatter.string(from: date), electricityUsed)
                        }
                        return nil
                    }
                } else if let error = error {
                    print("Error fetching electricity data: \(error.localizedDescription)")
                }
            }
    }
}

struct ChartSection: View {
    var title: String
    var dataPoints: [(String, Double)]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 5)
            
            if !dataPoints.isEmpty {
                Chart {
                    ForEach(dataPoints, id: \.0) { dataPoint in
                        BarMark(
                            x: .value("Date", dataPoint.0),
                            y: .value(title, dataPoint.1)
                        )
                    }
                }
                .frame(height: 300)
            } else {
                Text("No data available for \(title.lowercased()).")
                    .italic()
            }
        }
    }
}




#Preview {
    HistoryView()
}
