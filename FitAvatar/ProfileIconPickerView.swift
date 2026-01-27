//
//  ProfileIconPickerView.swift
//  FitAvatar
//
//  Created by Claude on 2025/01/28.
//

import SwiftUI
import PhotosUI

// デフォルトアイコンの定義
struct DefaultIcon: Identifiable {
    let id: String
    let systemName: String
    let color: Color

    static let allIcons = [
        DefaultIcon(id: "person.fill", systemName: "person.fill", color: .blue),
        DefaultIcon(id: "figure.run", systemName: "figure.run", color: .green),
        DefaultIcon(id: "dumbbell.fill", systemName: "dumbbell.fill", color: .orange),
        DefaultIcon(id: "heart.fill", systemName: "heart.fill", color: .red),
        DefaultIcon(id: "flame.fill", systemName: "flame.fill", color: .orange),
        DefaultIcon(id: "star.fill", systemName: "star.fill", color: .yellow),
        DefaultIcon(id: "bolt.fill", systemName: "bolt.fill", color: .yellow),
        DefaultIcon(id: "figure.strengthtraining.traditional", systemName: "figure.strengthtraining.traditional", color: .purple),
        DefaultIcon(id: "sportscourt.fill", systemName: "sportscourt.fill", color: .green),
        DefaultIcon(id: "bicycle", systemName: "bicycle", color: .blue),
        DefaultIcon(id: "figure.walk", systemName: "figure.walk", color: .mint),
        DefaultIcon(id: "trophy.fill", systemName: "trophy.fill", color: .yellow)
    ]
}

// プロフィールアイコンピッカービュー
struct ProfileIconPickerView: View {
    @ObservedObject private var appData = AppData.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingPhotoPicker = false
    @State private var selectedIconID: String

    init() {
        _selectedIconID = State(initialValue: AppData.shared.profileIconID ?? "person.fill")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 写真から選択セクション
                    VStack(spacing: 15) {
                        Text("写真から選択")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.blue)

                                Text("写真ライブラリから選択")
                                    .font(.body)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // デフォルトアイコンから選択セクション
                    VStack(spacing: 15) {
                        Text("デフォルトアイコンから選択")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(DefaultIcon.allIcons) { icon in
                                DefaultIconButton(
                                    icon: icon,
                                    isSelected: selectedIconID == icon.id
                                ) {
                                    selectedIconID = icon.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("アイコンを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        saveSelection()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            appData.profileIconType = .photo
                            appData.profilePhotoData = data
                            appData.profileIconID = nil
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func saveSelection() {
        if appData.profileIconType != .photo {
            appData.profileIconType = .defaultIcon
            appData.profileIconID = selectedIconID
            appData.profilePhotoData = nil
        }
    }
}

// デフォルトアイコンボタン
struct DefaultIconButton: View {
    let icon: DefaultIcon
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? icon.color.opacity(0.2) : Color(.systemGray6))
                    .frame(width: 70, height: 70)

                Image(systemName: icon.systemName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? icon.color : .gray)

                if isSelected {
                    Circle()
                        .stroke(icon.color, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
            }
        }
    }
}

#Preview {
    ProfileIconPickerView()
}
