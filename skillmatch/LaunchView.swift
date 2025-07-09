//
//  LaunchView.swift
//  skillmatch
//
//  Created by 松佳 on 2025/07/05.
//

import SwiftUI

struct LaunchView: View {
    @StateObject private var viewModel = CommentViewModel()
    @State private var hasProfile: Bool? = nil
    
    var body: some View {
        Group {
            if let hasProfile = hasProfile {
                if hasProfile {
                    ProfileView()
                } else {
                    CreateProfileView(onProfileCreated: {
                        self.hasProfile = true
                    })
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.checkIfProfileExists { exists in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.hasProfile = exists
                }
            }
        }
    }
}
