//
//  CommentViewModel.swift
//  skillmatch
//
//  Created by 松佳 on 2025/05/28.
//
import SwiftUI
import Foundation
import FirebaseFirestore

struct Profile: Identifiable{
    @DocumentID var id: String?
    var name1: String
    var age1: String//データベースに入れる時にintに直して入れている
    var email: String
    var text1: String
    
}

struct Boshyu: Identifiable{//募集型
    @DocumentID var id: String?
    var name: String//名前
    var age: String//年齢
    var title: String//タイトル
    var text: String//募集本文
    var SNSdore: String//下のIDはインスタかxかどっちなのか
    var SNSid: String//id
    var likedBy: [String] // 追加 → ユーザーIDのリスト
}


struct LikeNotification: Identifiable, Codable {//いいね送られた後の処理
    @DocumentID var id: String?
    var fromUserId: String   // いいねした人
    var postId: String       // 対象の募集ID（Boshyu）
    var timestamp: Timestamp // 通知時刻
}




class CommentViewModel: ObservableObject {
    @Published var Profiles: [Profile] = []
    @Published var boshyus: [Boshyu] = []
    private var db = Firestore.firestore()
    init(){
        fetchBoshyus()
    }
    func fetchBoshyus() {
        db.collection("Bosyu1").addSnapshotListener { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.boshyus = docs.compactMap { doc in
                let data = doc.data()
                
                // 安全にオプショナルをアンラップする
                guard let name = data["name"] as? String,
                      let title = data["title"] as? String,
                      let text = data["text"] as? String,
                      let SNSdore = data["SNSdore"] as? String,
                      let SNSid = data["SNSid"] as? String else {
                    print("データが不足しています: \(doc.documentID)")
                    return nil
                }
                
                let age = String(data["age"] as? Int ?? 0)
                let likedBy = data["likedBy"] as? [String] ?? [] // 存在しない場合は空配列にする
                
                return Boshyu(
                    id: doc.documentID,
                    name: name,
                    age: age,
                    title: title,
                    text: text,
                    SNSdore: SNSdore,
                    SNSid: SNSid,
                    likedBy: likedBy
                )
            }
        }
    }

    func addBoshyu(name: String,age: String,title: String,text: String,SNSdore: String,SNSid: String){
        let ageInt = Int(age) ?? 0
        let userId = getOrCreateUserId()
        let newBoshyu: [String:Any] = ["name":name,"age":ageInt,"title":title,"text":text,"SNSdore":SNSdore,"SNSid":SNSid]
        db.collection("Bosyu1").document(userId).setData(newBoshyu) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
        }
        

    }
    
    func fetchProf(for userId: String) {
        let userId = getOrCreateUserId()
        db.collection("first").document(userId).getDocument {(document,error)in
            if let error = error {
                print("エラー")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as! String
                let age = String(data?["age"] as? Int ?? 0)
                let email = data?["email"] as! String
                let text = data?["text"] as! String
                self.Profiles.append(Profile(name1: name, age1: age, email: email, text1: text))
            }
            
        }
    }
    
    func Profadd(name:String,age:String,email:String,text:String){
        let ageInt = Int(age) ?? 0
        let userId = getOrCreateUserId()
        let newProfile: [String:Any] = ["name": name,"age":ageInt,"email":email,"text":text]
        db.collection("first").document(userId).setData(newProfile) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
        }
        
    }
    
    func getOrCreateUserId() -> String {
        if let existingId = UserDefaults.standard.string(forKey: "userId") {
            return existingId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "userId")
            return newId
        }
    }
}

struct ProfileView: View {
    @State var name1:String=""
    @State var age2:String=""
    @State var text2:String=""
    @State var name:String=""
    @State var age:String=""
    @State var email:String=""
    @State var text:String=""
    @State var title:String=""
    @State var SNSdore:String=""
    @State var SNSid:String=""
    @StateObject private var viewModel = CommentViewModel()
    var body: some View {
        TabView{
            VStack {
                Text("プロフィール登録")
                
                TextField("名前を入力",text:$name1).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("年齢を入力",text:$age).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("gmailを入力",text:$email).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("自己紹介を入力",text:$text).textFieldStyle(RoundedBorderTextFieldStyle())
                Button("送信"){
                    viewModel.Profadd(name:name,age:age,email:email,text:text)
                }
                if let profile = viewModel.Profiles.first {
                    Text("名前: \(profile.name1)")
                    Text("年齢: \(profile.age1)")
                    Text("メール: \(profile.email)")
                    Text("ひとこと: \(profile.text1)")
                } else {
                    Text("読み込み中...")
                }
            }
            .onAppear {
                let userId = viewModel.getOrCreateUserId()
                viewModel.fetchProf(for: userId)
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("ホーム")
            }
            VStack{
                Text("募集追加")
                    .font(.headline)
                TextField("名前を入力",text:$name).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("年齢を入力",text:$age).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("titleを入力",text:$title).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("textを入力",text:$text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("SNSはどれですか",text:$SNSdore)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("SNSのIDを入力",text:$SNSid)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("送信"){
                    viewModel.addBoshyu(name:name,age:age,title:title,text:text,SNSdore:SNSdore,SNSid:SNSid)
                }
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("ホーム")
            }
            BoshyuView()
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("ホーム")
                }
            
        }
    }
    }


#Preview {
    ProfileView()
}


struct BoshyuView: View {
    @StateObject var viewModel=CommentViewModel()
 
    var Boshyutati: [Boshyu] {
        viewModel.boshyus
    }
    var body: some View {
        VStack {
            Text("募集掲示板")
                .font(.headline)
                .padding(.top, 16)

            Button("Load") {
                print(viewModel.boshyus)
            }

            Divider()

            // 投稿一覧だけスクロール可能にする
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.boshyus) { boshyu in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(boshyu.name)
                                .foregroundColor(Color.blue)
                            HStack{
                                Text(boshyu.age)
                                Text("歳")
                            }
                            Text(boshyu.title)
                            Text(boshyu.text)
                            HStack{Image(systemName: "bubble.left")
                                Image(systemName: "heart") }
                            .foregroundColor(.gray)

                            Divider()
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    
    
}
