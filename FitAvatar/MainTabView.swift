//
//  MainTabView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var appData = AppData.shared
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            WorkoutView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("ワークアウト")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
