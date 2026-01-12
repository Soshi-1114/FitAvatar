//
//  Exercise.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import Foundation

// トレーニング種目のモデル
struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: ExerciseCategory
    let targetMuscles: [String]
    let difficultyLevel: DifficultyLevel
    let instructions: String
    let imageName: String
    let lastPerformed: Date?
    
    init(name: String, category: ExerciseCategory, targetMuscles: [String], difficultyLevel: DifficultyLevel, instructions: String, imageName: String = "dumbbell", lastPerformed: Date? = nil) {
        self.name = name
        self.category = category
        self.targetMuscles = targetMuscles
        self.difficultyLevel = difficultyLevel
        self.instructions = instructions
        self.imageName = imageName
        self.lastPerformed = lastPerformed
    }
}

// カテゴリ分類
enum ExerciseCategory: String, CaseIterable {
    case upperBody = "上半身"
    case lowerBody = "下半身"
    case core = "体幹"
    case cardio = "有酸素"
    
    var icon: String {
        switch self {
        case .upperBody:
            return "figure.arms.open"
        case .lowerBody:
            return "figure.walk"
        case .core:
            return "figure.core.workout"
        case .cardio:
            return "heart.fill"
        }
    }
    
    var color: String {
        switch self {
        case .upperBody:
            return "blue"
        case .lowerBody:
            return "green"
        case .core:
            return "orange"
        case .cardio:
            return "red"
        }
    }
}

// 難易度レベル
enum DifficultyLevel: String, CaseIterable {
    case beginner = "初級"
    case intermediate = "中級"
    case advanced = "上級"
    
    var icon: String {
        switch self {
        case .beginner:
            return "1.circle.fill"
        case .intermediate:
            return "2.circle.fill"
        case .advanced:
            return "3.circle.fill"
        }
    }
}

// サンプルデータ
extension Exercise {
    static let sampleExercises: [Exercise] = [
        // 上半身
        Exercise(
            name: "プッシュアップ",
            category: .upperBody,
            targetMuscles: ["大胸筋", "三頭筋", "三角筋"],
            difficultyLevel: .beginner,
            instructions: "腕立て伏せの基本動作。胸を床に近づけるように上下運動を行います。",
            imageName: "figure.strengthtraining.traditional"
        ),
        Exercise(
            name: "ダンベルベンチプレス",
            category: .upperBody,
            targetMuscles: ["大胸筋", "三角筋", "三頭筋"],
            difficultyLevel: .intermediate,
            instructions: "ダンベルを使った胸筋トレーニング。ベンチに仰向けになり、ダンベルを上下に動かします。",
            imageName: "dumbbell"
        ),
        Exercise(
            name: "懸垂",
            category: .upperBody,
            targetMuscles: ["広背筋", "二頭筋"],
            difficultyLevel: .advanced,
            instructions: "バーにぶら下がり、胸をバーに近づけるように体を引き上げます。",
            imageName: "figure.strengthtraining.functional"
        ),
        
        // 下半身
        Exercise(
            name: "スクワット",
            category: .lowerBody,
            targetMuscles: ["大腿四頭筋", "大臀筋", "ハムストリング"],
            difficultyLevel: .beginner,
            instructions: "足を肩幅に開き、腰を落として立ち上がる動作を繰り返します。",
            imageName: "figure.strengthtraining.traditional"
        ),
        Exercise(
            name: "ランジ",
            category: .lowerBody,
            targetMuscles: ["大腿四頭筋", "大臀筋"],
            difficultyLevel: .intermediate,
            instructions: "片足を前に出し、膝を90度まで曲げてから元の位置に戻ります。",
            imageName: "figure.walk"
        ),
        Exercise(
            name: "デッドリフト",
            category: .lowerBody,
            targetMuscles: ["ハムストリング", "大臀筋", "広背筋"],
            difficultyLevel: .advanced,
            instructions: "バーベルを床から持ち上げる動作。背筋を伸ばし、腰に注意して行います。",
            imageName: "dumbbell"
        ),
        
        // 体幹
        Exercise(
            name: "プランク",
            category: .core,
            targetMuscles: ["腹直筋", "腹横筋"],
            difficultyLevel: .beginner,
            instructions: "うつ伏せになり、肘とつま先で体を支え、一直線の姿勢を保ちます。",
            imageName: "figure.core.workout"
        ),
        Exercise(
            name: "クランチ",
            category: .core,
            targetMuscles: ["腹直筋"],
            difficultyLevel: .beginner,
            instructions: "仰向けに寝て、膝を曲げた状態で上体を起こします。",
            imageName: "figure.core.workout"
        ),
        
        // 有酸素
        Exercise(
            name: "ランニング",
            category: .cardio,
            targetMuscles: ["全身"],
            difficultyLevel: .beginner,
            instructions: "一定のペースで走り続けます。心拍数を管理しながら行いましょう。",
            imageName: "figure.run"
        ),
        Exercise(
            name: "サイクリング",
            category: .cardio,
            targetMuscles: ["下半身", "心肺機能"],
            difficultyLevel: .intermediate,
            instructions: "自転車を使った有酸素運動。膝に負担をかけずに心肺機能を向上させます。",
            imageName: "bicycle"
        )
    ]
}