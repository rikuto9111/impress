//
//  EigaImpress.swift
//  Impress
//
//  Created by user on 2025/03/06.
//

import SwiftUI
import RealmSwift

struct EigaImpress: View {
    
    @ObservedResults(EigaCount.self) var eigacount
    
    @State var ismainNavigation   = false//4つのフラグで4画面をメインから制御
    @State var isreadNavigation   = false
    @State var ismovieNavigation  = false
    @State var isanimeNavigation  = false
    @State var isdoramaNavigation = false
    @State var islistActive = false
    
    @State var nowmonth     = -1
    
    @State var searchword = ""
    
    
     var moviedatalist = ReadDatamovie()//まずインスタンス生成　このクラスはObserveマクロ
    
    
    var body: some View {
        
        NavigationStack{//遷移の範囲を決める
            NavigationLink(destination:ContentView(),isActive: $ismainNavigation){
                
            }
            .navigationBarBackButtonHidden(true)
            
            NavigationLink(destination:ReadImpress(),isActive: $isreadNavigation){
                
            }
            NavigationLink(destination:AnimeImpress(),isActive: $isanimeNavigation){
                
            }
            NavigationLink(destination:DramaImpress(),isActive: $isdoramaNavigation){
                
            }
            
            NavigationLink(destination:EigaImpress(),isActive: $ismovieNavigation){
                
            }
            NavigationLink(destination:Movielist(),isActive: $islistActive){
                
            }
            ZStack{
                Image(.moviebackground)// 背景をタップ可能にする
                    .resizable()
                    .ignoresSafeArea()
                    .onTapGesture {//それがここ　タップした時の反応　これって部品全部に持ってるのかな
                        hideKeyboard3()
                    }
                VStack{
                    Spacer()
                        .frame(height:40)
                    
                    Text("映画記録")
                        .font(.largeTitle)
                        .frame(width: 400,height: 100)
                        .background(Color.green)
                    
                    
                    Spacer()
                        .frame(height:20)
                    
                    HStack{
                        TextField("search for movie",text:$searchword)
                        //.onSubmit(){moviedatalist.searchMovies(keyword: searchword)}
                            .submitLabel(.search)
                            .textFieldStyle(RoundedBorderTextFieldStyle())//枠がつけれる
                            .frame(width:300)
                        Button("検索"){
                            moviedatalist.searchMovies(keyword: searchword)
                        }
                    }
                    .onAppear(){
                        
                        let currentDate = Date()
                        let calendar = Calendar.current//ユーザの地域情報を加味した計算ツール
                        
                        let month = calendar.component(.month, from: currentDate)//月を取り出してくれるツール
                        
                        nowmonth = month
                    }
                    
                    if moviedatalist.Movieitems.isEmpty{//検索していない段階
                        HStack{
                            //Text("うんち")
                            VStack{
                                Text("\(nowmonth)月の読書量")
                                
                                List{
                                    if let counting = eigacount.first{
                                        Text("\(counting.number)本")
                                        let number = Double(counting.number)/30.0
                                        let stn    = String(format:"%.2f",number)
                                        //確かjavaとかだとstring.formatとかだったけどswiftuiではformat:
                                        Text(stn+"本/日")
                                    }
                                }
                                .frame(width:250,height:250)
                                .scrollContentBackground(.hidden)
                                
                                Button("視聴した映画"){
                                    islistActive = true
                                }
                                
                            }
                            
                        }
                        
                    }
                    else{
                        ZStack{
                            Color(red:0.9,green: 1.0,blue:0.7,opacity: 0.5)
                            
                        List(moviedatalist.Movieitems){ movie in
                            
                            NavigationLink(destination:eigaRegister(selecteiga:movie)){//選択した本のデータを引き渡す
                                
                                HStack{
                                    Spacer()
                                        .frame(width: 20)
                                    
                                    Text(movie.title)
                                        .frame(width:270,height: 100)
                                    AsyncImage(url: movie.posterLink){ image in
                                        image//httpsじゃないと許してもらえない
                                            .resizable()
                                            .frame(width:80,height:90)
                                        
                                        //画面をスクロールして画面外にimageが出た時にまた戻して画像を表示させるのに再読み込みする必要があるのがうざい
                                    }placeholder: {
                                        ProgressView()//非同期で動かしている間画面のインジゲータ
                                    }
                                }
                                }
                            }
                        .scrollContentBackground(.hidden)
                        }
                    }
                    
                    
                    
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
        }
    }
}
extension View {
    func hideKeyboard3() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }//UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}//FirstResponderは現在フォーカスが当てられている部品のこと　それを否定　resignすることでそらす　sendActionはUIkitの持っているメソッド 指定アクションをfromさんからtoさんに送信
