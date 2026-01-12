//
//  WorkoutRecordView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import SwiftUI

struct WorkoutRecordView: View {
    let exercise: Exercise
    @State private var sets: [WorkoutSet] = []
    @State private var currentSet = WorkoutSet()
    @State private var isTimerRunning = false
    @State private var remainingTime = 60
    @State private var timer: Timer?
    @State private var showingCompletionAlert = false
    @Environment(\.presentationMode) var presentationMode
    
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
                
                // タイマーセクション
                timerSection
                
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
                presentationMode.wrappedValue.dismiss()
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
            
            if exercise.category == .cardio {
                // 有酸素運動の場合
                cardioInputSection
            } else {
                // 筋力トレーニングの場合
                strengthInputSection
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Strength Training Input
    private var strengthInputSection: some View {
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
    
    // MARK: - Cardio Input
    private var cardioInputSection: some View {
        HStack(spacing: 20) {
            VStack {
                Text("時間 (分)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $currentSet.duration, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 80)
            }
            
            VStack {
                Text("距離 (km)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $currentSet.distance, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
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
            Text("インターバル")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
        }
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
        
        // セット完了時の音声フィードバック（振動）
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // インターバルタイマー自動開始
        if !sets.isEmpty {
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
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
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
        remainingTime = 60
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func completeWorkout() {
        // ここで実際のデータ保存処理を実装
        // Core Dataやその他のデータストレージに保存
        showingCompletionAlert = true
    }
}

// MARK: - Workout Set Model
struct WorkoutSet {
    var weight: Double = 0
    var reps: Int = 0
    var duration: Int = 0  // 分
    var distance: Double = 0  // km
    
    var isValid: Bool {
        return (weight > 0 && reps > 0) || (duration > 0 || distance > 0)
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
            
            if exercise.category == .cardio {
                // 有酸素運動の表示
                if set.duration > 0 {
                    Text("\(set.duration)分")
                }
                if set.distance > 0 {
                    Text("\(set.distance, specifier: "%.1f")km")
                }
            } else {
                // 筋力トレーニングの表示
                Text("\(set.weight, specifier: "%.1f")kg × \(set.reps)回")
            }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        WorkoutRecordView(exercise: Exercise.sampleExercises[0])
    }
}