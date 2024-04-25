//
//  HomeView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            ProfileView()
                .tabItem {
                    if let url = viewModel.profileImageURL {
                        AsyncImage(url: url) { image in
                            let size = CGSize(width: 30, height: 30)
                            Image(size: size) { gc in
                                gc.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                                gc.draw(image, in: .init(origin: .zero, size: size))
                            }
                            Text("Profile")
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}


#Preview {
    HomeView()
}
