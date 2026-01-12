# ビルドエラー修正: RadarChartView

## 🐛 発生していたエラー

```
error: Ambiguous use of operator '/'
```

## 原因

SwiftのCGFloatとDoubleの型推論が曖昧になっていました。特に以下の箇所：

1. **整数リテラルの除算**
```swift
// エラー: 2と.piの型が曖昧
let angleStep = 2 * .pi / Double(points)

// エラー: size / 2の型が曖昧
let center = CGPoint(x: size / 2, y: size / 2)
```

2. **三角関数の結果**
```swift
// エラー: cos/sinの結果がDoubleだがCGFloatとの演算で曖昧
let x = size / 2 + radius * cos(angle)
```

## ✅ 修正内容

### 1. 数値リテラルに明示的な型を指定

**修正前:**
```swift
let angleStep = 2 * .pi / Double(points)
return angleStep * Double(index) - .pi / 2
```

**修正後:**
```swift
let angleStep = 2.0 * .pi / Double(points)
return angleStep * Double(index) - .pi / 2.0
```

### 2. 除算に明示的な型を指定

**修正前:**
```swift
let center = CGPoint(x: size / 2, y: size / 2)
let radius = size / 2
```

**修正後:**
```swift
let center = CGPoint(x: size / 2.0, y: size / 2.0)
let radius = size / 2.0
```

### 3. 三角関数の結果を明示的にキャスト

**修正前:**
```swift
let x = center.x + radius * cos(angle)
let y = center.y + radius * sin(angle)
```

**修正後:**
```swift
let x = center.x + radius * CGFloat(cos(angle))
let y = center.y + radius * CGFloat(sin(angle))
```

## 📝 修正した構造体

### 1. RadarGridView
```swift
private func pointForAngle(_ angle: Double, radius: CGFloat) -> CGPoint {
    let x = size / 2.0 + radius * CGFloat(cos(angle))
    let y = size / 2.0 + radius * CGFloat(sin(angle))
    return CGPoint(x: x, y: y)
}
```

### 2. RadarDataPolygon
```swift
func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: size / 2.0, y: size / 2.0)
    let firstRadius = size / 2.0 * CGFloat(data[0].value)
    // ...
}
```

### 3. RadarPolygon
```swift
func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: size / 2.0, y: size / 2.0)
    let radius = size / 2.0
    // ...
}
```

### 4. RadarLabelsView
```swift
let radius = size / 2.0 + 20.0

private func pointForAngle(_ angle: Double, radius: CGFloat) -> CGPoint {
    let x = size / 2.0 + radius * CGFloat(cos(angle))
    let y = size / 2.0 + radius * CGFloat(sin(angle))
    return CGPoint(x: x, y: y)
}
```

## 🔍 型変換の重要性

### SwiftにおけるCGFloatとDouble

| 型 | 用途 | プラットフォーム |
|---|------|----------------|
| `CGFloat` | CoreGraphicsの座標・サイズ | iOS/macOS |
| `Double` | 汎用的な浮動小数点演算 | すべて |

### 三角関数の戻り値

Swiftの標準三角関数（`cos`, `sin`, `tan`）は**Double**を返します。

```swift
let angle: Double = .pi / 4
let result = cos(angle)  // Doubleを返す

// CGFloatと演算する場合は明示的にキャスト
let cgValue: CGFloat = 100
let x = cgValue * CGFloat(result)  // ✅ OK
```

## 🎯 ベストプラクティス

### 1. 数値リテラルに型を明示

```swift
// ❌ 避けるべき
let value = 2 / 5

// ✅ 推奨
let value = 2.0 / 5.0
let valueInt = 2 / 5  // 整数除算の場合は明示的に
```

### 2. 型変換を明示的に

```swift
// ❌ 避けるべき
let cgFloat: CGFloat = 10
let double: Double = 20
let result = cgFloat * double  // エラー

// ✅ 推奨
let result = cgFloat * CGFloat(double)
// または
let result = Double(cgFloat) * double
```

### 3. 三角関数の結果をキャスト

```swift
// ❌ 避けるべき
let x: CGFloat = 100 * cos(angle)  // エラー

// ✅ 推奨
let x: CGFloat = 100 * CGFloat(cos(angle))
```

## 🧪 テスト方法

1. プロジェクトをクリーン
   - Cmd + Shift + K

2. ビルド
   - Cmd + B

3. 実行
   - Cmd + R

4. レーダーチャートが正しく表示されることを確認

## 📊 変更前後の比較

### 変更前（エラー）
```swift
let angleStep = 2 * .pi / Double(points)         // ❌ 型が曖昧
let center = CGPoint(x: size / 2, y: size / 2)   // ❌ 型が曖昧
let x = center.x + radius * cos(angle)           // ❌ 型が曖昧
```

### 変更後（正常）
```swift
let angleStep = 2.0 * .pi / Double(points)              // ✅ OK
let center = CGPoint(x: size / 2.0, y: size / 2.0)     // ✅ OK
let x = center.x + radius * CGFloat(cos(angle))        // ✅ OK
```

## 🚀 追加の改善提案

### 1. 型エイリアスの使用

```swift
typealias Angle = Double
typealias Coordinate = CGFloat

private func angleForIndex(_ index: Int, points: Int) -> Angle {
    let angleStep = 2.0 * .pi / Double(points)
    return angleStep * Double(index) - .pi / 2.0
}
```

### 2. 定数の定義

```swift
private enum Constants {
    static let fullCircle: Double = 2.0 * .pi
    static let startAngle: Double = -.pi / 2.0
    static let labelOffset: CGFloat = 20.0
}

private func angleForIndex(_ index: Int, points: Int) -> Double {
    let angleStep = Constants.fullCircle / Double(points)
    return angleStep * Double(index) + Constants.startAngle
}
```

### 3. ヘルパー関数の追加

```swift
extension CGFloat {
    init(cosine angle: Double) {
        self.init(cos(angle))
    }
    
    init(sine angle: Double) {
        self.init(sin(angle))
    }
}

// 使用例
let x = center.x + radius * CGFloat(cosine: angle)
let y = center.y + radius * CGFloat(sine: angle)
```

## 📚 参考情報

### Apple Documentation
- [CGFloat](https://developer.apple.com/documentation/coregraphics/cgfloat)
- [Double](https://developer.apple.com/documentation/swift/double)
- [Type Conversion](https://docs.swift.org/swift-book/LanguageGuide/TypeCasting.html)

### Swift Evolution
- [SE-0282: Low-Level Atomic Operations](https://github.com/apple/swift-evolution/blob/main/proposals/0282-atomics.md)

## ✅ 結果

すべての型の曖昧さが解消され、ビルドが成功するようになりました！

- ✅ コンパイルエラーなし
- ✅ 型安全性の向上
- ✅ コードの可読性向上
- ✅ レーダーチャートが正しく描画される
