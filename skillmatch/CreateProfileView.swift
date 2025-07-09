//
//  CreateProfileView.swift
//  skillmatch
//
//  Created by 松佳 on 2025/07/05.
//

import SwiftUI

struct CreateProfileView: View {
    @StateObject private var viewModel = CommentViewModel()
    var onProfileCreated: () -> Void

    // --- State Variables ---
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var email: String = ""
    @State private var text: String = ""
    @State private var hasAgreedToPrivacyPolicy = false
    
    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
    //
    // プライバシーポリシーのシート表示を管理するState変数を追加
    @State private var isShowingPrivacyPolicy = false
    //
    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ようこそ！")) {
                    Text("最初にプロフィールを登録してください。")
                }
                
                Section(header: Text("プロフィール情報")) {
                    TextField("名前", text: $name)
                    
                    TextField("連絡先 (メールアドレスなど)", text: $email)
                }
                
                Section(header: Text("自己紹介")) {
                    TextEditor(text: $text)
                        .frame(height: 150)
                }
                
                Section(header: Text("利用規約への同意")) {
                    Toggle(isOn: $hasAgreedToPrivacyPolicy) {
                        Text("個人情報の取り扱いに同意する")
                    }
                    
                    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
                    //
                    // LinkをButtonに変更し、isShowingPrivacyPolicyをtrueにする
                    //
                    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
                    Button("プライバシーポリシーを読む") {
                        isShowingPrivacyPolicy = true
                    }
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("プロフィール作成")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存して開始") {
                        viewModel.Profadd(name:name,age:age,email:email,text:text)
                        // ... 保存処理 ...
                        onProfileCreated()
                        
                    }
                    .disabled(name.isEmpty || !hasAgreedToPrivacyPolicy)
                }
            }
            // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
            //
            // .sheetモディファイアを追加
            // isShowingPrivacyPolicyがtrueになったら、PrivacyPolicyViewを表示
            //
            // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
            .sheet(isPresented: $isShowingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}
