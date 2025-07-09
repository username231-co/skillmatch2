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
    var name: String
    var age: String//データベースに入れる時にintに直して入れている
    var email: String
    var text: String
    var photoUrl : String? //画像を設定しないケース
    var message: String? //メッセージを書かないケース
    
    
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

struct like: Identifiable {
    var id: String
    var timestamp: Timestamp
    var formattedTimestamp: String {
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormatter.string(from: date)
    }
}



struct Profilekidoku: Identifiable,Codable {
    var id:String
}



class CommentViewModel: ObservableObject {
    @Published var Profiles: [Profile] = []
    @Published var boshyus: [Boshyu] = []
    private var db = Firestore.firestore()
    @Published var Profiles2: [Profile] = []
    @Published var likes: [like] = []
    @Published var profiles3: [Profile] = []
    @Published var ProfilesKidoku: [Profilekidoku] = []
    @Published var profiles4: [Profile] = []
    
    init(){
        fetchProfiles()
        fetchBoshyus()
        listenForNotifications()
        fetchmidoku {
                // ② fetcHeidokuの中でcompletion()が呼ばれた後に、ここが実行される
                // これで正しいタイミングで洗濯物を取り出せる（チェックできる）
                self.eidokuyosoz()
            }
        
            }//このクラスがインスタンス化されたらまずここが実行される。ここがあるため、下の実行文でfetchBoshyusの記載なし
    func fetchProfiles() {
        
        db.collection("first").addSnapshotListener { snapshot, er in
            guard let docs = snapshot?.documents else { return }
            self.Profiles2=docs.compactMap { doc in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let text = data["text"] as? String,
                      let email=data["email"] as? String else {
                    print("データが不足していますよん1: \(doc.documentID)")
                    return nil
                }
                let age = String(data["age"] as? Int ?? 0)
                
                return Profile(
                    id: doc.documentID,
                    name: name,
                    age: age,
                    email: email,
                    text: text,
                )
            }
            //print("みせて-------------------------------\(self.Profiles2)")

        }
        
        
        
        
    }
    func fetchBoshyus() {//募集データの読み取り
        db.collection("Bosyu1").addSnapshotListener { snapshot, error    in//addsnapshotlistener監視カメラ的な存在で変更があるたび即更新が実行される。snapshotは読みってきたデータ、色々入っていいる
            guard let docs = snapshot?.documents else { return }//例外処理（データがあるかの確認）、もし空やった場合下の処理はしなくていいよって意味→データが読み取れたら次に進む
            self.boshyus = docs.compactMap { doc in//シンプルに登録の部分。docsは取ってきたドキュメントのリスト。compactMapはdocsの要素を一個ずつdocにいれる
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
    
    func addBoshyu(name: String,age: String,title: String,text: String,SNSdore: String,SNSid: String){//データ追加の話、これらは引数で受け取る
        let ageInt = Int(age) ?? 0//intに直す
        let userId = getOrCreateUserId()//user固有IDを下の関数から作って受け取る
        let newBoshyu: [String:Any] = ["name":name,"age":ageInt,"title":title,"text":text,"SNSdore":SNSdore,"SNSid":SNSid]//データをここに格納する
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
                self.Profiles.append(Profile(name: name, age: age, email: email, text: text))
            }
            
        }
    }
    func listenForNotifications() {//いいねされた人の表示処理
        let userId = getOrCreateUserId()
        
        db.collection("first").document(userId).collection("liketsuika")
            .order(by: "likedAt", descending: true)//.orderはミスるとからの文字列になるから注意（１時間苦戦した）
            .addSnapshotListener { querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {//(querySnapshotである理由はわからん
                    print("いいね通知の取得に失敗: \(error?.localizedDescription ?? "不明なエラー")")
                    return
                }
                
                // --- ステップ1：まず `like` オブジェクトの配列を同期的に作成する ---
                let fetchedLikes = documents.compactMap { doc -> like? in // `like?` を返すことを明記
                    let data = doc.data()
                    guard let likerId = data["userId"] as? String,
                          let likedAt = data["likedAt"] as? Timestamp else {
                        return nil//上二つが揃わなければnilを返す
                    }
                    
                    // ここで `like` オブジェクトをすぐに返す
                    // (注意: あなたの `like` モデルの定義に合わせてください)
                    return like(id: likerId, timestamp: likedAt)//fechedLikesに返す
                }
                
                // ViewModelのプロパティに、まずは基本的な `like` のリストを反映
                self.likes = fetchedLikes//扱いやすいようにlikesに入れる。/クラスの中なのでselfはいる
                
                self.profiles3 = []
                
                // --- ステップ2：取得した `like` リストを元に、各プロフィールを取得する ---
                // 毎回プロフィールリストを初期化する
                
                
                for like in fetchedLikes {//fetchedの中から一個一個入れる
                    // addSnapshotListenerではなく、一度だけデータを取得する getDocument を使うのが一般的
                    self.db.collection("first").document(like.id).getDocument { documentSnapshot, error in
                        guard let data = documentSnapshot?.data(), error == nil else {
                            print("プロフィールの取得に失敗1: \(like.id)")
                            return
                        }
                        
                        // Profileオブジェクトを作成
                        guard let name = data["name"] as? String,
                              let text = data["text"] as? String,
                              let email = data["email"] as? String else {
                            print("プロフィールのデータが不足: \(like.id)")
                            return
                        }
                        let age = String(data["age"] as? Int ?? 0)
                        let profile = Profile(id: like.id, name: name, age: age, email: email, text: text)
                        
                        // メインスレッドでUI用の配列に追加する
                        DispatchQueue.main.async {
                            self.profiles3.append(profile)//この追加でいい
                        }
                    }
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
    func iinetsuika(userIdUketoru:String){
        let userId = getOrCreateUserId()
        let likeData: [String: Any] = [
            "userId":userId,
            "likedAt": Timestamp(date: Date()) // 現在の日時
        ]
        db.collection("first").document(userIdUketoru).collection("liketsuika").document(userId).setData(likeData){error in
            if let error = error{
                print("エラー：いいね失敗")
            }else{
                print("成功：いいね")
            }}
        
        
    }
    func cardkidoku(kidokuuserId:String){
        let userId = getOrCreateUserId()
        let kidokusan: [String: Any] = [
            "userId":kidokuuserId,
        ]
        db.collection("first").document(userId).collection("kidokuuser").addDocument(data: kidokusan){error in
            if let error = error{
                print("エラー：いいね失敗")
            }else{
                print("成功：いいね2")
            }}
    }
    func checkIfProfileExists(completion: @escaping (Bool) -> Void) {
        let userId = getOrCreateUserId()
        db.collection("first").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                // プロフィールが見つかった場合
                completion(true)
            } else {
                // プロフィールが見つからなかった場合
                completion(false)
            }
        }
    }
    func fetchmidoku(completion: @escaping () -> Void){
        let userId = getOrCreateUserId()
        
        db.collection("first").document(userId).collection("kidokuuser").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Snapshot取得失敗")
                return
            }
            let fetchmidoku = documents.compactMap{doc -> Profilekidoku? in
                let data = doc.data()
                guard let  userId = data["userId"] as? String else { return nil }
                
                return Profilekidoku(id: userId)
                
            }
            self.ProfilesKidoku = fetchmidoku
            
            completion()
        }
    }
    func eidokuyosoz() {
        var ProfIditiziteki = [] as [String]
        
        // ステップ1：スワイプ済みのIDの「チェックリスト(Set)」を先に一度だけ作成する
        // .mapでIDだけを取り出し、Set()でSet型に変換
        let dokuIdSet = Set(self.ProfilesKidoku.map { $0.id })
        print("チェック対象のIDセット: \(dokuIdSet)")
        
        // ステップ2：全ユーザーをループし、高速なチェックを行う
        for prof in self.Profiles2 {
            guard let profId = prof.id else { continue } // prof.idがnilの場合はスキップ
            
            // Setの.contains()は非常に高速
            if dokuIdSet.contains(profId) {
                print("\(prof.name)のIDは、Profilesldokuに既に存在します。")
            } else {
                print("\(prof.name)のIDは、まだ存在しません。")
                ProfIditiziteki += [profId]
                print("ProfIditiziteki: \(ProfIditiziteki)")
            }
        }
        
        for id1 in ProfIditiziteki {
            self.db.collection("first").document(id1).getDocument { documentSnapshot, error in
                guard let data = documentSnapshot?.data(), error == nil else {
                    print("プロフィールの取得に失敗1: \(id1)")
                    return
                }
                
                // Profileオブジェクトを作成
                guard let name = data["name"] as? String,
                      let text = data["text"] as? String,
                      let email = data["email"] as? String else {
                    print("プロフィールのデータが不足: \(id1)")
                    return
                }
                let age = String(data["age"] as? Int ?? 0)
                let profile = Profile(id: id1, name: name, age: age, email: email, text: text)
                self.profiles4.append(profile)
                print("途中ですが失礼しますーーーーーーーーーーー\(profile)")
                DispatchQueue.main.async {
                    self.profiles4.append(profile)
                    print("プロフ確認33-------------------------------------\(self.profiles4)")
                    //この追加でいい
                    
                }
            }
        }
        print("プロフ444555555555-------------------------------------\(self.profiles4)")
        
    }
    func sakujo(completion: @escaping () -> Void){
        let userId = getOrCreateUserId()
        db.collection("first").document(userId).delete(){ error in
            if let error = error {
                print("アカウントの削除に失敗しました: \(error)")
            } else {
                print("アカウントを削除しました。")
            }
        }
        completion()
    }
    func TuuhouandBlockBoton(id3: String){
        var data:[String:Any] = ["userId": id3]
        db.collection("tuuhou").document(id3).setData(data){error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
            
        }
    }
}
import SwiftUI

// MARK: - プロフィール表示View
struct ProfileView: View {
    @StateObject private var viewModel = CommentViewModel()
    @State private var isDeletionComplete = false
    var body: some View {
        TabView{
            // 画面遷移のためにNavigationStackで囲む
            NavigationStack {
                VStack() {
                    if isDeletionComplete {
                        // 削除が完了した場合のメッセージ
                        Text("削除が完了しました。アプリを再起動してください。")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    } else {
                        // まだ削除ボタンが押されていない場合の表示
                        Button("アカウントを削除") {
                            // ViewModelの関数を呼び出し、完了後の処理を { } の中に書く
                            viewModel.sakujo {
                                // この中は削除が完了した後に実行される
                                // State変数をtrueにして、表示をメッセージに切り替える
                                self.isDeletionComplete = true
                            }
                        }
                        .tint(.red)
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 20)
                    }
                }
                VStack(spacing: 0) {
                    // プロフィール情報が読み込めたら表示
                    if let profile = viewModel.Profiles.first {
                        // プロフィール詳細の表示部分を別のViewとして切り出し
                        ProfileDetailCard(profile: profile)
                        Spacer() // 上に寄せる
                    } else {
                        // 読み込み中、またはプロフィールが存在しない場合
                        ProgressView()
                        Spacer()
                    }
                }
                
                .navigationTitle("マイプロフィール") // ナビゲーションバーのタイトル
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // ナビゲーションバーの右上に「編集」ボタンを配置
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // プロフィール情報がある時だけ編集ボタンを表示
                        if let profile = viewModel.Profiles.first {
                            // 編集画面へのリンク
                            NavigationLink(destination: EditProfileView(viewModel: viewModel, currentProfile: profile)) {
                                Text("編集")
                            }
                        }
                    }
                }
                .onAppear {
                    // この画面が表示された時にプロフィール情報を読み込む
                    let userId = viewModel.getOrCreateUserId()
                    viewModel.fetchProf(for: userId)
                }
            }
            .tabItem {
                Image(systemName: "person.circle.fill") // アイコン例
                Text("プロフィール") // 例：最初のタブ
            }
            
            
            ProfView2(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.2.fill") // アイコン例
                    Text("一覧") // 例
                }
                ListView()
              
                .tabItem {
                    Image(systemName: "magnifyingglass") // アイコン例
                    Text("検索") // 例
                }
            
            liketabView()
                .tabItem {
                    Image(systemName: "heart.fill") // アイコン例
                    Text("いいね") // 例
                }
        }
    }
}
import SwiftUI

// MARK: - プロフィール編集View
struct EditProfileView: View {
    // 親ViewからViewModelを引き継ぐ
    @ObservedObject var viewModel: CommentViewModel
    let currentProfile: Profile
    
    // 編集用のState変数
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var email: String = ""
    @State private var text: String = ""
    
    // この画面を閉じるための機能
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("プロフィール情報")) {
                TextField("名前（任意）", text: $name)
                TextField("年齢", text: $age)
                    .keyboardType(.numberPad) // 年齢なので数字キーボード
                TextField("メールアドレス", text: $email)
                    .keyboardType(.emailAddress) // メールなのでメール用キーボード
            }
            
            Section(header: Text("自己紹介")) {
                // 複数行入力できるようにTextEditorを使用
                TextEditor(text: $text)
                    .frame(height: 150)
                
            }
            
        }
        .navigationTitle("プロフィールを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 保存ボタン
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    // ViewModelの更新メソッドを呼び出す
                    viewModel.Profadd(name: name, age: age, email: email, text: text)
                    // 保存したら元の画面に戻る
                    dismiss()
                }
            }
        }
        .onAppear {
            // この画面が表示された時に、現在のプロフィール情報でフォームを初期化
            self.name = currentProfile.name
            self.age = currentProfile.age
            self.email = currentProfile.email
            self.text = currentProfile.text
        }
    }
}

// MARK: - プロフィール詳細表示用のカードUI
struct ProfileDetailCard: View {
    let profile: Profile
    
    var body: some View {
        VStack(spacing: 20) {
            // プロフィール画像（仮）
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(.gray.opacity(0.3))
                .padding(.top, 30)

            // Formを使って情報を整理して表示
            Form {
                Section(header: Text("基本情報").font(.headline)) {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .foregroundStyle(.secondary)
                        Text("名前")
                        Spacer()
                        Text(profile.name)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "number")
                             .foregroundStyle(.secondary)
                        Text("年齢")
                        Spacer()
                        Text("\(profile.age) 歳")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                             .foregroundStyle(.secondary)
                        Text("メール")
                        Spacer()
                        Text(profile.email)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section(header: Text("自己紹介").font(.headline)) {
                    Text(profile.text)
                }
            }
        }
        .background(Color(.systemGroupedBackground)) // 背景色
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

struct ProfView2: View {
    @ObservedObject var viewModel: CommentViewModel
    
    // ❌ isVisibleは使わない
    // @State private var isVisible = true
    
    // ✅ 非表示にした投稿のIDを保存するためのSet（リスト）を用意する
    @State private var hiddenProfileIDs: Set<String> = []
    
    var body: some View {
        ZStack {
            VStack {
                Text("プロフィール一覧")
                    .font(.headline)
                    .padding(.top, 16)
                
                // ... (デバッグボタンなどはそのまま)
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        // ForEachは変更なし
                        ForEach(viewModel.Profiles2) { profile in
                            
                            // ✅ この投稿が「非表示リスト」に含まれていない場合のみ、中身を表示する
                            if !hiddenProfileIDs.contains(profile.id ?? "") {
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    // ... (投稿内容のText表示部分はそのまま)
                                    Text(profile.name)
                                        .font(.headline)
                                        .foregroundColor(Color.blue)
                                    
                                    HStack {
                                        Text(profile.age)
                                        Text("歳")
                                        Text(profile.email)
                                    }
                                    .font(.subheadline)
                                    
                                    Text(profile.text)
                                        .font(.body)
                                    
                                    HStack {
                                        Button("非表示&ブロック") {
                                            // ✅ isVisibleをfalseにする代わりに、この投稿のIDを非表示リストに追加する
                                            if let id = profile.id {
                                                hiddenProfileIDs.insert(id)
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .padding()
                                        
                                        Button("通報") {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            viewModel.TuuhouandBlockBoton(id3: profile.id ?? "aaa")
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                }
                                .padding(.vertical, 4)
                                
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}


import SwiftUI

struct liketabView: View {
    @StateObject private var viewModel = CommentViewModel()
    @State private var hiddenLikeIDs: Set<String> = []

    // 💡 ここにヘルパー関数を定義
    private func getProfile(for likeItem: like) -> Profile? {
        // プロフィール配列から、likeItemのユーザーIDに一致するものを探す
        // 注意: `likeItem.uid` の部分はあなたのモデルに合わせてください (例: likeItem.userID)
        return viewModel.profiles3.first(where: { $0.id == likeItem.id })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.likes.isEmpty {
                    Spacer()
                    Text("まだいいねはありません")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.likes) { likeItem in
                            if !hiddenLikeIDs.contains(likeItem.id) {
                                
                                // ✅ ヘルパー関数を使って、プロフィール検索を一行でシンプルに！
                                if let profile = getProfile(for: likeItem) {
                                    
                                    LikeNotificationRow(
                                        profile: profile,
                                        likeItem: likeItem,
                                        onHide: {
                                            hiddenLikeIDs.insert(likeItem.id)
                                            viewModel.TuuhouandBlockBoton(id3: profile.id ?? "")
                                        },
                                        onReport: {
                                            viewModel.TuuhouandBlockBoton(id3: profile.id ?? "")
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("いいねしてくれた人")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.listenForNotifications()
        }
    }
}


// MARK: - Listの各行のUI部品
struct LikeNotificationRow: View {
    // このビューで表示するデータ
    let profile: Profile
    let likeItem: like
    
    // 親ビューから渡されるアクション
    var onHide: () -> Void
    var onReport: () -> Void
    
    // ❌ isVisibleは不要なので削除
    // @State private var isVisible = true
    
    // ❌ 各行でViewModelを生成するのは避ける
    // @StateObject private var viewModel = CommentViewModel()

    var body: some View {
        // if isVisible は削除し、VStackから始める
        VStack {
            HStack(alignment: .top, spacing: 16) {
                // ... (プロフィール画像やテキスト情報の部分は変更なし)
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.gray.opacity(0.4))
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .bottom) {
                        Text(profile.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("\(profile.age)歳")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(profile.text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                    Text(likeItem.formattedTimestamp)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 10)
            
            HStack {
                Button("非表示&ブロック") {
                    // ✅ isVisibleを操作する代わりに、親から渡されたアクションを実行する
                    onHide()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Button("通報") {
                    // ✅ 同じく、親から渡されたアクションを実行する
                    onReport()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

//struct ProgressView: View {
    //@StateObject private var viewModel = CommentViewModel()
    
    //var body: some View {
        //Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa--------------------------------------------")

//[skillmatch.Profile(_id: FirebaseFirestore.DocumentID<Swift.String>(value: Optional("079120EA-AA08-4879-B60F-D789472B4E23")), name: "めしこ", age: "19", email: "Ads@gmail.com", text: "サウナテント貸し出し事業やってます。興味ある方ボランティアで募集中", photoUrl: nil, message: nil),
//skillmatch.Profile(_id: FirebaseFirestore.DocumentID<Swift.String>(value: Optional("7EC2CFDD-CE9A-419C-A94E-8F855534CADD")), name: "こめお", age: "20", email: "@komeo_1256", text: "物販してます", photoUrl: nil, message: nil),


