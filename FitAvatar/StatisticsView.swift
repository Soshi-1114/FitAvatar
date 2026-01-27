//
//  StatisticsView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject private var appData = AppData.shared
    @State private var selectedPeriod: TimePeriod = .week

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間選択セグメント
                    periodSelectionSection

                    // サマリーカード
                    summaryCardsSection

                    // トレーニング頻度チャート（簡易版）
                    trainingFrequencySection

                    // カテゴリ別統計
                    categoryStatsSection

                    // 最近のトレーニング履歴
                    recentWorkoutsSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Period Selection Section
    private var periodSelectionSection: some View {
        Picker("期間", selection: $selectedPeriod) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical, 10)
    }

    // MARK: - Summary Cards Section
    private var summaryCardsSection: some View {
        VStack(spacing: 15) {
            Text("サマリー")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatisticCard(
                    title: "総トレーニング",
                    value: "\(filteredWorkouts.count)",
                    unit: "回",
                    icon: "dumbbell.fill",
                    color: .blue
                )

                StatisticCard(
                    title: "総セット数",
                    value: "\(totalSets)",
                    unit: "セット",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatisticCard(
                    title: "総時間",
                    value: "\(totalMinutes)",
                    unit: "分",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Training Frequency Section
    private var trainingFrequencySection: some View {
        VStack(spacing: 15) {
            Text("トレーニング頻度")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)

                VStack(spacing: 10) {
                    // 簡易的な棒グラフ表示
                    let maxCount = weeklyData.map(\.count).max() ?? 1
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(weeklyData, id: \.day) { data in
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 30, height: 100)

                                    VStack {
                                        Spacer()
                                        let normalizedHeight = maxCount > 0 ? CGFloat(data.count) / CGFloat(maxCount) * 100 : 0
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue)
                                            .frame(width: 30, height: normalizedHeight)
                                    }
                                }
                                .frame(height: 100)

                                Text(data.day)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Category Stats Section
    private var categoryStatsSection: some View {
        VStack(spacing: 15) {
            Text("カテゴリ別統計")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(ExerciseCategory.allCases, id: \.self) { category in
                CategoryStatRow(
                    category: category,
                    count: categoryCount(for: category),
                    totalCount: filteredWorkouts.count
                )
            }
        }
    }

    // MARK: - Recent Workouts Section
    private var recentWorkoutsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("最近のトレーニング")
                    .font(.headline)

                Spacer()

                NavigationLink("すべて見る") {
                    WorkoutHistoryListView(workouts: appData.workoutHistory)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            if filteredWorkouts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("まだトレーニングデータがありません")
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            } else {
                ForEach(filteredWorkouts.prefix(5)) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var filteredWorkouts: [WorkoutRecord] {
        appData.getFilteredWorkouts(for: selectedPeriod)
    }
    
    private var totalSets: Int {
        filteredWorkouts.reduce(0) { $0 + $1.sets }
    }

    private var totalMinutes: Int {
        filteredWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }

    private var weeklyData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
        
        // 今日の曜日を取得（1=日曜日, 2=月曜日, ..., 7=土曜日）
        let todayWeekday = calendar.component(.weekday, from: today)
        
        // 日本語の曜日表記（日曜始まり）
        let weekDayNames = ["日", "月", "火", "水", "木", "金", "土"]
        
        // 過去7日間のデータを作成（今日を含む）
        return (0..<7).map { dayOffset in
            // 6日前から今日まで
            let date = calendar.date(byAdding: .day, value: dayOffset - 6, to: today)!
            let weekday = calendar.component(.weekday, from: date)
            let dayName = weekDayNames[weekday - 1]  // weekdayは1始まりなので-1
            
            let count = appData.workoutHistory.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }.count
            
            return DayData(day: dayName, count: count)
        }
    }

    private func categoryCount(for category: ExerciseCategory) -> Int {
        filteredWorkouts.filter { $0.category == category }.count
    }
}


#Preview {
    StatisticsView()
}
