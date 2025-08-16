//
//  eigaRegister.swift
//  Impress
//
//  Created by user on 2025/03/30.
//

import RealmSwift
import SwiftUI

struct eigaRegister: View {

    var selecteiga: Movieitem
    @State var Editimpress: String = ""
    @State var date = Date()
    @State var iseigaAccess = false

    @State var selectgenre = ""
    @State var selectassess:String = "-1"//FloatかDoubleかどっちやねんって怒られる
    var aslist = ["0","0.5","1","1.5","2","2.5","3","3.5","4","4.5","5"]
    
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: EigaImpress(), isActive: $iseigaAccess)
            {  //登録ボタンをトリガーにする

            }

            ZStack {  // 背景に命を吹き込んだ
                Image(.moviebackground)
                    .resizable()// 背景をタップ可能にする
                    .ignoresSafeArea()
                    .onTapGesture {  //それがここ　タップした時の反応　これって部品全部に持ってるのかな
                         dismissKeyboard2()
                    }

                VStack {
                    ZStack{
                        Color.green
                        //元々Spacer()を置いて下げようと思ってたけど何がダメだったのか
                        Text("映画登録")//ブラックボックスすぎるんだけどもしかしたら.ignoresafeareaがデフォルトで適応されているのかもしれない
                            .font(.largeTitle)
                            .frame(width: 400, height: 60)
                        //.background(Color.green)//backgroundを使うのはやめよ
                        //.padding(.top, 70) // 上に30ptの余白を追加
                    }
                    .frame(height:80)

                    Spacer()
                        .frame(height: 40)

                    Button("登録") {

                        let smallThumbnail1 = selecteiga.posterLink
                        let imageUrlString = smallThumbnail1.absoluteString  //Stringに変換
                        //print(imageUrlString)
                        addEiga(
                            Image: imageUrlString, title: selecteiga.title,
                            finDate: date, Impression: Editimpress,
                            overview: selecteiga.overview,genre:selectgenre,evaluate:selectassess)
                        //データベースに本の情報を追加する

                        updateMovie()
                        iseigaAccess = true
                    }

                    .font(.largeTitle)  //文字を書いてから
                    .foregroundStyle(.white)

                    .frame(width: 130, height: 50)  //枠を決める

                    .padding(10)  //スペースを広げる
                    .background(
                        Color(red: 0.0, green: 0.0, blue: 255, opacity: 0.4)
                    )

                    .cornerRadius(50)  //なんかここにおいたらうまく機能した
                    
                    ScrollView {
                    Spacer()
                        .frame(height: 20)

                    HStack {
                        Spacer()
                            .frame(width: 20)

                        AsyncImage(url: selecteiga.posterLink) { image in
                            image  //httpsじゃないと許してもらえない
                                .resizable()
                                .frame(width: 150, height: 170)

                            //画面をスクロールして画面外にimageが出た時にまた戻して画像を表示させるのに再読み込みする必要があるのがうざい
                        } placeholder: {
                            ProgressView()  //非同期で動かしている間画面のインジゲータ
                        }
                        VStack(alignment:.leading) {
                            Text("タイトル")
                                .foregroundStyle(.gray)
                            
                            Text(selecteiga.title)

                                .font(.title2)
                                .foregroundStyle(.black)
                                .frame(width: 200, height: 150)
                        }

                    }
                    .padding(15)
                    //.onAppear(){
                    //print(selectbook.smallThumbnail)
                    //}

                    Spacer()
                        .frame(height: 30)
                    HStack {
                        Spacer()
                            .frame(width: 20)
                        DatePicker(
                            "読み終わった日",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .frame(width: 340)

                    }
                    Spacer()
                        .frame(height: 30)
                        
                        
                        HStack{
                            Spacer()
                                .frame(width:60)
                            
                            Text("ジャンル")
                            
                            Spacer()
                                .frame(width:160)

                            Picker(selection: $selectgenre){//何で$使うんだっけ？？？？？？
                                Text("ミステリー")//表面上見えてるもの
                                    .tag("ミステリー")//tagの値がselectconditionにはセットされている
                                Text("SF")
                                    .tag("SF")
                                Text("ファンタジー")
                                    .tag("ファンタジー")
                                Text("社会小説")
                                    .tag("社会小説")
                                Text("教養")
                                    .tag("教養")
                                Text("ビジネス")
                                    .tag("ビジネス")
                                Text("理工系")
                                    .tag("理工系")
                                Text("児童書")
                                    .tag("児童書")
                                
                                Text("その他")
                                    .tag("その他")
                            }label: {
                                Text("ジャンル")
                            }
                            .pickerStyle(.menu)
 
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height:15)
                        
                        HStack{
                            Spacer()
                                .frame(width:80)
                            Text("評価")
                            
                            Spacer()
                                .frame(width:170)
                            
                            Picker(selection:$selectassess){
                                ForEach(aslist,id: \.self){ item in
                                    Text(item).tag(item)
                                }
                            }label:{//pickerでラベルをつけないと怒られる
                                Text("a")
                            }
                            .pickerStyle(.menu)
                            
                            Spacer()
                        }
                        
                        
                        
                    Text("感想")
                    Spacer()
                        .frame(height: 20)

                     //今までこんなのなくてもスクロールできたくね？
                        ZStack(alignment: .top) {
                            if Editimpress.isEmpty {  // 入力されていない状態
                                Text("本の感想")  // プレースホルダー
                                    .foregroundColor(.gray)
                                    //.padding(.horizontal, 8)
                                    .padding(.vertical, 12)

                                    //.border(Color.gray, width: 1)
                                    .zIndex(1)  // ← プレースホルダーを前面にする！ こいつのお陰様様
                            }  //読み終わった日とカレンダーの間隔が広いから小さくしたい
                            TextEditor(text: $Editimpress)
                                .padding(8)//部品内部の感覚　すなわち文字Text箱と実際の文字の感覚
                                .frame(width: 350, height: 320)
                                .background(Color.clear)  // 背景を透明にする
                                //.border(Color.gray, width: 1)
                                .cornerRadius(50)
                                .zIndex(0)  // `TextEditor` を後ろに配置
                        }
                    }
                }
            }
        }

    }
}

func addEiga(
    Image: String, title: String, finDate: Date, Impression: String,
    overview: String,genre:String,evaluate:String
) {
    do {
        let realm = try Realm()  //これっていちおう見てるもの違うんだね
        let movie = MovieData()
        movie.Image = Image
        movie.title = title

        movie.finDate = finDate
        movie.Impression = Impression
        movie.overview = overview
        
        movie.genre = genre
        movie.evaluate = Float(evaluate)!
        
        try realm.write {  //データベースに入れる
            realm.add(movie)
        }

    } catch {
        print("Error adding task: \(error.localizedDescription)")
    }
}

func updateMovie() {

    do {
        let realm = try Realm()  //これっていちおう見てるもの違うんだね

        try realm.write {
            if let eigaCount = realm.objects(EigaCount.self).first {
                eigaCount.number += 1//こういうふうにrealmデータベースの値を直接いじるときはwriteの中に入れよう　中出し
            } else {
                let neweigaCount = EigaCount()
                neweigaCount.number = 1//これはワンチャンこの2行だけなら外だししてもいけるかもしれない
                realm.add(neweigaCount)
            }
        }

    } catch {
        print("Error adding task: \(error.localizedDescription)")
    }
}

extension View {
    func dismissKeyboard2() {//これに関しては何やってるのかわからん　$0とかってどういう書き方だっけ?
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.endEditing(true) }
        }
    }  //UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}  //FirstResponderは現在フォーカスが当てられている部品のこと　それを否定　resignすることでそらす　sendActionはUIkitの持っているメソッド 指定アクションをfromさんからtoさんに送信
