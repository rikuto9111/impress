//
//  Movielist.swift
//  Impress
//
//  Created by user on 2025/03/31.
//

import RealmSwift
import SwiftUI

struct Movielist: View {
    @ObservedResults(MovieData.self) var moviedatas
    @ObservedResults(EigaCount.self) var eigaCount

    var body: some View {
        
        ZStack{
            Image(.moviebackground)
                .resizable()
                .ignoresSafeArea()
            
            NavigationStack {
                
                List{
                    ForEach(moviedatas) { movie in//スワイプ削除を使うためにはそれぞれのアイテムidを指定しないといけなくてそのためにはforeachが必要
                        NavigationLink(
                            destination: Moviedetails(
                                title: movie.title,
                                image: movie.Image,
                                overview: movie.overview,
                                Impression: movie.Impression)
                        ) {
                            VStack {
                                Text(movie.title)
                                HStack {
                                    
                                    if let req_url = URL(string: movie.Image) {
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
                                    
                                    Text(movie.overview)
                                        .frame(width: 240, height: 150)
                                }
                                
                            }
                        }
                        
                    }
                    
                    .onDelete(perform: deleteMovie)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    private func deleteCount(){
        do{
            let realm = try Realm()
            try realm.write{
                if let eigaCount = realm.objects(EigaCount.self).first{//存在する場合とそうでない場合
                    eigaCount.number -= 1
                    
                    realm.add(eigaCount)
                }
            }
            
        }
                catch{
                    print("Error adding task: \(error.localizedDescription)")
                }
            }
 
    private func deleteMovie(at offsets: IndexSet) {  //スワイプした番号をリストから教えてもらった
        for index in offsets {
            let movie = moviedatas[index]  //その番号をもとにその番号にあった要素を取り出す
            $moviedatas.remove(movie)  // Realm のデータを削除
        }
        deleteCount()//Countデータベースの値も減らしておく
    }
}
