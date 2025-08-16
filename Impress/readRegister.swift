//
//  readRegister.swift
//  Impress
//
//  Created by user on 2025/03/29.
//

import SwiftUI
import RealmSwift
import Foundation

struct readRegister: View {
    
    @Environment(\.presentationMode) var presentationMode
    var selectbook: BookItem
    @State var Editimpress: String = ""
    @State var date = Date()
    @State var isAccess = false
    @State var selectgenre = ""
    @State var selectassess:String = "-1"
    
    @State var nowmonth:Int = 0
    
    @State var ispressed = false
    
    var aslist:[String] = ["0","0.5","1","1.5","2","2.5","3","3.5","4","4.5","5"]
    
    var body: some View {
    
            NavigationStack{
                NavigationLink(destination:ReadImpress(),isActive: $isAccess){//登録ボタンをトリガーにする
                    
                }
                
                let currentDate = Date()
                let calendar = Calendar.current//ユーザの地域情報を加味した計算ツール
                
                let month = calendar.component(.month, from: currentDate)//月を取り出してくれるツール
            
            
        
                ZStack {// 背景に命を吹き込んだ
                    Color(red:0.8,green: 0.9,blue:0.7,opacity: 0.4)
                        .ignoresSafeArea()
                        .onTapGesture {//それがここ　タップした時の反応　これって部品全部に持ってるのかな
                            dismissKeyboard()
                        }
                    
                    VStack {
                        
                        //元々Spacer()を置いて下げようと思ってたけど何がダメだったのか
                        /*Text("本登録")//ブラックボックスすぎるんだけどもしかしたら.ignoresafeareaがデフォルトで適応されているのかもしれない
                         .font(.largeTitle)
                         .frame(width: 400, height: 60)*/
                        
                        Text("読んだ本の登録")
                            .font(.title).bold()//文字のフォントを太くする
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(20)
                            .shadow(radius: 4)
                        //.background(Color.green)//backgroundを使うのはやめよ
                        //.padding(.top, 70) // 上に30ptの余白を追加
                        
                        
                            .navigationBarBackButtonHidden(true)//デフォルトのbackボタンを隠す
                            .toolbar{
                                
                                ToolbarItem(placement: .topBarLeading){
                                    
                                    Button("< 戻る"){
                                        presentationMode.wrappedValue.dismiss()//ここでトリガーをオンにして戻っても良いけど引数関連があると面倒臭い から一つ戻るだけにする
                                    }
                                }
                            }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Button("登録") {//ontapgesuterはボタンは持っている でこれは押した瞬間もうアクションは終了するから　おした状態　話した状態のアクションを実装するにあ
                            //別の手段が必要
                            if selectgenre != "" , selectassess != ""{//選択していないとデータベースに登録させない
                                let smallThumbnail1 = selectbook.smallThumbnail
                                let imageUrlString = smallThumbnail1.absoluteString//Stringに変換
                                //print(imageUrlString)
                                addBook(Image:imageUrlString, title :selectbook.title, finDate:date,pageCount:selectbook.pageCount, Impression:Editimpress,overview:selectbook.overview,genre: selectgenre,evaluate: selectassess)
                                //データベースに本の情報を追加する
                                
                                
                                //登録ボタンを押した時にその読んだ日付月をもとにその月のデータベースにカウンティングする　現在の日付ではないってこと
                                
                                let calendar = Calendar.current//ユーザの地域情報を加味した計算ツール
                                
                                let month = calendar.component(.month, from: date)//月を取り出してくれるツール
                                
                                
                                updateBook(pageCount: selectbook.pageCount,month: month){result in
                                    print(result)
                                    print("うんち")
                                    isAccess = true
                                }
                                
                   
                            }
                        }
                        /*.font(.largeTitle)  //文字を書いてから
                         .foregroundStyle(.white)
                         
                         .frame(width: 130, height: 50)  //枠を決める
                         
                         .padding(10)  //スペースを広げる
                         .background(
                         Color(red: 0.0, green: 0.0, blue: 255, opacity: 0.4)
                         )
                         
                         .cornerRadius(50)  //なんかここにおいたらうまく機能した*/
                        
                        .font(.title)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .frame(width: 115,height:55)
                        .background(Color.accentColor.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(35)
                        .shadow(radius: 6)
                        .scaleEffect(ispressed ? 0.9:1.0)
                        
                        
                        
                        .simultaneousGesture(//これを管理するにはこいつが必要だしボタンとも競合しない
                            DragGesture(minimumDistance:0)//ドラッグを認識する範囲　もし0ならその部分だけかな？？？？{
                            
                                .onChanged{
                                    _ in ispressed = true //ドラッグしている間　押している間
                                }
                                .onEnded{
                                    _ in ispressed = false //ドラッグし終わったら　っていう複数の動作
                                }
                            
                        )
                        
                        
                        ScrollView{
                            
                            Spacer()
                                .frame(height: 30)
                            
                            HStack {
                                Spacer()
                                    .frame(width:20)
                                
                                AsyncImage(url: selectbook.smallThumbnail) { image in
                                    image  //httpsじゃないと許してもらえない
                                        .resizable()
                                        .frame(width: 150, height: 170)
                                    
                                    //画面をスクロールして画面外にimageが出た時にまた戻して画像を表示させるのに再読み込みする必要があるのがうざい
                                } placeholder: {
                                    ProgressView()  //非同期で動かしている間画面のインジゲータ
                                }
                                
                                VStack(alignment:.leading){
                                    HStack{
                                        Spacer()
                                            .frame(width:50)
                                        Text("タイトル")
                                            .foregroundStyle(.gray)
                                    }
                                    Text(selectbook.title)
                                    
                                        .frame(width: 230, height: 120)
                                        .font(.title2)
                                        .foregroundStyle(.black)
                                    
                                }
                            }
                            .onAppear(){
                                print(selectbook.smallThumbnail)
                                let now = Date()
                                nowmonth = Calendar.current.component(.month, from: now)
                                
                            }
                            
                            
                            Spacer()
                                .frame(height: 30)
                            
                            
                            //VStack(alignment: .leading, spacing: 20){
                            
                            Section(header: Text("基本情報").font(.headline)) {//Listと組み合わせると強いらしい　でも今は別にあってもなくても あとコンピュータに伝わる
                                Spacer()
                                    .frame(height:20)
                                
                                VStack{
                                   
                                    VStack(alignment: .leading, spacing: 10) {
                                        Spacer()
                                            .frame(height:6)
                                        
                                        HStack {
                                            
                                            DatePicker(
                                                "読み終わった日",
                                                selection: $date,
                                                displayedComponents: [.date]
                                            )
                                            Spacer()
                                                .frame(width:40)
                                        }
                                        Spacer()
                                            .frame(height:5)
                                        //.frame(width:340)
                                        
                                        
                                        //HStack{
                                        // Spacer()
                                        // .frame(width:60)
                                        Divider()
                                        HStack(spacing:0){
                                            Text("ジャンル")
                                                .frame(width:70)
                                            // Spacer()
                                            // .frame(width:160)
                                            Spacer()
                                                .frame(width:130)
                                            ZStack{
                                                if selectgenre == ""{
                                                    Text("ジャンル")
                                                        .foregroundStyle(Color(red:0.3,green:0.5,blue:0.8,opacity:0.8))
                                                        .frame(width:80)
                                                        .padding(.trailing,80)
                                                }
                                                
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
                                                .frame(minWidth: 110)
                                                //.fixedSize(horizontal: false, vertical: true)
                                                Spacer()
                                                    .frame(width:20)
                                            }
                                        }
                                        
                                        //Spacer()
                                        //.frame(height:15)
                                        //HStack{
                                        //Spacer()
                                        //   .frame(width:80)
                                        Divider()
                                        HStack(spacing:0){
                                            Text("評価")
                                                .frame(width:40)
                                            Spacer()
                                                .frame(width:200)
                                            
                                            if selectassess == "-1"{
                                                Text("評価")
                                                    .foregroundStyle(Color(red:0.3,green:0.5,blue:0.8,opacity:0.8))
                                            }
                                          
                                                Picker(selection:$selectassess){
                                                    ForEach(aslist,id: \.self){ item in
                                                        Text(item).tag(item)
                                                    }
                                                }label:{//pickerでラベルをつけないと怒られる
                                                    Text("評価")
                                                }
                                                
                                                .pickerStyle(.menu)
                                            
                                            Spacer()
                                                .frame(width:20)
                                            
                                        }
                                        Spacer()
                                            .frame(height:15)
                                    }
                                    .padding(.leading,40)
                                }
                                .frame(width:380)
                                .background(.white)
                                
                            }
                            
                            
                            Spacer()
                                .frame(height:30)
                            
                            Section(header: Text("感想").font(.headline)) {
                                Spacer()
                                    .frame(height: 5)
                                ZStack(alignment: .top) {
                                    if Editimpress.isEmpty {  // 入力されていない状態
                                        Text("本の感想")  // プレースホルダー
                                            .foregroundColor(.gray)
                                        //.padding(.horizontal, 8)
                                            .padding(.vertical, 30)
                                        
                                        //.border(Color.gray, width: 1)
                                            .zIndex(1)  // ← プレースホルダーを前面にする！ こいつのお陰様様
                                    }  //読み終わった日とカレンダーの間隔が広いから小さくしたい
                                    TextEditor(text: $Editimpress)
                                        .padding(20)//部品内部の感覚　すなわち文字Text箱と実際の文字の感覚
                                        .padding(.horizontal, 8)
                                        .frame(width: 440, height: 320)
                                        .background(Color.clear)  // 背景を透明にする
                                    //.border(Color.gray, width: 1)
                                        .cornerRadius(80)
                                        .zIndex(0)  // `TextEditor` を後ろに配置
                                }
                                .frame(width:380)
                            }
                            //今までこんなのなくてもスクロールできたくね？
                            /*ZStack(alignment: .top) {
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
                             .cornerRadius(80)
                             .zIndex(0)  // `TextEditor` を後ろに配置
                             }*/
                        }
                    }
                }
            
        }
    }
    func addBook(Image :String, title : String, finDate:Date ,pageCount:Int,Impression:String,overview:String,genre:String,evaluate:String) {
        do {
            let realm = try Realm()//これっていちおう見てるもの違うんだね
            let book = BookData()
            book.Image = Image
            book.title = title
            book.pageCount = pageCount
            book.finDate = finDate
            book.Impression = Impression
            book.overview = overview
            book.genre = genre
            book.evaluate = Float(evaluate)!
            book.month = nowmonth // 本に追加した月の情報を持たせることで後でdeleteするタイミングでこれを使うと便利
            try realm.write {//データベースに入れる
                realm.add(book)
            }
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    func updateBook(pageCount:Int,month : Int,completion:@escaping (String) -> Void) {//何でもかんでも同じ枠に全部追加するようになっている
        
        
        do {
            let realm = try Realm()//これっていちおう見てるもの違うんだね

            try realm.write {//指定された月のデータベースに本を入れてやる
                if let bookCount = realm.objects(BookDataCount.self).filter("month == %@", month).first{//存在する場合とそうでない場合
                    
                    bookCount.number += 1
                    bookCount.pagesumCount += pageCount
                    //bookCount.month = month
                    
                    realm.add(bookCount)
                    print(bookCount)
                }
                
                else{
                    let newbookCount = BookDataCount()
                    newbookCount.pagesumCount += pageCount
                    newbookCount.number += 1
                    newbookCount.month = month
                    
                    realm.add(newbookCount)
                }
                
            }
       
            
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
        
        completion("")
    }
    

}
extension View {

        //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        func dismissKeyboard() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { $0.endEditing(true) }
            }
        
    }//UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}//FirstResponderは現在フォーカスが当てられている部品のこと　それを否定　resignすることでそらす　sendActionはUIkitの持っているメソッド 指定アクションをfromさんからtoさんに送信
