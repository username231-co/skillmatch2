//
//  zikkenn.swift
//  skillmatch
//
//  Created by 松佳 on 2025/07/05.
//

import SwiftUI

struct zikkenn: View {
    @StateObject private var viewModel1 = CommentViewModel()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button {
            print("aaa========================")
            viewModel1.eidokuyosoz()
            
        } label: {
            Image(systemName: "heart")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.mint)
                .background {
                    Circle()
                    // 枠線の色もアイコンに合わせると綺麗です
                        .stroke(.mint, lineWidth: 1)
                        .frame(width: 60, height: 60)
                }
            
        }
    }
}

#Preview {
    zikkenn()
}
