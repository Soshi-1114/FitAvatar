//
//  AppData.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import SwiftUI
import UIKit
import Combine

// アプリ全体で共有するデータストア
class AppData: ObservableObject {
    static let shared = AppData()
    
    // ユーザー名
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    // トレーニング履歴
    @Published var workoutHistory: [WorkoutRecord] = [] {
        didSet {
            saveWorkoutHistory()
        }
    }
    
    // アバターステータス
    @Published var avatarStats: AvatarStats {
        didSet {
            saveAvatarStats()
        }
    }
    
    // 外観モード
    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
            applyAppearanceMode()
        }
    }
    
    // 通知設定
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var dailyReminderTime: Date {
        didSet {
            UserDefaults.standard.set(dailyReminderTime, forKey: "dailyReminderTime")
        }
    }
    
    @Published var workoutReminders: Bool {
        didSet {
            UserDefaults.standard.set(workoutReminders, forKey: "workoutReminders")
        }
    }
    
    // 目標設定
    @Published var weeklyWorkoutGoal: Int {
        didSet {
            UserDefaults.standard.set(weeklyWorkoutGoal, forKey: "weeklyWorkoutGoal")
        }
    }
    
    @Published var monthlyXPGoal: Int {
        didSet {
            UserDefaults.standard.set(monthlyXPGoal, forKey: "monthlyXPGoal")
        }
    }
    
    // アプリ設定
    @Published var hapticFeedback: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedback, forKey: "hapticFeedback")
        }
    }
    
    @Published var weightUnit: WeightUnit {
        didSet {
            UserDefaults.standard.set(weightUnit.rawValue, forKey: "weightUnit")
        }
    }
    
    @Published var distanceUnit: DistanceUnit {
        didSet {
            UserDefaults.standard.set(distanceUnit.rawValue, forKey: "distanceUnit")
        }
    }
    
    private init() {
        // UserDefaultsから値を読み込む
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? "トレーニー"
        
        let appearanceModeString = UserDefaults.standard.string(forKey: "appearanceMode") ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: appearanceModeString) ?? .system
        
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.dailyReminderTime = UserDefaults.standard.object(forKey: "dailyReminderTime") as? Date ?? Date()
        self.workoutReminders = UserDefaults.standard.object(forKey: "workoutReminders") as? Bool ?? true
        
        self.weeklyWorkoutGoal = UserDefaults.standard.object(forKey: "weeklyWorkoutGoal") as? Int ?? 3
        self.monthlyXPGoal = UserDefaults.standard.object(forKey: "monthlyXPGoal") as? Int ?? 1000
        
        self.hapticFeedback = UserDefaults.standard.object(forKey: "hapticFeedback") as? Bool ?? true
        
        let weightUnitString = UserDefaults.standard.string(forKey: "weightUnit") ?? WeightUnit.kg.rawValue
        self.weightUnit = WeightUnit(rawValue: weightUnitString) ?? .kg
        
        let distanceUnitString = UserDefaults.standard.string(forKey: "distanceUnit") ?? DistanceUnit.km.rawValue
        self.distanceUnit = DistanceUnit(rawValue: distanceUnitString) ?? .km
        
        // アバターステータスを読み込む
        self.avatarStats = AvatarStats()
        
        // トレーニング履歴を読み込む
        loadWorkoutHistory()
        
        // アバターステータスを読み込む（履歴の後に読み込む）
        loadAvatarStats()
        
        // 外観モードを適用
        applyAppearanceMode()
    }
    
    // MARK: - Workout History Management
    
    func addWorkout(_ workout: WorkoutRecord) {
        workoutHistory.insert(workout, at: 0)
    }
    
    private func saveWorkoutHistory() {
        if let encoded = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(encoded, forKey: "workoutHistory")
        }
    }
    
    private func loadWorkoutHistory() {
        if let data = UserDefaults.standard.data(forKey: "workoutHistory"),
           let decoded = try? JSONDecoder().decode([WorkoutRecord].self, from: data) {
            workoutHistory = decoded
        } else {
            // サンプルデータを初期化（開発時のみ）
            workoutHistory = WorkoutHistory.sampleData.workouts
        }
    }
    
    // MARK: - Avatar Stats Management
    
    private func saveAvatarStats() {
        if let encoded = try? JSONEncoder().encode(avatarStats) {
            UserDefaults.standard.set(encoded, forKey: "avatarStats")
        }
    }
    
    private func loadAvatarStats() {
        if let data = UserDefaults.standard.data(forKey: "avatarStats"),
           let decoded = try? JSONDecoder().decode(AvatarStats.self, from: data) {
            avatarStats = decoded
        }
    }
    
    // ステータスにXPを追加
    func addXPToStats(_ xp: Int, for bodyParts: [BodyPart]) {
        avatarStats.addXP(xp, to: bodyParts)
    }
    
    // MARK: - Statistics Helpers
    
    func getFilteredWorkouts(for period: TimePeriod) -> [WorkoutRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        return workoutHistory.filter { workout in
            switch period {
            case .week:
                return calendar.isDate(workout.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(workout.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(workout.date, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    func getTotalXP(for period: TimePeriod) -> Int {
        getFilteredWorkouts(for: period).reduce(0) { $0 + $1.xpEarned }
    }
    
    func getCurrentLevel() -> Int {
        let totalXP = workoutHistory.reduce(0) { $0 + $1.xpEarned }
        return totalXP / 200 + 1 // 200 XPごとにレベルアップ
    }
    
    func getXPToNextLevel() -> Int {
        let totalXP = workoutHistory.reduce(0) { $0 + $1.xpEarned }
        let currentLevelXP = (getCurrentLevel() - 1) * 200
        return (getCurrentLevel() * 200) - totalXP
    }
    
    func getRecentWorkouts(limit: Int = 5) -> [WorkoutRecord] {
        return Array(workoutHistory.prefix(limit))
    }
    
    func getTodayWorkouts() -> [WorkoutRecord] {
        let calendar = Calendar.current
        let today = Date()
        return workoutHistory.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    // MARK: - Appearance Mode
    
    private func applyAppearanceMode() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            switch self.appearanceMode {
            case .system:
                windowScene.windows.forEach { $0.overrideUserInterfaceStyle = .unspecified }
            case .light:
                windowScene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
            case .dark:
                windowScene.windows.forEach { $0.overrideUserInterfaceStyle = .dark }
            }
        }
    }
    
    // MARK: - Data Management
    
    func exportData() -> Data? {
        let exportData = ExportData(
            userName: userName,
            workoutHistory: workoutHistory,
            weeklyWorkoutGoal: weeklyWorkoutGoal,
            monthlyXPGoal: monthlyXPGoal
        )
        return try? JSONEncoder().encode(exportData)
    }
    
    func importData(_ data: Data) -> Bool {
        guard let importData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }
        
        userName = importData.userName
        workoutHistory = importData.workoutHistory
        weeklyWorkoutGoal = importData.weeklyWorkoutGoal
        monthlyXPGoal = importData.monthlyXPGoal
        
        return true
    }
    
    func clearAllData() {
        workoutHistory.removeAll()
        userName = "トレーニー"
    }
}

// MARK: - Export Data Model
struct ExportData: Codable {
    let userName: String
    let workoutHistory: [WorkoutRecord]
    let weeklyWorkoutGoal: Int
    let monthlyXPGoal: Int
}

// MARK: - WorkoutRecord Codable Extension
extension WorkoutRecord: Codable {
    enum CodingKeys: String, CodingKey {
        case id, exerciseName, category, sets, durationMinutes, xpEarned, date, details
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        id = UUID(uuidString: idString) ?? UUID()
        exerciseName = try container.decode(String.self, forKey: .exerciseName)
        category = try container.decode(ExerciseCategory.self, forKey: .category)
        sets = try container.decode(Int.self, forKey: .sets)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        xpEarned = try container.decode(Int.self, forKey: .xpEarned)
        date = try container.decode(Date.self, forKey: .date)
        details = try container.decodeIfPresent([WorkoutSetDetail].self, forKey: .details) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(exerciseName, forKey: .exerciseName)
        try container.encode(category, forKey: .category)
        try container.encode(sets, forKey: .sets)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(xpEarned, forKey: .xpEarned)
        try container.encode(date, forKey: .date)
        try container.encode(details, forKey: .details)
    }
}
