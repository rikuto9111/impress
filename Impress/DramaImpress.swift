//
//  DramaImpress.swift
//  Impress
//
//  Created by user on 2025/03/06.
//

import SwiftUI

struct DramaImpress: View {
    @State var ismainNavigation   = false//4つのフラグで4画面をメインから制御
    @State var isreadNavigation   = false
    @State var ismovieNavigation  = false
    @State var isanimeNavigation  = false
    @State var isdoramaNavigation = false
    
    var body: some View {
        NavigationLink(destination:ContentView(),isActive: $ismainNavigation){
            
        }
        .navigationBarBackButtonHidden(true)
        
        NavigationLink(destination:ReadImpress(),isActive: $isreadNavigation){
            
        }
        NavigationLink(destination:AnimeImpress(),isActive: $isanimeNavigation){
            
        }
        NavigationLink(destination:DramaImpress(),isActive: $isdoramaNavigation){
            
        }
        
        Spacer()
            .frame(height:40)
        Text("映画記録")
            .font(.largeTitle)
            .frame(width: 500,height: 100)
            .background(Color.green)
        Spacer()
        HStack(spacing:30){//4画面へのボタン
            Button("初期"){
                ismainNavigation = true
            }
            
            Button("読書"){
                isreadNavigation = true
            }
            Button("映画"){
                ismovieNavigation = true
            }
            Button("アニメ"){
                isanimeNavigation = true
            }
            Button("ドラマ"){
                isdoramaNavigation = true
            }
        }
    }
}

#Preview {
    DramaImpress()
}
