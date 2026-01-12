//
//  HomeView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct HomeView: View {
    @State private var userName = "トレーニー"
    @State private var todayWorkouts: [String] = ["プッシュアップ", "スクワット", "プランク"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー部分
                    headerSection
                    
                    // アバター表示部分
                    avatarSection
                    
                    // 今日のトレーニング部分
                    todayWorkoutSection
                    
                    // クイックワークアウト部分
                    quickWorkoutSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("FitAvatar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("おかえりなさい！")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(userName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // 通知ボタン
            Button(action: {
                // 通知機能は後で実装
            }) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: 15) {
            Text("あなたのアバター")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)
                
                VStack {
                    // 仮のアバター表示（後で3Dアバターに置き換え）
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("レベル 5")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("次のレベルまで 45 XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                // アバター詳細画面へのナビゲーション
            }
        }
    }
    
    // MARK: - Today's Workout Section
    private var todayWorkoutSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("今日のトレーニング")
                    .font(.headline)
                
                Spacer()
                
                Button("すべて見る") {
                    // ワークアウト画面へのナビゲーション
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if todayWorkouts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("今日のトレーニングを\n追加しましょう！")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(todayWorkouts, id: \.self) { workout in
                        WorkoutCard(workoutName: workout)
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Workout Section
    private var quickWorkoutSection: some View {
        VStack(spacing: 15) {
            Text("クイックワークアウト")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickWorkoutButton(
                    title: "腕",
                    icon: "arm.flex",
                    color: .red
                )
                
                QuickWorkoutButton(
                    title: "胸",
                    icon: "heart.fill",
                    color: .orange
                )
                
                QuickWorkoutButton(
                    title: "脚",
                    icon: "figure.walk",
                    color: .green
                )
                
                QuickWorkoutButton(
                    title: "体幹",
                    icon: "figure.core.training",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Workout Card Component
struct WorkoutCard: View {
    let workoutName: String
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(workoutName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("未完了")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Workout Button Component
struct QuickWorkoutButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // クイックワークアウト開始処理
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(15)
        }
    }
}

#Preview {
    HomeView()
}