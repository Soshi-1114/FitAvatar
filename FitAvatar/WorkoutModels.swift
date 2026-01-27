//
//  WorkoutModels.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import Foundation

// MARK: - Time Period Enum
enum TimePeriod: String, CaseIterable, Codable {
    case week = "週"
    case month = "月"
    case year = "年"
}

// MARK: - Day Data
struct DayData: Codable {
    let day: String
    let count: Int
}

// MARK: - Workout Record Model
struct WorkoutRecord: Identifiable {
    let id: UUID
    let exerciseName: String
    let category: ExerciseCategory
    let sets: Int
    let durationMinutes: Int
    let xpEarned: Int
    let date: Date
    let details: [WorkoutSetDetail]
    
    init(id: UUID = UUID(), exerciseName: String, category: ExerciseCategory, sets: Int, durationMinutes: Int, xpEarned: Int, date: Date, details: [WorkoutSetDetail] = []) {
        self.id = id
        self.exerciseName = exerciseName
        self.category = category
        self.sets = sets
        self.durationMinutes = durationMinutes
        self.xpEarned = xpEarned
        self.date = date
        self.details = details
    }
}

// MARK: - Workout Set Detail Model
struct WorkoutSetDetail: Codable, Hashable {
    let weight: Double?
    let reps: Int?
    let duration: Int? // 秒
    let distance: Double? // km
    
    var description: String {
        if let weight = weight, let reps = reps {
            return String(format: "%.1fkg × %d回", weight, reps)
        } else if let reps = reps {
            return "\(reps)回"
        } else if let duration = duration {
            return "\(duration)秒"
        } else if let distance = distance, let duration = duration {
            return String(format: "%.1fkm - %d分", distance, duration / 60)
        } else if let distance = distance {
            return String(format: "%.1fkm", distance)
        }
        return ""
    }
}

