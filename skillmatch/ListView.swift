//
//  ListView.swift
//  MatchingWithSwiftUI
//
//  Created by 中村優介 on 2025/05/25.
//
import SwiftUI

struct ListView: View {
    // ✅ @StateObjectを使ってViewModelを正しく初期化する
    @StateObject private var viewModel = ListViewModel()
    @StateObject private var viewModel1 = CommentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // viewModel1からデータを取得し、viewModelで状態を管理する
            
            // ✅ 全カード表示後かどうかを判定
            if viewModel.currentIndex >= viewModel1.profiles4.count && !viewModel1.profiles4.isEmpty {
                // --- 「おしまい画面」 ---
                Spacer()
                VStack(spacing: 20) {
                    Text("表示できるカードは以上です")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("もう一度見る") {
                        viewModel.resetCards()
                    }
                    .padding(.top, 20)
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
                
            } else {
                // --- 通常のカード表示 ---
                cards
            }
            
            // アクションボタンは常時表示させるか、カードがある時だけにするか選べる
            // ここではカードがある時だけ表示する
            if !viewModel1.profiles4.isEmpty && viewModel.currentIndex < viewModel1.profiles4.count {
                actions
            }
        }
        .background(.black, in: RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 6)
        // アニメーションを追加すると画面遷移が滑らかになる
        .animation(.easeInOut, value: viewModel.currentIndex)
    }
}

#Preview {
    ListView()
}

extension ListView {
    // Profiletatiは現在使われていないようですが、残しておきます
    var Profiletati: [Profile] {
        viewModel1.Profiles
    }

    private var cards: some View {
         ZStack {
             // データソースがない場合は何も表示しない
             if viewModel1.profiles4.isEmpty {
                 // 必要であればローディング表示など
                 ProgressView("読み込み中...")
                 
                 
             } else {
                 // ForEachで全カード情報をループ
                 ForEach(Array(viewModel1.profiles4.enumerated()), id: \.element.id) { index, user in
                     
                     // まだスワイプされていないカードだけを表示対象にする
                     if viewModel.currentIndex <= index {
                         
                         CardView(user: user) { isRedo in
                             viewModel.adjustIndex(isRedo: isRedo)
                         }
                         // Zインデックス（重なりの前後関係）を手前に持ってくる
                         .zIndex(Double(viewModel1.profiles4.count - index))
                         // 重ね順（index）に応じて、大きさと位置を計算して適用
                         .scaleEffect(calculateScale(for: index))
                         .offset(y: calculateOffset(for: index))
                         // パフォーマンスのため、表示するスタックを3枚程度に制限する
                         .opacity(index < viewModel.currentIndex + 3 ? 1 : 0)
                     }
                 }
             }
         }
     }
     
     // --- カードの見た目を計算するためのヘルパー関数 ---
     // この2つの関数もListViewのextension内またはstruct内にコピーしてください。
     
     /// 重ね順に応じたカードの縮小率を計算する
     private func calculateScale(for index: Int) -> CGFloat {
         let diff = CGFloat(index - viewModel.currentIndex)
         // 1枚目(diff=0)は1.0, 2枚目(diff=1)は0.95, 3枚目(diff=2)は0.9... と徐々に小さくする
         return 1.0 - diff * 0.05
     }

     /// 重ね順に応じたカードのY軸オフセット（位置）を計算する
     private func calculateOffset(for index: Int) -> CGFloat {
         let diff = CGFloat(index - viewModel.currentIndex)
         // 1枚目(diff=0)は0, 2枚目(diff=1)は-10, 3枚目(diff=2)は-20... と徐々に奥にずらす
         return diff * -10
     }
 

    // ListView.swift の extension または struct の中

    private var actions: some View {
        HStack(spacing: 68) {
            Button {
                viewModel.nopeBottonTapped(profiles: viewModel1.profiles4)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.red)
                    .background {
                        Circle()
                            .stroke(.red, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
            }
            
            Button {
                viewModel.redoBottonTapped(profiles: viewModel1.profiles4)
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.yellow)
                    .background {
                        Circle()
                            // 枠線の色もアイコンに合わせると綺麗です
                            .stroke(.yellow, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
            }
            
            Button {
                viewModel.likeBottonTapped(profiles: viewModel1.profiles4, viewModel: viewModel1)
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
        .foregroundStyle(.white)
        .frame(height: 100) //エリア全体に高さを持たせる
    }
}
