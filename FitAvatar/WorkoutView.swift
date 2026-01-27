//
//  WorkoutView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var filterViewModel = ExerciseFilterViewModel()
    @State private var showFilterSheet = false
    @State private var exercises = Exercise.sampleExercises

    var filteredExercises: [Exercise] {
        return filterViewModel.filteredAndSorted(exercises: exercises)
    }

    var groupedExercises: [(SubCategory, [Exercise])] {
        return filterViewModel.groupedBySubCategory(exercises: exercises)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: filterViewModel.filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(filterViewModel.filter.isActive ? .blue : .gray)
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView(filterViewModel: filterViewModel)
            }
        }
    }

    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("トレーニングを検索", text: $filterViewModel.filter.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !filterViewModel.filter.searchText.isEmpty {
                Button(action: {
                    filterViewModel.filter.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
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
                    isSelected: filterViewModel.filter.mainCategory == nil
                ) {
                    filterViewModel.filter.mainCategory = nil
                    filterViewModel.filter.subCategory = nil
                }

                // カテゴリ別ボタン
                ForEach(MainCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: filterViewModel.filter.mainCategory == category
                    ) {
                        if filterViewModel.filter.mainCategory == category {
                            filterViewModel.filter.mainCategory = nil
                            filterViewModel.filter.subCategory = nil
                        } else {
                            filterViewModel.filter.mainCategory = category
                            filterViewModel.filter.subCategory = nil
                        }
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
            if filterViewModel.sortOrder == .category {
                // カテゴリ別グループ表示
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(groupedExercises, id: \.0) { subCategory, exercises in
                        VStack(alignment: .leading, spacing: 10) {
                            // セクションヘッダー
                            Text(subCategory.rawValue)
                                .font(.headline)
                                .padding(.horizontal)

                            // エクササイズグリッド
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(exercises) { exercise in
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
                .padding(.top)
            } else {
                // 通常のグリッド表示
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
                .padding(.top)
            }
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
                        Label(exercise.mainCategory.rawValue, systemImage: exercise.mainCategory.icon)

                        if exercise.subCategory != .none {
                            Label(exercise.subCategory.rawValue, systemImage: "circle.fill")
                                .font(.caption)
                        }

                        Spacer()

                        Label(exercise.difficultyLevel.rawValue, systemImage: exercise.difficultyLevel.icon)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                // 詳細情報
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "器具", value: exercise.equipment.rawValue)
                    InfoRow(title: "場所", value: exercise.location.rawValue)
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

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
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
//
//  FilterView.swift
//  FitAvatar
//
//  Created by Claude on 2026/01/28.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var filterViewModel: ExerciseFilterViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                // 大カテゴリセクション
                Section(header: Text("大カテゴリ")) {
                    Picker("大カテゴリ", selection: $filterViewModel.filter.mainCategory) {
                        Text("全て").tag(nil as MainCategory?)
                        ForEach(MainCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category as MainCategory?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // 中カテゴリセクション
                if let mainCategory = filterViewModel.filter.mainCategory {
                    Section(header: Text("中カテゴリ")) {
                        Picker("中カテゴリ", selection: $filterViewModel.filter.subCategory) {
                            Text("全て").tag(nil as SubCategory?)
                            ForEach(mainCategory.subCategories, id: \.self) { subCategory in
                                if subCategory != .none {
                                    Text(subCategory.rawValue).tag(subCategory as SubCategory?)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                // 難易度セクション
                Section(header: Text("難易度")) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        MultiSelectRow(
                            title: level.rawValue,
                            icon: level.icon,
                            isSelected: filterViewModel.filter.difficultyLevels.contains(level)
                        ) {
                            if filterViewModel.filter.difficultyLevels.contains(level) {
                                filterViewModel.filter.difficultyLevels.remove(level)
                            } else {
                                filterViewModel.filter.difficultyLevels.insert(level)
                            }
                        }
                    }
                }

                // 器具セクション
                Section(header: Text("器具")) {
                    ForEach(EquipmentType.allCases, id: \.self) { equipment in
                        MultiSelectRow(
                            title: equipment.rawValue,
                            icon: "wrench.and.screwdriver",
                            isSelected: filterViewModel.filter.equipment.contains(equipment)
                        ) {
                            if filterViewModel.filter.equipment.contains(equipment) {
                                filterViewModel.filter.equipment.remove(equipment)
                            } else {
                                filterViewModel.filter.equipment.insert(equipment)
                            }
                        }
                    }
                }

                // 場所セクション
                Section(header: Text("場所")) {
                    ForEach(LocationType.allCases, id: \.self) { location in
                        MultiSelectRow(
                            title: location.rawValue,
                            icon: "location",
                            isSelected: filterViewModel.filter.location.contains(location)
                        ) {
                            if filterViewModel.filter.location.contains(location) {
                                filterViewModel.filter.location.remove(location)
                            } else {
                                filterViewModel.filter.location.insert(location)
                            }
                        }
                    }
                }

                // ソート順セクション
                Section(header: Text("並び替え")) {
                    Picker("並び替え", selection: $filterViewModel.sortOrder) {
                        Text(ExerciseSortOrder.category.displayName).tag(ExerciseSortOrder.category)
                        Text(ExerciseSortOrder.nameAscending.displayName).tag(ExerciseSortOrder.nameAscending)
                        Text(ExerciseSortOrder.difficultyAscending.displayName).tag(ExerciseSortOrder.difficultyAscending)
                        Text(ExerciseSortOrder.difficultyDescending.displayName).tag(ExerciseSortOrder.difficultyDescending)
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("リセット") {
                        filterViewModel.filter.reset()
                        filterViewModel.sortOrder = .category
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Multi Select Row
struct MultiSelectRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    FilterView(filterViewModel: ExerciseFilterViewModel())
}
