//
//  Exercise.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import Foundation
import SwiftUI

// トレーニング種目のモデル
struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let mainCategory: MainCategory
    let subCategory: SubCategory
    let targetMuscles: [String]
    let difficultyLevel: DifficultyLevel
    let instructions: String
    let imageName: String
    let equipment: EquipmentType
    let location: LocationType
    let lastPerformed: Date?

    init(name: String, mainCategory: MainCategory, subCategory: SubCategory, targetMuscles: [String], difficultyLevel: DifficultyLevel, instructions: String, imageName: String = "dumbbell", equipment: EquipmentType = .bodyweight, location: LocationType = .both, lastPerformed: Date? = nil) {
        self.name = name
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.targetMuscles = targetMuscles
        self.difficultyLevel = difficultyLevel
        self.instructions = instructions
        self.imageName = imageName
        self.equipment = equipment
        self.location = location
        self.lastPerformed = lastPerformed
    }
}

// 大カテゴリ
enum MainCategory: String, CaseIterable, Codable {
    case upperBody = "上半身"
    case lowerBody = "下半身"
    case core = "体幹"
    case cardio = "有酸素"
    case functional = "機能的トレーニング"
    case flexibility = "ストレッチ・柔軟性"

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
        case .functional:
            return "figure.strengthtraining.functional"
        case .flexibility:
            return "figure.flexibility"
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
        case .functional:
            return "purple"
        case .flexibility:
            return "pink"
        }
    }

    var subCategories: [SubCategory] {
        switch self {
        case .upperBody:
            return [.chest, .back, .shoulders, .arms, .forearms]
        case .lowerBody:
            return [.thighs, .glutes, .calves]
        case .core:
            return [.abs, .lowerBack]
        case .cardio:
            return [.running, .cycling, .swimming, .otherCardio]
        case .functional:
            return [.none]
        case .flexibility:
            return [.none]
        }
    }
}

// 中カテゴリ
enum SubCategory: String, CaseIterable {
    // 上半身
    case chest = "胸部"
    case back = "背部"
    case shoulders = "肩部"
    case arms = "腕部"
    case forearms = "前腕"

    // 下半身
    case thighs = "大腿部"
    case glutes = "臀部"
    case calves = "ふくらはぎ"

    // 体幹
    case abs = "腹部"
    case lowerBack = "下背部"

    // 有酸素
    case running = "ランニング系"
    case cycling = "サイクリング系"
    case swimming = "水泳"
    case otherCardio = "その他有酸素"

    // 中カテゴリが不要な場合
    case none = "なし"
}

// 器具の種類
enum EquipmentType: String, CaseIterable {
    case bodyweight = "自重"
    case dumbbell = "ダンベル"
    case barbell = "バーベル"
    case machine = "マシン"
    case cable = "ケーブル"
    case kettlebell = "ケトルベル"
    case bench = "ベンチ"
    case pullupBar = "懸垂バー"
    case other = "その他"
}

// 実施場所
enum LocationType: String, CaseIterable {
    case home = "自宅"
    case gym = "ジム"
    case outdoor = "屋外"
    case pool = "プール"
    case both = "自宅・ジム"
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
        // MARK: - 上半身（胸部）
        Exercise(
            name: "プッシュアップ",
            mainCategory: .upperBody,
            subCategory: .chest,
            targetMuscles: ["大胸筋", "三角筋前部", "上腕三頭筋"],
            difficultyLevel: .beginner,
            instructions: "床にうつ伏せになり、両手を肩幅よりやや広めに置く。体を一直線に保ちながら、肘を曲げて胸を床に近づけ、再び腕を伸ばして体を持ち上げる。大胸筋、三角筋前部、上腕三頭筋を鍛える。体幹の安定性も向上する。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "ベンチプレス",
            mainCategory: .upperBody,
            subCategory: .chest,
            targetMuscles: ["大胸筋", "三角筋前部", "上腕三頭筋"],
            difficultyLevel: .intermediate,
            instructions: "ベンチに仰向けに寝て、バーベルを肩幅よりやや広めに握る。バーを胸に下ろし、再び押し上げる。大胸筋、三角筋前部、上腕三頭筋を効果的に鍛える。上半身の押す力を向上させる。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .barbell,
            location: .gym
        ),
        Exercise(
            name: "ダンベルベンチプレス",
            mainCategory: .upperBody,
            subCategory: .chest,
            targetMuscles: ["大胸筋", "三角筋", "上腕三頭筋"],
            difficultyLevel: .intermediate,
            instructions: "ベンチに仰向けになり、両手にダンベルを持つ。ダンベルを胸の横から上方に押し上げ、ゆっくり下ろす。バーベルより可動域が広く、左右のバランス調整にも効果的。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "ダンベルフライ",
            mainCategory: .upperBody,
            subCategory: .chest,
            targetMuscles: ["大胸筋"],
            difficultyLevel: .intermediate,
            instructions: "ベンチに仰向けになり、両手にダンベルを持って腕を広げる。胸を張りながら、弧を描くようにダンベルを上方で合わせる。大胸筋のストレッチと収縮を強調し、胸部の厚みを増す。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "ディップス",
            mainCategory: .upperBody,
            subCategory: .chest,
            targetMuscles: ["大胸筋下部", "上腕三頭筋", "三角筋前部"],
            difficultyLevel: .intermediate,
            instructions: "平行棒やディップスバーを両手で握り、体を浮かせる。肘を曲げて体を下ろし、再び押し上げる。大胸筋下部、上腕三頭筋、肩の前部を強化する。",
            imageName: "figure.strengthtraining.functional",
            equipment: .other,
            location: .both
        ),

        // MARK: - 上半身（背部）
        Exercise(
            name: "懸垂",
            mainCategory: .upperBody,
            subCategory: .back,
            targetMuscles: ["広背筋", "僧帽筋", "上腕二頭筋"],
            difficultyLevel: .intermediate,
            instructions: "バーにぶら下がり、肩甲骨を寄せながら体を引き上げ、顎をバーの上に持っていく。ゆっくり下ろす。広背筋、僧帽筋、上腕二頭筋を鍛える。背中の幅と厚みを増す。",
            imageName: "figure.strengthtraining.functional",
            equipment: .pullupBar,
            location: .both
        ),
        Exercise(
            name: "ラットプルダウン",
            mainCategory: .upperBody,
            subCategory: .back,
            targetMuscles: ["広背筋", "僧帽筋", "上腕二頭筋"],
            difficultyLevel: .beginner,
            instructions: "マシンに座り、バーを肩幅より広めに握る。バーを胸の上部に向かって引き下ろし、ゆっくり戻す。懸垂ができない人でも背中を効果的に鍛えられる。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .machine,
            location: .gym
        ),
        Exercise(
            name: "デッドリフト",
            mainCategory: .upperBody,
            subCategory: .back,
            targetMuscles: ["広背筋", "脊柱起立筋", "大臀筋", "ハムストリング"],
            difficultyLevel: .advanced,
            instructions: "バーベルを床に置き、足を腰幅に開いて立つ。背筋を伸ばしたまま腰を落とし、バーを握って立ち上がる。全身の筋肉を鍛える。筋力向上に非常に効果的。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .barbell,
            location: .gym
        ),
        Exercise(
            name: "ベントオーバーロウ",
            mainCategory: .upperBody,
            subCategory: .back,
            targetMuscles: ["広背筋", "僧帽筋", "脊柱起立筋"],
            difficultyLevel: .intermediate,
            instructions: "バーベルを持ち、膝を軽く曲げて上体を前傾させる。バーをお腹に向かって引き上げ、ゆっくり下ろす。背中の厚みを増す。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .barbell,
            location: .gym
        ),
        Exercise(
            name: "ダンベルロウ",
            mainCategory: .upperBody,
            subCategory: .back,
            targetMuscles: ["広背筋", "僧帽筋", "三角筋後部"],
            difficultyLevel: .beginner,
            instructions: "ベンチに片手と片膝をつき、もう一方の手でダンベルを持つ。肘を後方に引き上げ、ダンベルを体側に引き寄せる。左右の筋力バランスを整える。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "シーテッドロウ",
            mainCategory: .upperBody,
            subCategory: .back,
            targetMuscles: ["広背筋", "僧帽筋", "三角筋後部"],
            difficultyLevel: .beginner,
            instructions: "ローイングマシンに座り、ケーブルのハンドルを握る。肩甲骨を寄せながら体側に引き寄せ、ゆっくり戻す。姿勢改善にも効果的。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .cable,
            location: .gym
        ),

        // MARK: - 上半身（肩部）
        Exercise(
            name: "ショルダープレス",
            mainCategory: .upperBody,
            subCategory: .shoulders,
            targetMuscles: ["三角筋", "上腕三頭筋"],
            difficultyLevel: .beginner,
            instructions: "ダンベルまたはバーベルを肩の高さで持ち、頭上に押し上げ、ゆっくり下ろす。三角筋全体を鍛え、肩幅を広くする。上半身の押す力を向上させる。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "サイドレイズ",
            mainCategory: .upperBody,
            subCategory: .shoulders,
            targetMuscles: ["三角筋中部"],
            difficultyLevel: .beginner,
            instructions: "両手にダンベルを持ち、体の横で腕を伸ばす。肩の高さまで腕を横に上げ、ゆっくり下ろす。三角筋中部を集中的に鍛える。肩幅を広く見せる効果がある。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "フロントレイズ",
            mainCategory: .upperBody,
            subCategory: .shoulders,
            targetMuscles: ["三角筋前部"],
            difficultyLevel: .beginner,
            instructions: "ダンベルまたはプレートを体の前で持ち、腕を前方に肩の高さまで上げ、ゆっくり下ろす。三角筋前部を鍛える。肩の前面を発達させる。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "リアレイズ",
            mainCategory: .upperBody,
            subCategory: .shoulders,
            targetMuscles: ["三角筋後部", "僧帽筋"],
            difficultyLevel: .beginner,
            instructions: "上体を前傾させ、ダンベルを持って腕を後方に開く。肩甲骨を寄せながら肩の高さまで上げる。姿勢改善にも効果的。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),

        // MARK: - 上半身（腕部）
        Exercise(
            name: "ダンベルカール",
            mainCategory: .upperBody,
            subCategory: .arms,
            targetMuscles: ["上腕二頭筋"],
            difficultyLevel: .beginner,
            instructions: "両手にダンベルを持ち、肘を固定したまま腕を曲げてダンベルを肩に近づけ、ゆっくり下ろす。上腕二頭筋を鍛える。腕の前面を太くする。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "ハンマーカール",
            mainCategory: .upperBody,
            subCategory: .arms,
            targetMuscles: ["上腕二頭筋", "上腕筋", "前腕"],
            difficultyLevel: .beginner,
            instructions: "ダンベルを縦に持ち（親指が上）、肘を曲げて持ち上げ、ゆっくり下ろす。上腕二頭筋、上腕筋、前腕を鍛える。腕の厚みを増す。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "トライセプスエクステンション",
            mainCategory: .upperBody,
            subCategory: .arms,
            targetMuscles: ["上腕三頭筋"],
            difficultyLevel: .beginner,
            instructions: "ダンベルまたはバーベルを頭上で持ち、肘を固定したまま肘を曲げて頭の後ろに下ろし、再び伸ばす。上腕三頭筋を集中的に鍛える。腕の後ろ側を引き締める。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "トライセプスプッシュダウン",
            mainCategory: .upperBody,
            subCategory: .arms,
            targetMuscles: ["上腕三頭筋"],
            difficultyLevel: .beginner,
            instructions: "ケーブルマシンのハンドルを握り、肘を体の横に固定したまま腕を下方に押し下げ、ゆっくり戻す。上腕三頭筋を鍛える。腕の後ろ側を引き締め、形を整える。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .cable,
            location: .gym
        ),
        Exercise(
            name: "リストカール",
            mainCategory: .upperBody,
            subCategory: .forearms,
            targetMuscles: ["前腕屈筋群"],
            difficultyLevel: .beginner,
            instructions: "ダンベルやバーベルを握り、前腕をベンチや膝に固定したまま、手首だけを曲げて持ち上げる。前腕屈筋群を鍛える。握力を向上させる。",
            imageName: "dumbbell",
            equipment: .dumbbell,
            location: .both
        ),

        // MARK: - 下半身（大腿部・臀部）
        Exercise(
            name: "スクワット",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋", "大臀筋", "ハムストリング"],
            difficultyLevel: .beginner,
            instructions: "足を肩幅に開き、背筋を伸ばしたまま腰を後ろに引きながら膝を曲げて腰を落とし、立ち上がる。下半身全体の筋力向上と基礎代謝の向上。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "バーベルスクワット",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋", "大臀筋", "ハムストリング", "体幹"],
            difficultyLevel: .intermediate,
            instructions: "バーベルを肩に担ぎ、足を肩幅に開いてスクワットを行う。全身の筋力向上に非常に効果的。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .barbell,
            location: .gym
        ),
        Exercise(
            name: "フロントスクワット",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋", "体幹"],
            difficultyLevel: .intermediate,
            instructions: "バーベルを体の前、肩の前面で保持してスクワットを行う。大腿四頭筋をより強調して鍛える。体幹の安定性も向上する。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .barbell,
            location: .gym
        ),
        Exercise(
            name: "ランジ",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋", "大臀筋", "ハムストリング"],
            difficultyLevel: .beginner,
            instructions: "片足を前に大きく踏み出し、両膝を90度まで曲げて腰を落とし、元の位置に戻る。左右交互に行う。バランス能力も向上する。",
            imageName: "figure.walk",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "ブルガリアンスクワット",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋", "大臀筋"],
            difficultyLevel: .intermediate,
            instructions: "片足をベンチや台の上に乗せ、もう片方の足でスクワットを行う。片足ずつ集中的に鍛える。バランス能力も向上する。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .bench,
            location: .both
        ),
        Exercise(
            name: "レッグプレス",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋", "大臀筋", "ハムストリング"],
            difficultyLevel: .beginner,
            instructions: "マシンに座り、足をプレート板に置いて押し出し、ゆっくり戻す。安全に高重量を扱いやすい。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .machine,
            location: .gym
        ),
        Exercise(
            name: "レッグエクステンション",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["大腿四頭筋"],
            difficultyLevel: .beginner,
            instructions: "マシンに座り、足首にパッドをかけて膝を伸ばし、ゆっくり戻す。大腿四頭筋を集中的に鍛える。膝周りの筋力を強化する。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .machine,
            location: .gym
        ),
        Exercise(
            name: "レッグカール",
            mainCategory: .lowerBody,
            subCategory: .thighs,
            targetMuscles: ["ハムストリング"],
            difficultyLevel: .beginner,
            instructions: "マシンにうつ伏せになり、足首にパッドをかけて膝を曲げ、ゆっくり戻す。ハムストリングを集中的に鍛える。膝の安定性を向上させる。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .machine,
            location: .gym
        ),
        Exercise(
            name: "ヒップスラスト",
            mainCategory: .lowerBody,
            subCategory: .glutes,
            targetMuscles: ["大臀筋"],
            difficultyLevel: .beginner,
            instructions: "ベンチに背中の上部を乗せ、バーベルを腰に乗せて臀部を上下させる。大臀筋を集中的に鍛える。ヒップアップに非常に効果的。",
            imageName: "figure.strengthtraining.traditional",
            equipment: .barbell,
            location: .gym
        ),

        // MARK: - 下半身（ふくらはぎ）
        Exercise(
            name: "カーフレイズ",
            mainCategory: .lowerBody,
            subCategory: .calves,
            targetMuscles: ["腓腹筋", "ヒラメ筋"],
            difficultyLevel: .beginner,
            instructions: "つま先立ちになってかかとを上げ、ゆっくり下ろす。段差を使うとさらに効果的。ふくらはぎを引き締める。",
            imageName: "figure.walk",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "シーテッドカーフレイズ",
            mainCategory: .lowerBody,
            subCategory: .calves,
            targetMuscles: ["ヒラメ筋"],
            difficultyLevel: .beginner,
            instructions: "椅子に座り、膝の上に重りを乗せてかかとを上下させる。ヒラメ筋を集中的に鍛える。ふくらはぎの厚みを増す。",
            imageName: "figure.walk",
            equipment: .dumbbell,
            location: .both
        ),

        // MARK: - 体幹（腹部）
        Exercise(
            name: "プランク",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹直筋", "腹横筋", "腹斜筋"],
            difficultyLevel: .beginner,
            instructions: "うつ伏せになり、肘とつま先で体を支え、体を一直線に保つ。その姿勢をキープする。体幹の安定性を向上させる。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "サイドプランク",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹斜筋"],
            difficultyLevel: .beginner,
            instructions: "横向きに寝て、肘と足の側面で体を支え、体を一直線に保つ。腹斜筋を集中的に鍛える。体幹の側面の安定性を向上させる。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "クランチ",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹直筋"],
            difficultyLevel: .beginner,
            instructions: "仰向けに寝て膝を曲げ、手を頭の後ろに置く。肩甲骨を床から離すように上体を起こす。腹直筋を鍛える。お腹を引き締める。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "シットアップ",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹直筋", "腸腰筋"],
            difficultyLevel: .beginner,
            instructions: "仰向けに寝て膝を曲げ、完全に上体を起こして膝にタッチし、ゆっくり戻る。腹直筋、腸腰筋を鍛える。腹筋全体を強化する。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "レッグレイズ",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹直筋下部", "腸腰筋"],
            difficultyLevel: .beginner,
            instructions: "仰向けに寝て、脚を伸ばしたまま床から持ち上げ、ゆっくり下ろす。床につく直前で止める。下腹部を引き締める。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "バイシクルクランチ",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹直筋", "腹斜筋"],
            difficultyLevel: .beginner,
            instructions: "仰向けに寝て、自転車をこぐように脚を動かしながら、対角の肘と膝を近づける。腹直筋、腹斜筋を同時に鍛える。お腹全体を引き締める。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "ロシアンツイスト",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹斜筋"],
            difficultyLevel: .beginner,
            instructions: "座った状態で上体を後ろに傾け、足を浮かせる。両手を合わせて左右にツイストする。腹斜筋を集中的に鍛える。くびれを作る。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "マウンテンクライマー",
            mainCategory: .core,
            subCategory: .abs,
            targetMuscles: ["腹筋", "体幹", "全身"],
            difficultyLevel: .beginner,
            instructions: "プランクの姿勢から、膝を胸に引き寄せる動作を左右交互に素早く繰り返す。腹筋、体幹、有酸素運動の効果も得られる。全身の引き締めに効果的。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),

        // MARK: - 体幹（背部・下背部）
        Exercise(
            name: "バックエクステンション",
            mainCategory: .core,
            subCategory: .lowerBack,
            targetMuscles: ["脊柱起立筋"],
            difficultyLevel: .beginner,
            instructions: "うつ伏せになり、上体を反らして持ち上げ、ゆっくり戻す。脊柱起立筋を鍛える。姿勢改善、腰痛予防に効果的。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "スーパーマン",
            mainCategory: .core,
            subCategory: .lowerBack,
            targetMuscles: ["脊柱起立筋", "臀筋", "ハムストリング"],
            difficultyLevel: .beginner,
            instructions: "うつ伏せになり、両手両足を同時に浮かせて伸ばし、数秒キープして戻す。脊柱起立筋、臀筋、ハムストリングを鍛える。背面全体を強化する。",
            imageName: "figure.core.workout",
            equipment: .bodyweight,
            location: .both
        ),

        // MARK: - 有酸素運動
        Exercise(
            name: "ランニング",
            mainCategory: .cardio,
            subCategory: .running,
            targetMuscles: ["全身", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "一定のペースで走り続ける。初心者はゆっくりとしたペースから始める。心肺機能の向上、脂肪燃焼、持久力の向上。",
            imageName: "figure.run",
            equipment: .bodyweight,
            location: .outdoor
        ),
        Exercise(
            name: "ジョギング",
            mainCategory: .cardio,
            subCategory: .running,
            targetMuscles: ["全身", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "ランニングよりもゆっくりとしたペースで走る。会話ができる程度のペースが目安。脂肪燃焼、心肺機能の向上。ランニングよりも関節への負担が少ない。",
            imageName: "figure.run",
            equipment: .bodyweight,
            location: .outdoor
        ),
        Exercise(
            name: "ウォーキング",
            mainCategory: .cardio,
            subCategory: .running,
            targetMuscles: ["全身", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "速めのペースで歩く。腕を振りながらしっかりと歩幅を取る。脂肪燃焼、心肺機能の向上。関節への負担が最も少ない。",
            imageName: "figure.walk",
            equipment: .bodyweight,
            location: .outdoor
        ),
        Exercise(
            name: "サイクリング",
            mainCategory: .cardio,
            subCategory: .cycling,
            targetMuscles: ["下半身", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "自転車またはエアロバイクを一定のペースでこぐ。下半身の筋力向上、心肺機能の向上、脂肪燃焼。膝への負担が少ない。",
            imageName: "bicycle",
            equipment: .other,
            location: .both
        ),
        Exercise(
            name: "水泳",
            mainCategory: .cardio,
            subCategory: .swimming,
            targetMuscles: ["全身", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "クロール、平泳ぎ、背泳ぎなど様々な泳法で泳ぐ。全身の筋肉を使い、心肺機能を向上させる。関節への負担が非常に少ない。",
            imageName: "figure.pool.swim",
            equipment: .bodyweight,
            location: .pool
        ),
        Exercise(
            name: "ローイング",
            mainCategory: .cardio,
            subCategory: .otherCardio,
            targetMuscles: ["全身", "背中", "脚", "体幹"],
            difficultyLevel: .beginner,
            instructions: "ローイングマシンを使い、座った状態で漕ぐ動作を繰り返す。全身の筋肉を使い、心肺機能を向上させる。背中、脚、体幹を同時に鍛える。",
            imageName: "figure.rowing",
            equipment: .machine,
            location: .gym
        ),
        Exercise(
            name: "ステップマシン",
            mainCategory: .cardio,
            subCategory: .otherCardio,
            targetMuscles: ["下半身", "臀筋", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "階段を上るような動作を繰り返すマシンで運動する。下半身の筋力向上、心肺機能の向上、脂肪燃焼。臀筋に効果的。",
            imageName: "figure.stairs",
            equipment: .machine,
            location: .gym
        ),
        Exercise(
            name: "縄跳び",
            mainCategory: .cardio,
            subCategory: .otherCardio,
            targetMuscles: ["全身", "心肺機能", "瞬発力"],
            difficultyLevel: .intermediate,
            instructions: "縄跳びを使って連続でジャンプする。様々なバリエーションがある。心肺機能の向上、脂肪燃焼、瞬発力の向上。短時間で高い運動効果が得られる。",
            imageName: "figure.jumprope",
            equipment: .other,
            location: .both
        ),
        Exercise(
            name: "エリプティカルトレーナー",
            mainCategory: .cardio,
            subCategory: .otherCardio,
            targetMuscles: ["全身", "心肺機能"],
            difficultyLevel: .beginner,
            instructions: "楕円軌道を描くように足を動かすマシンで運動する。全身の有酸素運動。膝や足首への衝撃が少ない。",
            imageName: "figure.elliptical",
            equipment: .machine,
            location: .gym
        ),

        // MARK: - 機能的トレーニング
        Exercise(
            name: "バーピー",
            mainCategory: .functional,
            subCategory: .none,
            targetMuscles: ["全身", "心肺機能", "瞬発力"],
            difficultyLevel: .intermediate,
            instructions: "立った状態からしゃがみ、両手を地面につけて脚を後ろに伸ばし（プランク）、再び脚を戻してジャンプする。全身の筋力、心肺機能、瞬発力を同時に鍛える。脂肪燃焼効果が非常に高い。",
            imageName: "figure.strengthtraining.functional",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "ケトルベルスイング",
            mainCategory: .functional,
            subCategory: .none,
            targetMuscles: ["臀筋", "ハムストリング", "体幹", "肩"],
            difficultyLevel: .intermediate,
            instructions: "ケトルベルを両手で持ち、腰の力を使って前方に振り上げる。臀筋、ハムストリング、体幹、肩を鍛える。爆発的なパワーを養う。",
            imageName: "figure.strengthtraining.functional",
            equipment: .kettlebell,
            location: .both
        ),
        Exercise(
            name: "ボックスジャンプ",
            mainCategory: .functional,
            subCategory: .none,
            targetMuscles: ["下半身", "瞬発力"],
            difficultyLevel: .intermediate,
            instructions: "ボックスや台の上に両足でジャンプして飛び乗り、ステップで降りる。下半身の爆発的なパワー、瞬発力を鍛える。ジャンプ力の向上。",
            imageName: "figure.strengthtraining.functional",
            equipment: .other,
            location: .both
        ),
        Exercise(
            name: "ファーマーズウォーク",
            mainCategory: .functional,
            subCategory: .none,
            targetMuscles: ["握力", "前腕", "体幹", "肩", "脚"],
            difficultyLevel: .intermediate,
            instructions: "両手に重いダンベルやケトルベルを持って歩く。握力、前腕、体幹、肩、脚を鍛える。機能的な筋力を向上させる。",
            imageName: "figure.walk",
            equipment: .dumbbell,
            location: .both
        ),
        Exercise(
            name: "ウォールボール",
            mainCategory: .functional,
            subCategory: .none,
            targetMuscles: ["下半身", "肩", "体幹", "心肺機能"],
            difficultyLevel: .intermediate,
            instructions: "メディシンボールを持ってスクワットし、立ち上がる勢いでボールを壁に投げ、キャッチして繰り返す。下半身、肩、体幹、心肺機能を同時に鍛える。全身の協調性を向上させる。",
            imageName: "figure.strengthtraining.functional",
            equipment: .other,
            location: .gym
        ),

        // MARK: - ストレッチ・柔軟性
        Exercise(
            name: "ヨガ",
            mainCategory: .flexibility,
            subCategory: .none,
            targetMuscles: ["全身", "柔軟性", "体幹"],
            difficultyLevel: .beginner,
            instructions: "様々なポーズを取りながら、呼吸と身体の動きを連動させる。柔軟性の向上、体幹の強化、ストレス軽減、姿勢改善。",
            imageName: "figure.yoga",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "ダイナミックストレッチ",
            mainCategory: .flexibility,
            subCategory: .none,
            targetMuscles: ["全身", "柔軟性"],
            difficultyLevel: .beginner,
            instructions: "動きながら筋肉を伸ばすストレッチ。レッグスイング、アームサークルなど。運動前のウォームアップに効果的。関節の可動域を広げ、怪我を予防する。",
            imageName: "figure.flexibility",
            equipment: .bodyweight,
            location: .both
        ),
        Exercise(
            name: "スタティックストレッチ",
            mainCategory: .flexibility,
            subCategory: .none,
            targetMuscles: ["全身", "柔軟性"],
            difficultyLevel: .beginner,
            instructions: "静止した状態で筋肉を伸ばし、一定時間キープする。柔軟性の向上、筋肉の緊張をほぐす。運動後のクールダウンに効果的。",
            imageName: "figure.flexibility",
            equipment: .bodyweight,
            location: .both
        )
    ]
}
// MARK: - Exercise Filter

// フィルター状態を管理する構造体
struct ExerciseFilter {
    var mainCategory: MainCategory?
    var subCategory: SubCategory?
    var difficultyLevels: Set<DifficultyLevel>
    var targetMuscles: Set<String>
    var equipment: Set<EquipmentType>
    var location: Set<LocationType>
    var searchText: String

    init(
        mainCategory: MainCategory? = nil,
        subCategory: SubCategory? = nil,
        difficultyLevels: Set<DifficultyLevel> = [],
        targetMuscles: Set<String> = [],
        equipment: Set<EquipmentType> = [],
        location: Set<LocationType> = [],
        searchText: String = ""
    ) {
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.difficultyLevels = difficultyLevels
        self.targetMuscles = targetMuscles
        self.equipment = equipment
        self.location = location
        self.searchText = searchText
    }

    // フィルター条件に一致するか判定
    func matches(_ exercise: Exercise) -> Bool {
        // 大カテゴリフィルター
        if let mainCategory = mainCategory, exercise.mainCategory != mainCategory {
            return false
        }

        // 中カテゴリフィルター
        if let subCategory = subCategory, exercise.subCategory != subCategory {
            return false
        }

        // 難易度フィルター
        if !difficultyLevels.isEmpty && !difficultyLevels.contains(exercise.difficultyLevel) {
            return false
        }

        // 部位フィルター（targetMusclesのいずれかが一致すればOK）
        if !targetMuscles.isEmpty {
            let hasMatchingMuscle = exercise.targetMuscles.contains { muscle in
                targetMuscles.contains(muscle)
            }
            if !hasMatchingMuscle {
                return false
            }
        }

        // 器具フィルター
        if !equipment.isEmpty && !equipment.contains(exercise.equipment) {
            return false
        }

        // 場所フィルター（bothは全てにマッチ）
        if !location.isEmpty {
            let matchesLocation = location.contains(exercise.location) || exercise.location == .both
            if !matchesLocation {
                return false
            }
        }

        // 検索テキストフィルター
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            let nameMatches = exercise.name.lowercased().contains(lowercasedSearch)
            let musclesMatch = exercise.targetMuscles.contains { muscle in
                muscle.lowercased().contains(lowercasedSearch)
            }
            if !nameMatches && !musclesMatch {
                return false
            }
        }

        return true
    }

    // フィルターがアクティブかどうか
    var isActive: Bool {
        return mainCategory != nil ||
               subCategory != nil ||
               !difficultyLevels.isEmpty ||
               !targetMuscles.isEmpty ||
               !equipment.isEmpty ||
               !location.isEmpty ||
               !searchText.isEmpty
    }

    // フィルターをリセット
    mutating func reset() {
        mainCategory = nil
        subCategory = nil
        difficultyLevels.removeAll()
        targetMuscles.removeAll()
        equipment.removeAll()
        location.removeAll()
        searchText = ""
    }
}

// ソート順を定義
enum ExerciseSortOrder {
    case nameAscending      // 名前昇順（あいうえお順）
    case nameDescending     // 名前降順
    case difficultyAscending  // 難易度昇順（初級→上級）
    case difficultyDescending // 難易度降順（上級→初級）
    case recent             // 最近実施した順
    case category           // カテゴリ順

    var displayName: String {
        switch self {
        case .nameAscending:
            return "名前順（あ→ん）"
        case .nameDescending:
            return "名前順（ん→あ）"
        case .difficultyAscending:
            return "難易度順（易→難）"
        case .difficultyDescending:
            return "難易度順（難→易）"
        case .recent:
            return "最近実施した順"
        case .category:
            return "カテゴリ順"
        }
    }

    // ソート関数
    func sort(_ exercises: [Exercise]) -> [Exercise] {
        switch self {
        case .nameAscending:
            return exercises.sorted { $0.name < $1.name }
        case .nameDescending:
            return exercises.sorted { $0.name > $1.name }
        case .difficultyAscending:
            return exercises.sorted { $0.difficultyLevel.rawValue < $1.difficultyLevel.rawValue }
        case .difficultyDescending:
            return exercises.sorted { $0.difficultyLevel.rawValue > $1.difficultyLevel.rawValue }
        case .recent:
            return exercises.sorted { exercise1, exercise2 in
                guard let date1 = exercise1.lastPerformed else { return false }
                guard let date2 = exercise2.lastPerformed else { return true }
                return date1 > date2
            }
        case .category:
            return exercises.sorted { exercise1, exercise2 in
                if exercise1.mainCategory.rawValue != exercise2.mainCategory.rawValue {
                    return exercise1.mainCategory.rawValue < exercise2.mainCategory.rawValue
                }
                return exercise1.subCategory.rawValue < exercise2.subCategory.rawValue
            }
        }
    }
}

// フィルターとソートを統合したViewModel
class ExerciseFilterViewModel: ObservableObject {
    @Published var filter = ExerciseFilter()
    @Published var sortOrder: ExerciseSortOrder = .category

    // フィルター＆ソート済みの種目リストを返す
    func filteredAndSorted(exercises: [Exercise]) -> [Exercise] {
        let filtered = exercises.filter { filter.matches($0) }
        return sortOrder.sort(filtered)
    }

    // カテゴリ別にグループ化
    func groupedBySubCategory(exercises: [Exercise]) -> [(SubCategory, [Exercise])] {
        let filtered = exercises.filter { filter.matches($0) }
        let sorted = sortOrder.sort(filtered)

        let grouped = Dictionary(grouping: sorted) { $0.subCategory }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }
}
