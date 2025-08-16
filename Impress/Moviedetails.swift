//
//  Moviedetails.swift
//  Impress
//
//  Created by user on 2025/03/31.
//

import SwiftUI


struct Moviedetails: View {
    
    @State var title:String
    @State var image:String
    @State var overview:String
    @State var Impression:String
    
    var body: some View {
        ZStack{
            
            Image(.moviebackground)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                List{
                    HStack{
                        Spacer()
                            .frame(width:5)
                        
                        Text("タイトル")
                            .foregroundColor(.gray)
                            .frame(width:90)
                        
                        Spacer()
                            .frame(width:70)
                        
                        Text(title)
                    }
                    HStack{
                        Spacer()
                            .frame(width:5)
                        
                        Text("タイトル")
                            .foregroundColor(.gray)
                            .frame(width:90)
                        
                        Spacer()
                            .frame(width:70)
                        
                        //Text("\(pagenumber)ページ")
                    }
                    /*.overlay(//いまいちわかっていないけどHStackVstackに枠線を囲いたいときに使う
                     RoundedRectangle(cornerRadius: 10)
                     .stroke(Color.green, lineWidth: 2)
                     )*/
                    
                    HStack{
                        
                        Spacer()
                            .frame(width:20)
                        
                        if let req_url = URL(string: image) {
                            AsyncImage(url: req_url) { image in
                                image
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            } placeholder: {
                                ProgressView()  //非同期で動かしている間画面のインジゲータ
                            }
                        }
                        
                        Spacer()
                            .frame(width:20)
                        
                        Text(overview)
                            .frame(width:230,height:240)
                    }
                    .padding(10)
                    /* .overlay(
                     RoundedRectangle(cornerRadius: 10)
                     .stroke(Color.green, lineWidth: 2)
                     )*/
                    HStack{
                        Spacer()
                            .frame(width:5)
                        
                        Text("感想")
                            .foregroundColor(.gray)
                            .frame(width:40)
                        
                        Spacer()
                            .frame(width:10)
                        
                        
                        Text(Impression)
                        //.border(Color.black)//言葉の通りでそのまま角張った線を引く
                            .padding(20)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    
}




