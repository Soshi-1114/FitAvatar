# ナビゲーションエラーの修正

## 🐛 発生していた問題

### エラーメッセージ
```
"Layout requested for visible navigation bar when the top item belongs 
to a different navigation bar... possibly from a client attempt to nest 
wrapped navigation controllers."
```

### 原因
複数の`presentationMode.wrappedValue.dismiss()`を短い間隔で連続して呼び出すと、SwiftUIのナビゲーションスタックが混乱し、内部的なナビゲーションバーの状態が不整合になる。

## ✅ 修正内容

### 1. `@Environment(\.dismiss)`への移行

**修正前:**
```swift
@Environment(\.presentationMode) var presentationMode

// 使用時
presentationMode.wrappedValue.dismiss()
```

**修正後:**
```swift
@Environment(\.dismiss) private var dismiss

// 使用時
dismiss()
```

### メリット
- iOS 15以降の推奨される方法
- よりシンプルな構文
- ナビゲーションスタックの管理が改善
- SwiftUIの内部実装でより安全に処理される

### 2. タイミングの調整

**修正前:**
```swift
// 記録画面: 0.3秒後にコールバック
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    onWorkoutComplete?()
}

// 詳細画面: 0.1秒後にdismiss
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    presentationMode.wrappedValue.dismiss()
}
```

**修正後:**
```swift
// 記録画面: 0.5秒後にコールバック（より余裕を持たせる）
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    onWorkoutComplete?()
}

// 詳細画面: 0.1秒後にdismiss
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    dismiss()
}
```

### 理由
- アニメーションの完了を確実に待つ
- ナビゲーションスタックの更新を待つ
- 複数のdismissが衝突しないようにする

## 🔧 変更されたファイル

### WorkoutRecordView.swift

```swift
struct WorkoutRecordView: View {
    // 変更前
    @Environment(\.presentationMode) var presentationMode
    
    // 変更後
    @Environment(\.dismiss) private var dismiss
    
    // ...
    
    .alert("ワークアウト完了", isPresented: $showingCompletionAlert) {
        Button("OK") {
            // 記録画面を閉じる
            dismiss()
            // 0.5秒後にコールバック実行
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onWorkoutComplete?()
            }
        }
    }
}
```

### WorkoutView.swift (ExerciseDetailView)

```swift
struct ExerciseDetailView: View {
    // 変更前
    @Environment(\.presentationMode) var presentationMode
    
    // 変更後
    @Environment(\.dismiss) private var dismiss
    
    // ...
    
    NavigationLink(
        destination: WorkoutRecordView(
            exercise: exercise,
            onWorkoutComplete: {
                // 0.1秒後に詳細画面を閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
            }
        )
    ) {
        Text("トレーニングを開始")
        // ...
    }
}
```

## ⏱️ タイミング図（修正後）

```
時間 →  0ms        500ms       600ms
        │           │           │
記録画面 │ dismiss   │           │
        │---------->│           │
        │           │           │
        │    アニメーション    │
        │<-------完了-------->  │
        │           │           │
コール  │           │ 実行      │
バック  │           │---------->│
        │           │           │
詳細画面│           │           │ dismiss
        │           │           │-------->
        │           │           │
        │           │    アニメーション
        │           │<-------完了-------->
        │           │           │
選択画面│           │           │ 表示完了
```

## 📱 iOS バージョン要件

### `@Environment(\.dismiss)`
- **必要なバージョン:** iOS 15.0+
- **現在のプロジェクト:** iOS 15.0以降をサポート
- **互換性:** ✅ 問題なし

もしiOS 14以下をサポートする必要がある場合:
```swift
// iOS 14以下の場合は元の方法に戻す必要がある
@available(iOS 15.0, *)
@Environment(\.dismiss) private var dismiss

@available(iOS, deprecated: 15.0)
@Environment(\.presentationMode) private var presentationMode
```

## 🧪 テスト結果

### テストケース

1. **通常のフロー**
   - ✅ 選択画面 → 詳細画面 → 記録画面
   - ✅ 記録完了 → 選択画面に戻る
   - ✅ エラーなし

2. **複数回のトレーニング**
   - ✅ トレーニング1を完了
   - ✅ トレーニング2を開始
   - ✅ トレーニング2を完了
   - ✅ エラーなし

3. **途中でキャンセル**
   - ✅ 詳細画面で戻るボタン
   - ✅ 記録画面で戻るボタン
   - ✅ エラーなし

4. **高速操作**
   - ✅ 素早くボタンをタップ
   - ✅ ナビゲーションバーのエラーなし
   - ✅ アニメーションがスムーズ

## 🎯 なぜ`dismiss`が優れているか

### 1. 型安全性
```swift
// presentationMode: Binding<PresentationMode>
presentationMode.wrappedValue.dismiss()

// dismiss: DismissAction (クロージャ型)
dismiss()
```

### 2. シンプルさ
- ラップされた値にアクセスする必要なし
- 直接呼び出せる

### 3. SwiftUIの内部最適化
- より効率的なナビゲーション処理
- ナビゲーションバーの状態管理が改善
- エッジケースの処理が向上

### 4. Apple推奨
- iOS 15以降のベストプラクティス
- 将来のSwiftUIバージョンとの互換性
- deprecation警告なし

## 🔍 デバッグのヒント

もし今後ナビゲーションエラーが発生した場合:

### 1. 遅延時間を調整
```swift
// 遅延を長くする
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    dismiss()
}
```

### 2. デバッグログを追加
```swift
dismiss()
print("✅ Dismissed at \(Date())")

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    print("✅ Callback executed at \(Date())")
    onWorkoutComplete?()
}
```

### 3. ナビゲーションスタックをリセット
```swift
// 最終手段: ルートビューに戻る
if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
   let window = windowScene.windows.first,
   let rootViewController = window.rootViewController {
    // ナビゲーションコントローラーをリセット
}
```

## 🎉 結果

- ✅ **ナビゲーションエラー解決**
- ✅ **スムーズな画面遷移**
- ✅ **iOS 15+の推奨方法を使用**
- ✅ **コードがよりシンプルに**

## 📚 参考資料

- [Apple Documentation: dismiss](https://developer.apple.com/documentation/swiftui/environmentvalues/dismiss)
- [WWDC 2021: What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10018/)
- [SwiftUI Navigation Best Practices](https://developer.apple.com/documentation/swiftui/view-navigation)
