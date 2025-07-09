//
//  ListView.swift
//  MatchingWithSwiftUI
//
//  Created by 中村優介 on 2025/05/25.
//

import SwiftUI

struct ListView: View {
    private var viewModel = ListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            //cards
            cards
           
            //action
            actions
            

            
            
        }
        .background(.black, in : RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 6)
    }
    
    }


#Preview {
    ListView()
}
extension ListView {
    
    private var cards: some View {
        ZStack {
            ForEach(viewModel.users.reversed()) { user in
                CardView(user: user){ isRedo in
                    viewModel.adjustIndex(isRedo: isRedo)
                }
            }
        }
        
    }
    private var actions: some View {
        HStack(spacing: 68) {
            Button {
                viewModel.nopeBottonTapped()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.red)
                    .background {
                        Circle()
                            .stroke(.red, lineWidth: 1)//図形に枠線を引くとき
                        
                            .frame(width: 60, height: 60)
                          
                            
                    }
                
                
            }
            Button {
                viewModel.redoBottonTapped()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.yellow)
                    .background {
                        Circle()
                            .stroke(.red, lineWidth: 1)//図形に枠線を引くとき
                        
                            .frame(width: 60, height: 60)
                          
                            
                    }
                
                
            }
            Button {
                viewModel.likeBottonTapped()
            } label: {
                Image(systemName: "heart")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.mint)
                    .background {
                        Circle()
                            .stroke(.red, lineWidth: 1)//図形に枠線を引くとき
                        
                            .frame(width: 60, height: 60)
                          
                            
                    }
                
                
            }


        }
          
        .foregroundStyle(.white)
        .frame(height: 100)//エリア全体に高さを持たせる
        
    }
}

