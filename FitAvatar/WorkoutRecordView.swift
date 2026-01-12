//
//  WorkoutRecordView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import SwiftUI
import UIKit

struct WorkoutRecordView: View {
    let exercise: Exercise
    let onWorkoutComplete: (() -> Void)?  // 完了時のコールバック
    @ObservedObject private var appData = AppData.shared
    @State private var sets: [WorkoutSet] = []
    @State private var currentSet = WorkoutSet()
    @State private var isTimerRunning = false
    @State private var isTimerEnabled = false  // インターバルタイマーのオン/オフ
    @State private var intervalDuration = 60  // 選択されたインターバル時間
    @State private var remainingTime = 60
    @State private var timer: Timer?
    @State private var showingCompletionAlert = false
    @Environment(\.dismiss) private var dismiss
    
    // デフォルトのイニシャライザ（コールバックなし）
    init(exercise: Exercise, onWorkoutComplete: (() -> Void)? = nil) {
        self.exercise = exercise
        self.onWorkoutComplete = onWorkoutComplete
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // エクササイズ情報ヘッダー
                exerciseHeaderSection
                
                // 現在のセット入力
                currentSetSection
                
                // セット追加ボタン
                addSetButton
                
                // 完了したセット一覧
                completedSetsSection
                
                // タイマーセクション（有酸素運動以外）
                if exercise.trainingType != .cardio {
                    timerSection
                }
                
                // ワークアウト完了ボタン
                completeWorkoutButton
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("トレーニング記録")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopTimer()
        }
        .alert("ワークアウト完了", isPresented: $showingCompletionAlert) {
            Button("OK") {
                // 記録画面を閉じる
                dismiss()
                // コールバックを呼び出す（詳細画面も閉じるため）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onWorkoutComplete?()
                }
            }
        } message: {
            Text("お疲れ様でした！トレーニングが記録されました。")
        }
    }
    
    // MARK: - Exercise Header Section
    private var exerciseHeaderSection: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: exercise.imageName)
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(exercise.targetMuscles.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Current Set Section
    private var currentSetSection: some View {
        VStack(spacing: 15) {
            Text("セット \(sets.count + 1)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            switch exercise.trainingType {
            case .weighted:
                weightedInputSection
            case .bodyweight:
                bodyweightInputSection
            case .timed:
                timedInputSection
            case .cardio:
                cardioInputSection
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Weighted Training Input (重量 × 回数)
    private var weightedInputSection: some View {
        HStack(spacing: 20) {
            VStack {
                Text("重量 (kg)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $currentSet.weight, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
            }
            
            VStack {
                Text("回数")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $currentSet.reps, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 80)
            }
        }
    }
    
    // MARK: - Bodyweight Training Input (回数のみ)
    private var bodyweightInputSection: some View {
        VStack {
            Text("回数")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("0", value: $currentSet.reps, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 120)
        }
    }
    
    // MARK: - Timed Training Input (時間のみ)
    private var timedInputSection: some View {
        VStack {
            Text("秒数")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("0", value: $currentSet.durationSeconds, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 120)
        }
    }
    
    // MARK: - Cardio Input (距離 × 時間)
    private var cardioInputSection: some View {
        HStack(spacing: 20) {
            VStack {
                Text("距離 (km)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $currentSet.distance, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
            }
            
            VStack {
                Text("時間 (分)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $currentSet.durationMinutes, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
            }
        }
    }
    
    // MARK: - Add Set Button
    private var addSetButton: some View {
        Button(action: addSet) {
            Text("セットを追加")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(currentSet.isValid ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
        .disabled(!currentSet.isValid)
    }
    
    // MARK: - Completed Sets Section
    private var completedSetsSection: some View {
        VStack(spacing: 10) {
            if !sets.isEmpty {
                Text("完了したセット")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(Array(sets.enumerated()), id: \.offset) { index, set in
                    CompletedSetRow(setNumber: index + 1, set: set, exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Timer Section
    private var timerSection: some View {
        VStack(spacing: 15) {
            // トグルヘッダー
            HStack {
                Text("インターバルタイマー")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $isTimerEnabled)
                    .labelsHidden()
                    .onChange(of: isTimerEnabled) { newValue in
                        if !newValue {
                            // オフにした時はタイマーを停止
                            stopTimer()
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // タイマーコントロール（オンの時のみ表示）
            if isTimerEnabled {
                VStack(spacing: 15) {
                    HStack(spacing: 20) {
                        // タイマー表示
                        Text(formatTime(remainingTime))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isTimerRunning ? .blue : .primary)
                        
                        Spacer()
                        
                        // タイマーコントロール
                        HStack(spacing: 15) {
                            Button(action: startTimer) {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.green)
                            }
                            .disabled(isTimerRunning)
                            
                            Button(action: stopTimer) {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.red)
                            }
                            .disabled(!isTimerRunning)
                            
                            Button(action: resetTimer) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.orange)
                            }
                        }
                        .font(.title2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // インターバル時間設定
                    HStack {
                        Text("インターバル時間:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Picker("", selection: $intervalDuration) {
                            Text("30秒").tag(30)
                            Text("60秒").tag(60)
                            Text("90秒").tag(90)
                            Text("120秒").tag(120)
                            Text("180秒").tag(180)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .disabled(isTimerRunning)
                        .onChange(of: intervalDuration) { newValue in
                            if !isTimerRunning {
                                remainingTime = newValue
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut, value: isTimerEnabled)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - Complete Workout Button
    private var completeWorkoutButton: some View {
        Button(action: completeWorkout) {
            Text("ワークアウト完了")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(sets.isEmpty ? Color.gray : Color.green)
                .cornerRadius(10)
        }
        .disabled(sets.isEmpty)
    }
    
    // MARK: - Helper Methods
    private func addSet() {
        sets.append(currentSet)
        currentSet = WorkoutSet()
        
        // セット完了時の振動フィードバック
        if appData.hapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        // インターバルタイマー自動開始（タイマーがオンで、有酸素運動以外の場合）
        if !sets.isEmpty && exercise.trainingType != .cardio && isTimerEnabled {
            resetTimer()
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopTimer()
                // タイマー終了時の通知
                if appData.hapticFeedback {
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                }
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        remainingTime = intervalDuration
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func completeWorkout() {
        // XP計算
        let baseXP = 15
        let setMultiplier = sets.count
        let difficultyMultiplier: Int = {
            switch exercise.difficultyLevel {
            case .beginner: return 1
            case .intermediate: return 2
            case .advanced: return 3
            }
        }()
        let totalXP = baseXP * setMultiplier * difficultyMultiplier
        
        // 総時間計算
        let totalMinutes: Int = {
            switch exercise.trainingType {
            case .cardio:
                return sets.reduce(0) { $0 + ($1.durationMinutes ?? 0) }
            case .timed:
                return sets.reduce(0) { $0 + (($1.durationSeconds ?? 0) / 60) }
            default:
                return sets.count * 2 // 1セットあたり2分と仮定
            }
        }()
        
        // WorkoutSetDetail配列を作成
        let details: [WorkoutSetDetail] = sets.map { set in
            WorkoutSetDetail(
                weight: set.weight,
                reps: set.reps,
                duration: set.durationSeconds,
                distance: set.distance
            )
        }
        
        // WorkoutRecordを作成して保存
        let record = WorkoutRecord(
            exerciseName: exercise.name,
            category: exercise.category,
            sets: sets.count,
            durationMinutes: totalMinutes,
            xpEarned: totalXP,
            date: Date(),
            details: details
        )
        
        appData.addWorkout(record)
        
        // 部位別ステータスにXPを追加
        let bodyParts = exercise.trainedBodyParts
        appData.addXPToStats(totalXP, for: bodyParts)
        
        // 完了時の振動フィードバック
        if appData.hapticFeedback {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
        
        showingCompletionAlert = true
    }
}

// MARK: - Workout Set Model
struct WorkoutSet {
    var weight: Double? = nil
    var reps: Int? = nil
    var durationSeconds: Int? = nil  // 秒
    var durationMinutes: Int? = nil  // 分（有酸素運動用）
    var distance: Double? = nil  // km
    
    var isValid: Bool {
        // 重量トレーニング
        if let weight = weight, weight > 0, let reps = reps, reps > 0 {
            return true
        }
        // 自重トレーニング
        if let reps = reps, reps > 0 {
            return true
        }
        // 時間制トレーニング
        if let duration = durationSeconds, duration > 0 {
            return true
        }
        // 有酸素運動
        if let duration = durationMinutes, duration > 0 {
            return true
        }
        if let distance = distance, distance > 0 {
            return true
        }
        return false
    }
}

// MARK: - Completed Set Row
struct CompletedSetRow: View {
    let setNumber: Int
    let set: WorkoutSet
    let exercise: Exercise
    
    var body: some View {
        HStack {
            Text("セット \(setNumber)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Text(setDescription)
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var setDescription: String {
        switch exercise.trainingType {
        case .weighted:
            if let weight = set.weight, let reps = set.reps {
                return String(format: "%.1fkg × %d回", weight, reps)
            }
        case .bodyweight:
            if let reps = set.reps {
                return "\(reps)回"
            }
        case .timed:
            if let duration = set.durationSeconds {
                return "\(duration)秒"
            }
        case .cardio:
            var parts: [String] = []
            if let distance = set.distance {
                parts.append(String(format: "%.1fkm", distance))
            }
            if let duration = set.durationMinutes {
                parts.append("\(duration)分")
            }
            return parts.joined(separator: " / ")
        }
        return ""
    }
}

#Preview {
    NavigationView {
        WorkoutRecordView(exercise: Exercise.sampleExercises[0])
    }
}
