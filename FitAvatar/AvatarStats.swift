//
//  AvatarStats.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import Foundation

// アバターの部位別ステータス
struct AvatarStats: Codable, Equatable {
    var arms: Int       // 腕
    var shoulders: Int  // 肩
    var abs: Int        // 腹筋
    var back: Int       // 背筋
    var legs: Int       // 足
    
    // デフォルト値
    init(arms: Int = 0, shoulders: Int = 0, abs: Int = 0, back: Int = 0, legs: Int = 0) {
        self.arms = arms
        self.shoulders = shoulders
        self.abs = abs
        self.back = back
        self.legs = legs
    }
    
    // 総合レベル（平均値）
    var overallLevel: Int {
        (arms + shoulders + abs + back + legs) / 5
    }
    
    // 各ステータスのレベル計算（100ポイントで1レベル）
    func getLevel(for stat: BodyPart) -> Int {
        let points = getPoints(for: stat)
        return points / 100 + 1
    }
    
    // 次のレベルまでの経験値
    func getXPToNextLevel(for stat: BodyPart) -> Int {
        let points = getPoints(for: stat)
        let currentLevelXP = (getLevel(for: stat) - 1) * 100
        return (getLevel(for: stat) * 100) - points
    }
    
    // レベル進捗（0.0〜1.0）
    func getLevelProgress(for stat: BodyPart) -> Double {
        let points = getPoints(for: stat)
        let currentLevelXP = (getLevel(for: stat) - 1) * 100
        let nextLevelXP = getLevel(for: stat) * 100
        let progress = Double(points - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return min(max(progress, 0), 1)
    }
    
    // 部位ごとのポイントを取得
    func getPoints(for part: BodyPart) -> Int {
        switch part {
        case .arms: return arms
        case .shoulders: return shoulders
        case .abs: return abs
        case .back: return back
        case .legs: return legs
        }
    }
    
    // ステータスを追加
    mutating func addXP(_ xp: Int, to parts: [BodyPart]) {
        for part in parts {
            switch part {
            case .arms: arms += xp
            case .shoulders: shoulders += xp
            case .abs: abs += xp
            case .back: back += xp
            case .legs: legs += xp
            }
        }
    }
    
    // レーダーチャート用のデータ（0.0〜1.0に正規化）
    func getRadarData() -> [RadarDataPoint] {
        // 最大値を取得（最低でも100に設定して、初期状態でも表示可能に）
        let maxPoints = max(arms, shoulders, abs, back, legs, 100)
        
        // 最小値を0.05に設定（完全に0だと見えないため）
        let minDisplayValue = 0.05
        
        return [
            RadarDataPoint(
                label: "腕",
                value: arms > 0 ? max(Double(arms) / Double(maxPoints), minDisplayValue) : minDisplayValue,
                part: .arms
            ),
            RadarDataPoint(
                label: "肩",
                value: shoulders > 0 ? max(Double(shoulders) / Double(maxPoints), minDisplayValue) : minDisplayValue,
                part: .shoulders
            ),
            RadarDataPoint(
                label: "腹筋",
                value: abs > 0 ? max(Double(abs) / Double(maxPoints), minDisplayValue) : minDisplayValue,
                part: .abs
            ),
            RadarDataPoint(
                label: "背筋",
                value: back > 0 ? max(Double(back) / Double(maxPoints), minDisplayValue) : minDisplayValue,
                part: .back
            ),
            RadarDataPoint(
                label: "足",
                value: legs > 0 ? max(Double(legs) / Double(maxPoints), minDisplayValue) : minDisplayValue,
                part: .legs
            )
        ]
    }
}

// 体の部位
enum BodyPart: String, Codable, CaseIterable {
    case arms = "腕"
    case shoulders = "肩"
    case abs = "腹筋"
    case back = "背筋"
    case legs = "足"
    
    var icon: String {
        switch self {
        case .arms: return "figure.arms.open"
        case .shoulders: return "figure.arms.open"
        case .abs: return "figure.core.workout"
        case .back: return "figure.strengthtraining.traditional"
        case .legs: return "figure.walk"
        }
    }
    
    var color: String {
        switch self {
        case .arms: return "blue"
        case .shoulders: return "purple"
        case .abs: return "orange"
        case .back: return "green"
        case .legs: return "red"
        }
    }
}

// レーダーチャート用のデータポイント
struct RadarDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double  // 0.0〜1.0
    let part: BodyPart
}

// エクササイズと部位のマッピング
extension Exercise {
    // このエクササイズで鍛えられる部位
    var trainedBodyParts: [BodyPart] {
        switch category {
        case .upperBody:
            // 上半身トレーニング
            if name.contains("プッシュアップ") || name.contains("ベンチプレス") {
                return [.arms, .shoulders]
            } else if name.contains("懸垂") {
                return [.arms, .back]
            } else {
                return [.arms, .shoulders]
            }
            
        case .lowerBody:
            // 下半身トレーニング
            return [.legs]
            
        case .core:
            // 体幹トレーニング
            return [.abs]
            
        case .cardio:
            // 有酸素運動（全身）
            return [.legs, .abs]
        }
    }
}
