# ワークアウト完了時のナビゲーション改善

## ✅ 実装完了した機能

### ワークアウト完了時に選択画面まで自動的に戻る

トレーニング完了ボタンを押すと、ワークアウト記録画面とワークアウト詳細画面の両方が閉じられ、ワークアウト選択画面まで自動的に戻るようになりました。

## 📱 画面遷移フロー

### 修正前
```
選択画面 → 詳細画面 → 記録画面
                      ↓ 完了ボタン
                   詳細画面 ← （ここで止まる）
```

### 修正後
```
選択画面 → 詳細画面 → 記録画面
   ↑                    ↓ 完了ボタン
   └────────────────────┘（自動的に選択画面まで戻る）
```

## 🔧 実装の詳細

### 1. WorkoutRecordView の修正

**コールバックの追加:**
```swift
struct WorkoutRecordView: View {
    let exercise: Exercise
    let onWorkoutComplete: (() -> Void)?  // 完了時のコールバック
    
    // デフォルトのイニシャライザ
    init(exercise: Exercise, onWorkoutComplete: (() -> Void)? = nil) {
        self.exercise = exercise
        self.onWorkoutComplete = onWorkoutComplete
    }
    
    // ...
}
```

**完了時の処理:**
```swift
.alert("ワークアウト完了", isPresented: $showingCompletionAlert) {
    Button("OK") {
        // 1. 記録画面を閉じる
        presentationMode.wrappedValue.dismiss()
        
        // 2. コールバックを呼び出す（詳細画面を閉じるため）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onWorkoutComplete?()
        }
    }
}
```

### 2. ExerciseDetailView の修正

**presentationMode の取得:**
```swift
struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.presentationMode) var presentationMode
    
    // ...
}
```

**NavigationLink でコールバックを渡す:**
```swift
NavigationLink(
    destination: WorkoutRecordView(
        exercise: exercise,
        onWorkoutComplete: {
            // ワークアウト完了時に詳細画面も閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    )
) {
    Text("トレーニングを開始")
        // ...
}
```

## ⏱️ タイミング制御

### なぜ遅延が必要なのか？

```swift
// 記録画面のdismiss
presentationMode.wrappedValue.dismiss()

// 0.3秒後にコールバック実行
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    onWorkoutComplete?()
}

// さらに0.1秒後に詳細画面のdismiss
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    presentationMode.wrappedValue.dismiss()
}
```

**理由:**
1. SwiftUIのナビゲーションアニメーションが完了するのを待つ必要がある
2. 同時に複数の画面を閉じようとすると、アニメーションが不自然になる
3. 遅延を入れることで、スムーズな画面遷移を実現

### タイミング図

```
時間 →  0ms        300ms       400ms
        │           │           │
記録画面 │ dismiss   │           │
        │---------->│           │
        │           │           │
コール  │           │ 実行      │
バック  │           │---------->│
        │           │           │
詳細画面│           │           │ dismiss
        │           │           │-------->
        │           │           │
選択画面│           │           │ 表示
```

## 🎯 ユーザー体験

### シナリオ: トレーニングを完了する

1. **ワークアウト選択画面**
   - トレーニングを選択

2. **ワークアウト詳細画面**
   - 「トレーニングを開始」をタップ

3. **ワークアウト記録画面**
   - セットを記録
   - 「ワークアウト完了」をタップ

4. **完了アラート**
   - 「お疲れ様でした！」メッセージ
   - 「OK」をタップ

5. **自動遷移** ✨
   - 記録画面が閉じる
   - 詳細画面も自動的に閉じる
   - **選択画面に戻る**（スムーズなアニメーション）

## 🔍 技術的なポイント

### 1. オプショナルコールバック
```swift
let onWorkoutComplete: (() -> Void)?
```
- オプショナルなので、コールバックなしでも動作する
- 既存のコードとの互換性を保つ

### 2. デフォルト引数
```swift
init(exercise: Exercise, onWorkoutComplete: (() -> Void)? = nil)
```
- デフォルト値を`nil`に設定
- 他の場所から呼び出す際にコールバックを省略可能

### 3. Environment変数
```swift
@Environment(\.presentationMode) var presentationMode
```
- SwiftUIの標準的な方法で画面を閉じる
- ナビゲーションスタックを適切に管理

## 📊 メリット

### ユーザー体験の向上
- ✅ 直感的な動作（完了したら最初の画面に戻る）
- ✅ 手動で戻るボタンを押す必要がない
- ✅ スムーズなアニメーション
- ✅ 次のトレーニングをすぐに選択できる

### コードの保守性
- ✅ シンプルなコールバック機構
- ✅ 既存のコードとの互換性を維持
- ✅ 拡張しやすい設計
- ✅ テストしやすい

## 🚀 今後の拡張可能性

### 追加できる機能

1. **完了後のサマリー画面**
```swift
onWorkoutComplete: {
    // サマリー画面を表示してから閉じる
    showSummary = true
}
```

2. **次のトレーニングの提案**
```swift
onWorkoutComplete: {
    // 次のおすすめトレーニングを提案
    suggestNextWorkout()
}
```

3. **共有機能**
```swift
onWorkoutComplete: {
    // トレーニング結果をSNSに共有
    shareWorkout()
}
```

4. **バッジやアチーブメント**
```swift
onWorkoutComplete: {
    // バッジの獲得をチェック
    checkAchievements()
}
```

## 🧪 テスト方法

### 動作確認手順

1. アプリを起動
2. ワークアウトタブを選択
3. 任意のトレーニングをタップ（例: プッシュアップ）
4. 「トレーニングを開始」をタップ
5. セットを1つ以上追加
6. 「ワークアウト完了」をタップ
7. アラートの「OK」をタップ
8. ✅ **ワークアウト選択画面に戻ることを確認**

### 期待される動作

- [ ] 記録画面が閉じる
- [ ] 詳細画面も自動的に閉じる
- [ ] 選択画面に戻る
- [ ] アニメーションがスムーズ
- [ ] データが正しく保存されている（統計画面で確認）

## 🎉 まとめ

この実装により、ワークアウト完了後のユーザー体験が大幅に向上しました。ユーザーは完了ボタンを押すだけで、自動的にワークアウト選択画面まで戻り、次のトレーニングをすぐに開始できます。

コールバック機構を使ったシンプルな実装により、コードの保守性と拡張性も確保されています。
