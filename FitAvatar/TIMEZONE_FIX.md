# タイムゾーンと曜日表示の修正

## 🐛 発生していた問題

### 症状
- トレーニング頻度グラフで曜日が正しく表示されない
- 土曜日にトレーニングしたのに、日曜日のバーに表示される
- 曜日の順序が実際の曜日と一致しない

### 原因
固定の曜日配列（月〜日）を使用していたため、実際の日付の曜日と合致していなかった。

```swift
// 問題のあったコード
let weekDays = ["月", "火", "水", "木", "金", "土", "日"]
return weekDays.enumerated().map { index, day in
    let date = calendar.date(byAdding: .day, value: index - 6, to: today)!
    // ...
}
```

このロジックでは：
- `index=0` → 6日前 → "月"
- `index=1` → 5日前 → "火"
- ...
- `index=6` → 今日 → "日"

しかし、今日が土曜日の場合、6日前も土曜日なので、曜日がずれてしまっていました。

## ✅ 修正内容

### weeklyDataの計算を修正

**修正後のコード:**
```swift
private var weeklyData: [DayData] {
    let calendar = Calendar.current
    let today = Date()
    
    // 今日の曜日を取得（1=日曜日, 2=月曜日, ..., 7=土曜日）
    let todayWeekday = calendar.component(.weekday, from: today)
    
    // 日本語の曜日表記（日曜始まり）
    let weekDayNames = ["日", "月", "火", "水", "木", "金", "土"]
    
    // 過去7日間のデータを作成（今日を含む）
    return (0..<7).map { dayOffset in
        // 6日前から今日まで
        let date = calendar.date(byAdding: .day, value: dayOffset - 6, to: today)!
        let weekday = calendar.component(.weekday, from: date)
        let dayName = weekDayNames[weekday - 1]  // weekdayは1始まりなので-1
        
        let count = appData.workoutHistory.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }.count
        
        return DayData(day: dayName, count: count)
    }
}
```

## 🔍 詳細な説明

### Calendarの.weekdayコンポーネント

Appleの`Calendar`では、曜日は以下のように定義されています：

```
1 = 日曜日 (Sunday)
2 = 月曜日 (Monday)
3 = 火曜日 (Tuesday)
4 = 水曜日 (Wednesday)
5 = 木曜日 (Thursday)
6 = 金曜日 (Friday)
7 = 土曜日 (Saturday)
```

### 配列のインデックス

```swift
let weekDayNames = ["日", "月", "火", "水", "木", "金", "土"]
//                  0     1     2     3     4     5     6
```

したがって、`weekday - 1`でインデックスに変換します。

### 動作例

今日が**2025年1月10日（金曜日）**の場合：

```
dayOffset=0: 1月4日(土) → weekday=7 → weekDayNames[6] = "土"
dayOffset=1: 1月5日(日) → weekday=1 → weekDayNames[0] = "日"
dayOffset=2: 1月6日(月) → weekday=2 → weekDayNames[1] = "月"
dayOffset=3: 1月7日(火) → weekday=3 → weekDayNames[2] = "火"
dayOffset=4: 1月8日(水) → weekday=4 → weekDayNames[3] = "水"
dayOffset=5: 1月9日(木) → weekday=5 → weekDayNames[4] = "木"
dayOffset=6: 1月10日(金) → weekday=6 → weekDayNames[5] = "金"
```

グラフには：`[土, 日, 月, 火, 水, 木, 金]` と表示される ✅

## 📱 タイムゾーン対応

### Calendar.current の使用

```swift
let calendar = Calendar.current
```

`Calendar.current`は、デバイスの現在のタイムゾーンとロケール設定を自動的に使用します。

### タイムゾーンの例

| 地域 | タイムゾーン | 動作 |
|-----|------------|------|
| 🇯🇵 日本 | JST (UTC+9) | ✅ 正しく動作 |
| 🇺🇸 アメリカ東部 | EST (UTC-5) | ✅ 正しく動作 |
| 🇬🇧 イギリス | GMT (UTC+0) | ✅ 正しく動作 |
| 🇦🇺 オーストラリア | AEST (UTC+10) | ✅ 正しく動作 |

### 日付の比較

```swift
calendar.isDate($0.date, inSameDayAs: date)
```

この関数は、タイムゾーンを考慮して「同じ日」かどうかを判定します。

例：
- 日本時間: 2025-01-10 23:00 JST
- UTC時間: 2025-01-10 14:00 UTC

両方とも「2025年1月10日」として正しく扱われます ✅

## 🧪 テスト方法

### 1. 基本的な動作確認

```swift
let calendar = Calendar.current
let today = Date()

print("今日: \(today)")
print("曜日コンポーネント: \(calendar.component(.weekday, from: today))")

// 過去7日間を表示
for i in 0..<7 {
    let date = calendar.date(byAdding: .day, value: i - 6, to: today)!
    let weekday = calendar.component(.weekday, from: date)
    let weekDayNames = ["日", "月", "火", "水", "木", "金", "土"]
    print("dayOffset=\(i): \(date) → \(weekDayNames[weekday - 1])")
}
```

### 2. タイムゾーンのテスト

シミュレータの設定を変更：
1. **Settings** → **General** → **Date & Time**
2. タイムゾーンを変更（例: New York, London, Sydney）
3. アプリを再起動
4. グラフが正しく表示されることを確認

### 3. データの整合性確認

```swift
// 今日トレーニングを記録
let workout = WorkoutRecord(...)
appData.addWorkout(workout)

// 統計画面を開く
// → 今日の曜日のバーにカウントが表示される ✅
```

## 📊 修正前後の比較

### 修正前（2025年1月10日 金曜日の場合）

```
グラフ表示: [月, 火, 水, 木, 金, 土, 日]
実際の日付: [土, 日, 月, 火, 水, 木, 金]
                ↑ ずれている ❌
```

### 修正後（2025年1月10日 金曜日の場合）

```
グラフ表示: [土, 日, 月, 火, 水, 木, 金]
実際の日付: [土, 日, 月, 火, 水, 木, 金]
                ↑ 一致している ✅
```

## 🌍 ロケール対応

現在の実装は日本語に固定されていますが、将来的に多言語対応する場合：

```swift
// ロケールに応じた曜日名を取得
let weekDayNames = calendar.shortWeekdaySymbols
// 例: 英語の場合 → ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
```

または：

```swift
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "E"  // 短縮曜日名
let dayName = dateFormatter.string(from: date)
```

## 🔧 その他の改善点

### 1. タイムゾーン情報の表示（デバッグ用）

```swift
// AppData.swiftに追加
func getTimezoneInfo() -> String {
    let calendar = Calendar.current
    let timezone = calendar.timeZone
    return """
    TimeZone: \(timezone.identifier)
    Offset: \(timezone.secondsFromGMT() / 3600) hours
    Current Date: \(Date())
    """
}
```

### 2. 週の開始曜日の設定

一部の国では週の開始が月曜日です：

```swift
var calendar = Calendar.current
calendar.firstWeekday = 2  // 1=日曜, 2=月曜
```

### 3. サマータイム対応

`Calendar.current`は自動的にサマータイムを考慮します：

```swift
// サマータイム中かどうか確認
let isDST = TimeZone.current.isDaylightSavingTime(for: Date())
```

## 🎯 結果

- ✅ **曜日が正確に表示される**
- ✅ **デバイスのタイムゾーンに対応**
- ✅ **過去7日間の正しいデータを表示**
- ✅ **世界中どこでも正確に動作**

## 📚 参考情報

### Apple Documentation
- [Calendar - Apple Developer](https://developer.apple.com/documentation/foundation/calendar)
- [Calendar.Component - Apple Developer](https://developer.apple.com/documentation/foundation/calendar/component)
- [TimeZone - Apple Developer](https://developer.apple.com/documentation/foundation/timezone)

### 曜日の処理
```swift
// 曜日を取得
calendar.component(.weekday, from: date)

// 日付を比較
calendar.isDate(date1, inSameDayAs: date2)

// 曜日名を取得
calendar.shortWeekdaySymbols
calendar.weekdaySymbols
```

## 🚀 今後の拡張

1. **カスタマイズ可能な週の表示範囲**
   - 過去7日、14日、30日など選択可能に

2. **月間カレンダービュー**
   - ヒートマップ形式で1ヶ月のトレーニング頻度を可視化

3. **年間統計**
   - 月ごとの集計グラフ

4. **タイムゾーン変更の検知**
   - 旅行中もデータを正確に記録
