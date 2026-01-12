//
//  RadarChartView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/09/03.
//

import SwiftUI

struct RadarChartView: View {
    let data: [RadarDataPoint]
    let size: CGFloat
    let showLabels: Bool
    let showMultipleLevels: Bool
    
    init(data: [RadarDataPoint], size: CGFloat = 200, showLabels: Bool = true, showMultipleLevels: Bool = false) {
        self.data = data
        self.size = size
        self.showLabels = showLabels
        self.showMultipleLevels = showMultipleLevels
    }
    
    var body: some View {
        ZStack {
            // 背景のグリッド線
            RadarGridView(points: data.count, size: size, showMultipleLevels: showMultipleLevels)
            
            // データポリゴン
            RadarDataPolygon(data: data, size: size)
                .fill(Color.blue.opacity(0.3))
            
            RadarDataPolygon(data: data, size: size)
                .stroke(Color.blue, lineWidth: 2)
            
            // ラベル
            if showLabels {
                RadarLabelsView(data: data, size: size)
            }
        }
        .frame(width: size, height: size)
    }
}

// グリッド線
struct RadarGridView: View {
    let points: Int
    let size: CGFloat
    let showMultipleLevels: Bool
    
    init(points: Int, size: CGFloat, showMultipleLevels: Bool = false) {
        self.points = points
        self.size = size
        self.showMultipleLevels = showMultipleLevels
    }
    
    var body: some View {
        ZStack {
            if showMultipleLevels {
                // 5段階のグリッド（全て親のsizeで描画、radiusだけ変える）
                ForEach(1...5, id: \.self) { level in
                    RadarPolygon(points: points, radius: size / 2.0 * CGFloat(level) / 5.0)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                }
            } else {
                // 外枠のみ
                RadarPolygon(points: points, radius: size / 2.0)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
            }
            
            // 中心から各頂点への線
            ForEach(0..<points, id: \.self) { index in
                Path { path in
                    let angle = angleForIndex(index, points: points)
                    let endPoint = pointForAngle(angle, radius: size / 2.0)
                    path.move(to: CGPoint(x: size / 2.0, y: size / 2.0))
                    path.addLine(to: endPoint)
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        }
        .frame(width: size, height: size)
    }
    
    private func angleForIndex(_ index: Int, points: Int) -> Double {
        let angleStep = 2.0 * .pi / Double(points)
        return angleStep * Double(index) - .pi / 2.0
    }
    
    private func pointForAngle(_ angle: Double, radius: CGFloat) -> CGPoint {
        let x = size / 2.0 + radius * CGFloat(cos(angle))
        let y = size / 2.0 + radius * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
    }
}

// データポリゴン
struct RadarDataPolygon: Shape {
    let data: [RadarDataPoint]
    let size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !data.isEmpty else { return path }
        
        let center = CGPoint(x: size / 2.0, y: size / 2.0)
        let points = data.count
        
        // 最初の点に移動
        let firstAngle = angleForIndex(0, points: points)
        let firstRadius = size / 2.0 * CGFloat(data[0].value)
        let firstPoint = pointForAngle(firstAngle, radius: firstRadius, center: center)
        path.move(to: firstPoint)
        
        // 各点を結ぶ
        for index in 1..<data.count {
            let angle = angleForIndex(index, points: points)
            let radius = size / 2.0 * CGFloat(data[index].value)
            let point = pointForAngle(angle, radius: radius, center: center)
            path.addLine(to: point)
        }
        
        // 最初の点に戻って閉じる
        path.closeSubpath()
        
        return path
    }
    
    private func angleForIndex(_ index: Int, points: Int) -> Double {
        let angleStep = 2.0 * .pi / Double(points)
        return angleStep * Double(index) - .pi / 2.0
    }
    
    private func pointForAngle(_ angle: Double, radius: CGFloat, center: CGPoint) -> CGPoint {
        let x = center.x + radius * CGFloat(cos(angle))
        let y = center.y + radius * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
    }
}

// 多角形（グリッド用）
struct RadarPolygon: Shape {
    let points: Int
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard points > 0 else { return path }
        
        // rectの中心を使用
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // 最初の点に移動
        let firstAngle = angleForIndex(0, points: points)
        let firstPoint = pointForAngle(firstAngle, radius: radius, center: center)
        path.move(to: firstPoint)
        
        // 各頂点を結ぶ
        for index in 1..<points {
            let angle = angleForIndex(index, points: points)
            let point = pointForAngle(angle, radius: radius, center: center)
            path.addLine(to: point)
        }
        
        // パスを閉じる
        path.closeSubpath()
        
        return path
    }
    
    private func angleForIndex(_ index: Int, points: Int) -> Double {
        let angleStep = 2.0 * .pi / Double(points)
        return angleStep * Double(index) - .pi / 2.0
    }
    
    private func pointForAngle(_ angle: Double, radius: CGFloat, center: CGPoint) -> CGPoint {
        let x = center.x + radius * CGFloat(cos(angle))
        let y = center.y + radius * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
    }
}

// ラベル
struct RadarLabelsView: View {
    let data: [RadarDataPoint]
    let size: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                let angle = angleForIndex(index, points: data.count)
                let radius = size / 2.0 + 20.0  // ラベルは少し外側に配置
                let position = pointForAngle(angle, radius: radius)
                
                Text(dataPoint.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .position(position)
            }
        }
    }
    
    private func angleForIndex(_ index: Int, points: Int) -> Double {
        let angleStep = 2.0 * .pi / Double(points)
        return angleStep * Double(index) - .pi / 2.0
    }
    
    private func pointForAngle(_ angle: Double, radius: CGFloat) -> CGPoint {
        let x = size / 2.0 + radius * CGFloat(cos(angle))
        let y = size / 2.0 + radius * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
    }
}

// プレビュー
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            Text("アバターステータス")
                .font(.title)
                .fontWeight(.bold)
            
            // 5段階グリッド表示
            VStack(spacing: 10) {
                Text("5段階グリッド")
                    .font(.headline)
                
                RadarChartView(
                    data: [
                        RadarDataPoint(label: "腕", value: 0.8, part: .arms),
                        RadarDataPoint(label: "肩", value: 0.6, part: .shoulders),
                        RadarDataPoint(label: "腹筋", value: 0.7, part: .abs),
                        RadarDataPoint(label: "背筋", value: 0.5, part: .back),
                        RadarDataPoint(label: "足", value: 0.9, part: .legs)
                    ],
                    size: 250,
                    showMultipleLevels: true
                )
            }
            
            Divider()
            
            // シンプル表示
            VStack(spacing: 10) {
                Text("シンプル（外枠のみ）")
                    .font(.headline)
                
                RadarChartView(
                    data: [
                        RadarDataPoint(label: "腕", value: 0.8, part: .arms),
                        RadarDataPoint(label: "肩", value: 0.6, part: .shoulders),
                        RadarDataPoint(label: "腹筋", value: 0.7, part: .abs),
                        RadarDataPoint(label: "背筋", value: 0.5, part: .back),
                        RadarDataPoint(label: "足", value: 0.9, part: .legs)
                    ],
                    size: 250,
                    showMultipleLevels: false
                )
            }
            
            Spacer()
        }
        .padding()
    }
}
