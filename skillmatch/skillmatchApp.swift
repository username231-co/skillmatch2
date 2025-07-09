//
//  skillmatchApp.swift
//  skillmatch
//
//  Created by 松佳 on 2025/05/28.
//
import SwiftUI
import FirebaseCore

// AppDelegateは変更ありません
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            // 最初に表示するViewをLaunchViewに変更
            LaunchView()
        }
    }
}
