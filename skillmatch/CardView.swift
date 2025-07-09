//
//  CardView.swift
//  MatchingWithSwiftUI
//コードの分離
//  Created by 中村優介 on 2025/05/27.
//起点からの距離として制御

import SwiftUI

struct CardView: View {
    @State private var offset : CGSize = .zero // CGSize(width: 0, height: 0)の省略形
    //@Stateで動かすことができる
    let user: Profile
    let adjustIndex: (Bool) -> Void
    @StateObject private var viewModel1 = CommentViewModel()


    var body: some View {
        ZStack(alignment:.bottom) {
            //画像の上にテキスト要素
            //Background
            Image("3da6a1c7218c76750a71770c512a0064")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 600)
                // .frame(width: 400) のような固定サイズではなく、
                // ZStack全体に広がるように .ignoresSafeArea() などを使うのが一般的
            
            // ユーザー画像レイヤー
            // もしユーザー画像があるなら、これが背景画像の上に重なる
            //imageLayar
            
            // グラデーション
            LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom)
            
            // 情報レイヤー
            infomationLayar
            
            // Like と Nope の表示
            LikeAndNope
        }
        .frame(width: 400, height: 600)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .offset(offset) //変数にして後から制御できるようにする
        .gesture(gesture)
        .scaleEffect(scale)
        .rotationEffect(.degrees(angle))
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NOPEAUTION"),object: nil)){
            data in
            print("ListViewModelからの通知を受信しました \(data)")
            guard
                  let info = data.userInfo,
                  let id = info["id"] as? String
                  else { return }
            if id == user.id {
                removeCard(isLiked: false)
               }
                    }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LIKEACTION"),object: nil)){
            data in
            print("ListViewModelからの通知を受信しました \(data)")
            
            guard
                  let info = data.userInfo,
                  let id = info["id"] as? String
                  else { return }
            if id == user.id {
                removeCard(isLiked: true)
                
                        
               }
                    }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("REDOACTION"),object: nil)){
            data in
            print("ListViewModelからの通知を受信しました \(data)")
            guard
                  let info = data.userInfo,
                  let id = info["id"] as? String
                  else { return }
            if id == user.id {
                resetCard()
               }
                    }
    }
}

#Preview {
    ListView()
}

// MARK: -UI
extension CardView {
    private var imageLayar : some View {
        Image("3da6a1c7218c76750a71770c512a0064")
            .resizable() // 全体に合わせる
            .aspectRatio(contentMode: .fill) // 元々の比
            .frame(width: 400)
    }
}


extension CardView {
    private var screenWidth: CGFloat {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else
        { return 0.0}
        return window.screen.bounds.width
    }
    private var scale : CGFloat {
        return max(1.0 - (abs(offset.width) / screenWidth), 0.75)
  
    }
    private var angle: Double { //degreesメソッドがDoubleのため
        return (offset.width / screenWidth) * 10.0
    }
    private var opacity: Double {
        return offset.width / screenWidth * 4.0
    }


    
    private var infomationLayar : some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                Text(user.name)
                    .font(.largeTitle.bold())
                Text("\(user.age)")
                    .font(.title2)
                Image(systemName: "checkmark.seal.fill") // SF Symbols
                    .foregroundStyle(.white, .blue) // 中を白、チェックをブルー
                    .font(.title2)
            }
            
            Text(user.text)
            Text(user.email)
            
            
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var LikeAndNope: some View {
        VStack{
            HStack {
                //Like
                Text("LIKE")
                    .tracking(4)
                    .foregroundStyle(.green)
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .padding(.horizontal,8)
                    .padding(.vertical,2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.green, lineWidth: 5)
                        
                    )
                    .rotationEffect(Angle(degrees: -15))
                    .offset(x: 16, y: 30)
                    .opacity(opacity)
                
                
                Spacer()
                //Nope
                Text("NOPE")
                    .tracking(4)
                    .foregroundStyle(.red)
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .padding(.horizontal,8)
                    .padding(.vertical,2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 5)
                        
                        
                    )
                    .rotationEffect(Angle(degrees: 15))
                    .offset(x: -16, y: 30)
                    .opacity(-opacity)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            Spacer()
        }
        
    }
}

// MARK: -Action
extension CardView {
    private var gesture : some Gesture {
        DragGesture()
            .onChanged { value in
                let width = value.translation.width

                let height = value.translation.height
//三項演算子を利用
//trueなら：の左側の処理Falseなら：の右側の処理
                let limitedHeight = height > 0 ? min(height, 100) : max(height, -100)

                offset = CGSize(width: width, height: limitedHeight )
            }
            .onEnded { value in
                let width = value.translation.width
                let height = value.translation.height

                if (abs(width) > (screenWidth / 4)) {
                    // isLikedを定数にしておくと、より分かりやすくなります
                    let isLiked = width > 0

                    removeCard(isLiked: isLiked, height: height)
                    viewModel1.cardkidoku(kidokuuserId: user.id ?? "aaa")
                    
                    // ✅ isLiked が true の時（右スワイプの時）だけ、いいね処理を呼び出す
                    if isLiked {
                        // user.idがnilでないことを確認し、安全に取り出す
                        if let userID = user.id {
                            print("いいねのアクションを実行します")
                            viewModel1.iinetsuika(userIdUketoru: userID)
                        }
                    }
                } else {
                    resetCard()
                }
            }
        
                }
            }
// MARK: -Action
extension CardView {
    // ... gestureの定義 ...
    
    private func removeCard(isLiked: Bool, height: CGFloat = 0.0) {
        withAnimation(.smooth) {
            offset = CGSize(width: isLiked ? screenWidth * 1.5 : -screenWidth * 1.5, height: height)
        }
        // ✅【重要】カードを消した時にインデックスを進める
        adjustIndex(false) // isRedo: false を渡す
    }
    
    private func resetCard() {
        withAnimation(.smooth) {
            offset = .zero
        }
        // ✅ カードが中央に戻るだけなので、インデックスは操作しない
        // adjustIndex(true) // ← この行をコメントアウトまたは削除
    }

    // ...
}


