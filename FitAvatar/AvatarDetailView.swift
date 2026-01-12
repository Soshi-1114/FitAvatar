//
//  AvatarDetailView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import SwiftUI

struct AvatarDetailView: View {
    @ObservedObject private var appData = AppData.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // レーダーチャート
                radarChartSection
                
                // 総合レベル
                overallLevelSection
                
                // 部位別ステータス
                bodyPartStatsSection
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("アバターステータス")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Radar Chart Section
    private var radarChartSection: some View {
        VStack(spacing: 15) {
            Text("能力チャート")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                
                RadarChartView(
                    data: appData.avatarStats.getRadarData(),
                    size: 280,
                    showLabels: true,
                    showMultipleLevels: true
                )
                .padding()
            }
        }
    }
    
    // MARK: - Overall Level Section
    private var overallLevelSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("総合レベル")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(appData.avatarStats.overallLevel)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Body Part Stats Section
    private var bodyPartStatsSection: some View {
        VStack(spacing: 15) {
            Text("部位別ステータス")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(BodyPart.allCases, id: \.self) { part in
                BodyPartStatRow(part: part, stats: appData.avatarStats)
            }
        }
    }
}

// MARK: - Body Part Stat Row
struct BodyPartStatRow: View {
    let part: BodyPart
    let stats: AvatarStats
    
    private var level: Int {
        stats.getLevel(for: part)
    }
    
    private var points: Int {
        stats.getPoints(for: part)
    }
    
    private var xpToNextLevel: Int {
        stats.getXPToNextLevel(for: part)
    }
    
    private var progress: Double {
        stats.getLevelProgress(for: part)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: part.icon)
                    .font(.title3)
                    .foregroundColor(colorForPart)
                    .frame(width: 30)
                
                Text(part.rawValue)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Lv.\(level)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(points) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // プログレスバー
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [colorForPart.opacity(0.7), colorForPart]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 12)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("次のレベルまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(xpToNextLevel) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorForPart)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private var colorForPart: Color {
        switch part {
        case .arms: return .blue
        case .shoulders: return .purple
        case .abs: return .orange
        case .back: return .green
        case .legs: return .red
        }
    }
}

#Preview {
    NavigationView {
        AvatarDetailView()
    }
}
