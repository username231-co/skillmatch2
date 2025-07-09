//
//  PrivacyPolicyVi.swift
//  skillmatch
//
//  Created by 松佳 on 2025/07/06.
//

import SwiftUI


#Preview {
    PrivacyPolicyView()
}
import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("この利用規約（以下、「本規約」といいます。）は、【運営者名】（以下、「当方」といいます。）が提供するアプリケーション「【相棒】」（以下、「本サービス」といいます。）の利用条件を定めるものです。本サービスを利用するすべてのユーザー（以下、「ユーザー」といいます。）は、本規約に同意の上、本サービスを利用するものとします。")
                    
                    sectionTitle("第1条（本サービスの内容）")
                    sectionBody("本サービスは、起業や新しいビジネスに関心を持つユーザー同士が、自身のスキルや経験を共有し、信頼できるビジネスパートナー（以下、「相棒」といいます。）を見つけることを目的としたマッチングプラットフォームです。")
                    
                    sectionTitle("第2条（利用登録）")
                    sectionBody("1. 本サービスの利用を希望する方は、本規約に同意した上で、当方が定める方法によりプロフィール情報等を登録し、利用登録を申請するものとします。\n2. ユーザーは、登録情報が常に真実、正確、最新であることを保証するものとします。")
                    
                    sectionTitle("第3条（プライバシーと個人情報）")
                    sectionBody("ユーザーの個人情報の取り扱については、別途定める「プライバシーポリシー」に従うものとします。当方は、ユーザーから取得した情報を、本サービスのスムーズな提供、機能改善、およびユーザー間の円滑なコミュニケーションの実現という目的の範囲内でのみ利用し、ユーザーの同意なく第三者に提供または開示することはありません。")
                    
                    sectionTitle("第4条（禁止事項）")
                    sectionBody("ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。")
                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("法令または公序良俗に違反する行為")
                        bulletPoint("虚偽の情報を提供する行為")
                        bulletPoint("他のユーザーに対する嫌がらせ、誹謗中傷、ストーカー行為")
                        bulletPoint("当方の許可なく、本サービスを商業目的、宗教活動、またはマルチ商法等の勧誘に利用する行為")
                        bulletPoint("他のユーザーの個人情報を不正に収集、公開する行為")
                        bulletPoint("本サービスのサーバーやネットワークに過度な負荷をかける行為")
                        bulletPoint("当方または第三者の知的財産権を侵害する行為")
                        bulletPoint("その他、当方が不適切と判断する行為")
                    }
                    
                    sectionTitle("第5条（免責事項）")
                    sectionBody("1. 当方は、本サービスを通じてユーザー間で成立したマッチングや、その後の事業活動の結果について、一切の責任を負いません。ユーザー間のトラブルは、当事者間で解決するものとします。\n2. 当方は、本サービスが全てのユーザーの期待を満たすこと、または特定の相棒とのマッチングが成立することを保証するものではありません。\n3. 当方は、システムの保守や障害により、予告なく本サービスの提供を一時的に中断することがあります。これによりユーザーに生じた損害について、当方は責任を負いません。")
                    
                    sectionTitle("第6条（知的財産権）")
                    sectionBody("本サービスを構成する文章、画像、プログラム、アイコン等の一切のコンテンツに関する知的財産権は、ユーザー自身が作成したものを除き、すべて当方に帰属します。")

                    sectionTitle("第7条（利用停止・退会）")
                    sectionBody("1. ユーザーが本規約に違反したと当方が判断した場合、当方は事前の通知なく、当該ユーザーの利用を一時停止または強制的に退会させることができるものとします。\n2. ユーザーは、当方が定める手続きにより、いつでも本サービスから退会することができます。")

                    sectionTitle("第8条（本規約の変更）")
                    sectionBody("当方は、必要に応じて、ユーザーへの事前の通知なく本規約を変更できるものとします。変更後の規約は、本サービス内に掲載された時点から効力を生じるものとします。")

                    sectionTitle("第9条（準拠法・管轄裁判所）")
                    sectionBody("本規約の解釈にあたっては、日本法を準拠法とします。本サービスに関して紛争が生じた場合には、【東京地方裁判所】を第一審の専属的合意管轄裁判所とします。")

                    // 附則
                    VStack(alignment: .trailing) {
                        Text("附則")
                        Text("制定日：2025年7月6日")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                }
                .padding()
            }
            .navigationTitle("利用規約")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // ヘルパー関数で見やすくしています
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
    
    @ViewBuilder
    private func sectionBody(_ body: String) -> some View {
        Text(body)
            .font(.subheadline)
            .lineSpacing(5)
    }

    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("・")
            Text(text)
        }
        .font(.subheadline)
        .lineSpacing(5)
    }
}



