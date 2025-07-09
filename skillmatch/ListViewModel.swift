//
//  ListViewModel.swift
//  MatchingWithSwiftUI2
//
//  Created by 中村優介 on 2025/06/08.
//

import Foundation
class ListViewModel {
    
    
    var users = [User]()
    private var currentIndex = 0
    init() {
        self.users = getMockUsers()
    }
    
    private func getMockUsers() -> [User] {
        return [
            User.MOCK_USER1,
            User.MOCK_USER2,
            User.MOCK_USER3,
            User.MOCK_USER4,
            User.MOCK_USER5,
            User.MOCK_USER6,
            User.MOCK_USER7,
        ]
    }
    func adjustIndex(isRedo: Bool) {
        if isRedo {
            currentIndex -= 1
        } else {
            currentIndex += 1
        }
    }
    
    func nopeBottonTapped() {
        if currentIndex >= users.count { //メソッドの処理から抜けるようにする
            return
        }
        NotificationCenter .default.post(name: Notification.Name("NOPEAUTION"), object: nil,userInfo: [
            "id": users[currentIndex].id
        ])
    }
    
    func likeBottonTapped() {
        if currentIndex >= users.count { //メソッドの処理から抜けるようにする
            return
        }
        NotificationCenter .default.post(name: Notification.Name("LIKEACTION"), object: nil,userInfo: [
            "id": users[currentIndex].id
        ])
    }
    func redoBottonTapped() {
        if currentIndex <= 0 { //メソッドの処理から抜けるようにする
            return
        }
        NotificationCenter .default.post(name: Notification.Name("REDOACTION"), object: nil,userInfo: [
            "id": users[currentIndex - 1].id
        ])
    }
}

