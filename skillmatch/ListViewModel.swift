//
//  ListViewModel.swift
//  MatchingWithSwiftUI2
//
//  Created by 中村優介 on 2025/06/08.
//
import Foundation
import SwiftUI // ObservableObjectのために必要

// ✅ 1. ObservableObjectに準拠させる
class ListViewModel: ObservableObject {
    @Published var currentIndex = 0
    
    func adjustIndex(isRedo: Bool) {
        if isRedo {
            if currentIndex > 0 {
                currentIndex -= 1
            }
        } else {
            currentIndex += 1
        }
        print("adjustIndex new currentIndex: \(currentIndex)")
    }
    
    func resetCards() {
        currentIndex = 0
    }

    func nopeBottonTapped(profiles: [Profile]) {
        if currentIndex >= profiles.count { return }
        NotificationCenter.default.post(name: Notification.Name("NOPEACTION"),
                                        object: nil,
                                        userInfo: ["id": profiles[currentIndex].id])
    }
    
    func likeBottonTapped(profiles: [Profile], viewModel: CommentViewModel) {
        if currentIndex >= profiles.count { return }
        let id = profiles[currentIndex].id
        NotificationCenter.default.post(name: Notification.Name("LIKEACTION"),
                                        object: nil,
                                        userInfo: ["id": id])
        viewModel.iinetsuika(userIdUketoru: id ?? "abc")
        viewModel.cardkidoku(kidokuuserId: id ?? "aaa")
    }

    func redoBottonTapped(profiles: [Profile]) {
        if currentIndex <= 0 { return }
        NotificationCenter.default.post(name: Notification.Name("REDOACTION"),
                                        object: nil,
                                        userInfo: ["id": profiles[currentIndex - 1].id])
    }
}

