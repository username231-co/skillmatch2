//
//  SwiftUIView.swift
//  skillmatch
//
//  Created by 松佳 on 2025/06/29.
//

import SwiftUI

struct SwiftUIView: View {
    // CardViewに合わせて Profile 型でモックデータを作成する
    let MOCK_USER1 = Profile(id: "3puVxzzjAYRRPyEo4JNa", name: "ブルー", age:"20", email: "test1@example.com",text: "いいね",)
    
    var body: some View {
        VStack { // 複数のViewを縦に並べるためにVStackで囲う
            Text("これはCardViewのテストです")
            
            // 正しい引数で CardView を呼び出す
            CardView(
                user: MOCK_USER1,
                adjustIndex: { isLiked in
                    print("カードがスワイプされました: \(isLiked ? "Like" : "Nope")")
                }
            )
            .padding() // 少し余白をつける
        }
    }
}

#Preview {
    SwiftUIView()
}
