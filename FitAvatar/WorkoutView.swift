//
//  WorkoutView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct WorkoutView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var exercises = Exercise.sampleExercises
    
    var filteredExercises: [Exercise] {
        var filtered = exercises
        
        // カテゴリフィルタ
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // 検索フィルタ
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.targetMuscles.joined().localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                searchSection
                
                // カテゴリフィルター
                categoryFilterSection
                
                // トレーニング一覧
                exerciseListSection
            }
            .navigationTitle("ワークアウト")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("トレーニングを検索", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - Category Filter Section
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 全て表示ボタン
                CategoryFilterButton(
                    title: "全て",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // カテゴリ別ボタン
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Exercise List Section
    private var exerciseListSection: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(filteredExercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        ExerciseCard(exercise: exercise)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ヘッダー（アイコンと難易度）
            HStack {
                Image(systemName: exercise.imageName)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: exercise.difficultyLevel.icon)
                    .font(.caption)
                    .foregroundColor(difficultyColor)
            }
            
            // トレーニング名
            Text(exercise.name)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            // 対象部位
            Text(exercise.targetMuscles.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // 最後に実施した日時
            if let lastPerformed = exercise.lastPerformed {
                Text("最終: \(formatDate(lastPerformed))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                Text("未実施")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 140)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var difficultyColor: Color {
        switch exercise.difficultyLevel {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Exercise Detail View
struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // エクササイズ情報
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(exercise.category.rawValue, systemImage: exercise.category.icon)
                        
                        Spacer()
                        
                        Label(exercise.difficultyLevel.rawValue, systemImage: exercise.difficultyLevel.icon)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                // 対象部位
                VStack(alignment: .leading, spacing: 8) {
                    Text("対象部位")
                        .font(.headline)
                    
                    FlowLayout(items: exercise.targetMuscles) { muscle in
                        Text(muscle)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                
                // 説明
                VStack(alignment: .leading, spacing: 8) {
                    Text("実施方法")
                        .font(.headline)
                    
                    Text(exercise.instructions)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 記録開始ボタン
                NavigationLink(
                    destination: WorkoutRecordView(
                        exercise: exercise,
                        onWorkoutComplete: {
                            // ワークアウト完了時に詳細画面も閉じる
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                dismiss()
                            }
                        }
                    )
                ) {
                    Text("トレーニングを開始")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Flow Layout (対象部位のタグ表示用)
struct FlowLayout<Data, Content>: View where Data: RandomAccessCollection, Content: View, Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(items.chunked(into: 3)), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                    Spacer()
                }
            }
        }
    }
}

extension RandomAccessCollection {
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        var currentChunk: [Element] = []
        
        for element in self {
            currentChunk.append(element)
            if currentChunk.count == size {
                chunks.append(currentChunk)
                currentChunk = []
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks
    }
}

#Preview {
    WorkoutView()
}
