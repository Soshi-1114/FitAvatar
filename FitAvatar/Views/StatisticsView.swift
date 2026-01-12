//
//  StatisticsView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct StatisticsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("統計画面")
                    .font(.largeTitle)
                    .padding()
                
                Text("進捗グラフ・履歴機能を実装予定")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("統計")
        }
    }
}

#Preview {
    StatisticsView()
}