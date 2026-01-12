//
//  WorkoutView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct WorkoutView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("ワークアウト画面")
                    .font(.largeTitle)
                    .padding()
                
                Text("トレーニング一覧とカテゴリ機能を実装予定")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("ワークアウト")
        }
    }
}

#Preview {
    WorkoutView()
}