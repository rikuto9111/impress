//
//  Toukou.swift
//  Impress
//
//  Created by user on 2025/04/26.
//

import FirebaseFirestore
import SwiftUI
import FirebaseAuth

struct Toukouitem: Identifiable{
    var id = UUID()
    var title:String
    var overview:String
    var name: String
    var imageiconurl: String
    var image: String
    var rating: Float
    var goodness:Int
    var othUserId:String//これあったらそれぞれのアイテムに良いねをつけた時にそのアイテムの持ち主のIDをすぐ特定できる
    var documentId:String//都合良くするためだけに無理やり追加したけど良かったのかな
    var createAt: Timestamp
    var isComment:[[String:String]]
    var registerday: Timestamp
    var genre:String
}

struct AnimeToukouitem: Identifiable{
    var id = UUID()
    var episodes:Int
    var title:String
    var overview:String
    var name: String
    var imageiconurl: String
    var image: String
    var rating: Float
    var goodness:Int
    var othUserId:String//これあったらそれぞれのアイテムに良いねをつけた時にそのアイテムの持ち主のIDをすぐ特定できる
    var documentId:String//都合良くするためだけに無理やり追加したけど良かったのかな
    var createAt: Timestamp
    var isComment:[[String:String]]
    var registerday: Timestamp
    var genre:String

}

struct MixToukouitem: Identifiable{
    var id = UUID()
    var booktitle:String
    var animetitle:String
    
    var overview:String
    var name: String
    var imageiconurl: String
    
    var bookimage: String
    var animeimage: String
    
    var bookrating: Float
    var animerating:Float
    
    var goodness:Int
    var mixthema:String
    var othUserId:String//これあったらそれぞれのアイテムに良いねをつけた時にそのアイテムの持ち主のIDをすぐ特定できる
    var documentId:String//都合良くするためだけに無理やり追加したけど良かったのかな
    var createAt: Timestamp
    var isComment:[[String:String]]
    var registerday: Timestamp
    var animegenre:String
    var bookgenre:String

}


struct BookListView: View {
    @Binding var toukoulist: [Toukouitem]  // あなたのモデルに合わせて調整
    @Binding var formatter :DateFormatter
    @Binding var onTap:Bool
    
    var body: some View {
        List {
            ForEach(toukoulist) { book in
                NavigationLink(destination: Comment(book: book)) {
                    // 元のVStackそのまま書く
                    // 省略
                    
                    VStack{
                        Spacer()
                            .frame(width:10)
                        
                        HStack{
                            AsyncImage(url: URL(string:book.imageiconurl)){ image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:50,height: 50)
                                    .cornerRadius(40)
                                
                            }placeholder: {
                                ProgressView()
                            }
                            
                            Spacer()
                                .frame(width:15)
                            
                            Text("\(book.name)")
                                .bold()
                            
                            Text(formatter.string(from: book.createAt.dateValue()))
                                .font(.system(size:16))
                            
                            Spacer()
                        }//HStack
                        
                        //Divider()
                        
                        Spacer()
                            .frame(height:25)
                        
                        HStack{
                            Spacer()
                                .frame(width:2)
                            VStack{
                                AsyncImage(url: URL(string:book.image)){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:90,height: 100)
                                    
                                    
                                }placeholder: {
                                    ProgressView()
                                }
                                StarRatingView(rating:book.rating)//他のswiftファイルの構造体も参照可
                            }//VStack
                            VStack{
                                
                                    Text(book.title)
                                Spacer()
                                    .frame(height:20)
                                HStack{
                                    Text("ジャンル")
                                        .foregroundColor(.gray)
                                    Text(book.genre)
                                }
                            }
                            Spacer()
                        }//HStack
                        
                        
                        Spacer()
                            .frame(width:10)
                        
                        Text(book.overview)
                            .frame(height:100)
                        
                        HStack{
                            
                            Spacer()
                            
                            Button(action:{
                                onTap.toggle()
                                updateGoodness(isGood:onTap,othUserId: book.othUserId,documentId: book.documentId,goodness:book.goodness)
                            },label:{
                                Image(systemName: onTap ? "heart.fill" : "heart")
                                    .foregroundColor(.pink)
                            })
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                                .frame(width:30)
                            
                            Text("\(book.goodness)")
                            //Text("\(isgoodnessalternate)")
                        }//HStack
                        
                        
                        Spacer()
                    }//VStack
                }//NavigationLink
                
            }//Foreach
        }
    }
    

    func updateGoodness(isGood:Bool,othUserId:String,documentId:String,goodness:Int){
       var db = Firestore.firestore()
       
       let newGoodness = isGood ? goodness + 1 : goodness - 1
       db.collection("user")
           .document(othUserId)
           .collection("posts")
           .document(documentId)
           .updateData(["goodness": newGoodness]) { error in
               if let error = error {
                   print("Firestore 更新エラー: \(error)")
                   return
               }//これはめちゃくちゃ上手いやり方を提案してもらった
           }
       
       /* 条件に応じて変化するのはgoodnessの値のみ
        if isGood{
        db.collection("user")
        .document(othUserId)
        .collection("posts")
        .document(documentId)
        .updateData(["goodness":goodness+1]){error in
        if let error = error{
        print("error")
        }
        }
        }
        else{
        db.collection("user")
        .document(othUserId)
        .collection("posts")
        .document(documentId)
        .updateData(["goodness":goodness-1]){error in
        if let error = error{
        print("error")
        }
        //realmとは異なるよ　realmdb参照変数は即座に変化を見るけどただのStateだし値も変更されていない
        }//もちろんreloadしてからは更新後のfirestore がtoukoulistに入ることになるを見ることになるけどさ
        //結びついているわけではなく手動で追加してる
        }*/
       if let index = toukoulist.firstIndex(where: {$0.documentId == documentId}){
           toukoulist[index].goodness = newGoodness
       }//即座に画面に反映させたいならtoukoulist属性に追加しないと
       
       //guard let
   }
}
    

struct AnimeListView: View {
    @Binding var animetoukoulist: [AnimeToukouitem]  // あなたのモデルに合わせて調整
    @Binding var formatter :DateFormatter
    @Binding var onTap:Bool
    
    var body: some View {
        List{
            ForEach(animetoukoulist){ anime in//State型のリストはすぐさま変化を検知してくれるわけではない
                NavigationLink(destination:Comment2(anime:anime)){
                    VStack{
                        Spacer()
                            .frame(width:10)
                        
                        HStack{
                            AsyncImage(url: URL(string:anime.imageiconurl)){ image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:50,height: 50)
                                    .cornerRadius(40)
                                
                            }placeholder: {
                                ProgressView()
                            }
                            
                            Spacer()
                                .frame(width:15)
                            
                            Text("\(anime.name)")
                                .bold()
                            
                            Text(formatter.string(from: anime.createAt.dateValue()))
                                .font(.system(size:16))
                            
                            Spacer()
                        }//HStack
                        
                        //Divider()
                        
                        Spacer()
                            .frame(height:25)
                        
                        HStack{
                            Spacer()
                                .frame(width:2)
                            VStack{
                                AsyncImage(url: URL(string:anime.image)){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:90,height: 100)
                                    
                                    
                                }placeholder: {
                                    ProgressView()
                                }
                                StarRatingView(rating:anime.rating)//他のswiftファイルの構造体も参照可
                            }//VStack
                            
                            VStack{
                                Text(anime.title)
                                Spacer()
                                    .frame(height:20)
                                HStack{
                                    Text("ジャンル")
                                        .foregroundColor(.gray)
                                    Text(anime.genre)
                                }
                            }
                            Spacer()
                        }//HStack
                        

                            Spacer()
                                .frame(width:10)
       
                            Text(anime.overview)
              
                        .frame(height:100)
                        HStack{
                            
                            Spacer()
                            
                            Button(action:{
                                onTap.toggle()
                                animeupdateGoodness(isGood:onTap,othUserId: anime.othUserId,documentId: anime.documentId,goodness:anime.goodness)
                            },label:{
                                Image(systemName: onTap ? "heart.fill" : "heart")
                                    .foregroundColor(.pink)
                            })
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                                .frame(width:30)
                            
                            Text("\(anime.goodness)")
                            //Text("\(isgoodnessalternate)")
                        }//HStack
                        
                        
                        Spacer()
                    }//VStack
                }//NavigationLink
                
            }//Foreach
            
        }//List
    }
    
    private func animeupdateGoodness(isGood:Bool,othUserId:String,documentId:String,goodness:Int){
        var db = Firestore.firestore()
        
        let newGoodness = isGood ? goodness + 1 : goodness - 1
        db.collection("user")
            .document(othUserId)
            .collection("Animeposts")
            .document(documentId)
            .updateData(["goodness": newGoodness]) { error in
                if let error = error {
                    print("Firestore 更新エラー: \(error)")
                    return
                }//これはめちゃくちゃ上手いやり方を提案してもらった
            }
        
        /* 条件に応じて変化するのはgoodnessの値のみ
         if isGood{
         db.collection("user")
         .document(othUserId)
         .collection("posts")
         .document(documentId)
         .updateData(["goodness":goodness+1]){error in
         if let error = error{
         print("error")
         }
         }
         }
         else{
         db.collection("user")
         .document(othUserId)
         .collection("posts")
         .document(documentId)
         .updateData(["goodness":goodness-1]){error in
         if let error = error{
         print("error")
         }
         //realmとは異なるよ　realmdb参照変数は即座に変化を見るけどただのStateだし値も変更されていない
         }//もちろんreloadしてからは更新後のfirestore がtoukoulistに入ることになるを見ることになるけどさ
         //結びついているわけではなく手動で追加してる
         }*/
        if let index = animetoukoulist.firstIndex(where: {$0.documentId == documentId}){
            animetoukoulist[index].goodness = newGoodness
        }//即座に画面に反映させたいならtoukoulist属性に追加しないと
        
        //guard let
    }
    
}
struct MixListView: View {
    @Binding var mixtoukoulist: [MixToukouitem]  // あなたのモデルに合わせて調整
    @Binding var formatter : DateFormatter
    @Binding var onTap:Bool
    
    var body: some View {
        
        List{
            ForEach(mixtoukoulist){ mixitem in//State型のリストはすぐさま変化を検知してくれるわけではない
                NavigationLink(destination: MixComment(mixitem: mixitem)){

                    VStack{
                        Spacer()
                            .frame(width:10)
                        
                        HStack{
                            AsyncImage(url: URL(string:mixitem.imageiconurl)){ image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:50,height: 50)
                                    .cornerRadius(40)
                                
                            }placeholder: {
                                ProgressView()
                            }
                        
                    
                 
                 Spacer()
                 .frame(width:15)
                 
                 Text("\(mixitem.name)")
                 .bold()
                 
                 Text(formatter.string(from: mixitem.createAt.dateValue()))
                 .font(.system(size:16))
                 
                 Spacer()
                 }//HStack
                 
                 //Divider()
 
                        
                        Divider()
                        
                        Spacer()
                        .frame(height:25)
                        
                        HStack{
                            Spacer()
                                .frame(width:4)
                            VStack{
                                AsyncImage(url: URL(string:mixitem.bookimage)){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:80,height: 80)
                                    
                                    
                                }placeholder: {
                                    ProgressView()
                                }
                                
                                StarRatingView(rating:mixitem.bookrating)//他のswiftファイルの構造体も参照可
                            }//VStack
                            
                            VStack{
                                Text(mixitem.booktitle)
                                Spacer()
                                    .frame(height:20)
                                
                                HStack{
                                    Text("ジャンル")
                                        .foregroundColor(.gray)
                                    Text(mixitem.bookgenre)
                                }
                                
                            }
                            Spacer()
                        }
                        
                        HStack{
                            Spacer()
                                .frame(width:4)
                            
                            VStack{
                                AsyncImage(url: URL(string:mixitem.animeimage)){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:80,height: 80)
                                    
                                    
                                }placeholder: {
                                    ProgressView()
                                }
                                
                                StarRatingView(rating:mixitem.animerating)//他のswiftファイルの構造体も参照可
                            }
                            VStack{
                                Text(mixitem.animetitle)
                                Spacer()
                                    .frame(height:20)
                                HStack{
                                    Text("ジャンル")
                                        .foregroundColor(.gray)
                                    Text(mixitem.animegenre)
                                }
                              
                            }
                            Spacer()
                        }
                 Divider()
                     
                        Spacer()
                            .frame(height:20)
                        
                        HStack{
                            Spacer()
                                .frame(width:10)
                            Text("テーマ")
                                .foregroundColor(.gray)
                            Spacer()
                                .frame(width:60)
                            Text(mixitem.mixthema)
                        
                            
                            Spacer()
                        }
    Spacer()
                            .frame(height:20)
                        HStack{
                            Spacer()
                                .frame(width:10)
                            Text("感想")
                                .foregroundColor(.gray)
                            Spacer()
                                .frame(width:40)
                            
                            Text(mixitem.overview)
                                .lineLimit(nil) // 行数制限なし
                                .fixedSize(horizontal: false, vertical: true) // 縦
                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height:20)
                 HStack{
                 
                 Spacer()
                 
                 Button(action:{
                 onTap.toggle()
                 MixupdateGoodness(isGood:onTap,othUserId: mixitem.othUserId,documentId: mixitem.documentId,goodness:mixitem.goodness)
                 },label:{
                 Image(systemName: onTap ? "heart.fill" : "heart")
                 .foregroundColor(.pink)
                 })
                 .buttonStyle(PlainButtonStyle())
                 
                 Spacer()
                 .frame(width:30)
                 
                 Text("\(mixitem.goodness)")
                 //Text("\(isgoodnessalternate)")
                 }//HStack
                 
                 
                 Spacer()
                 }//VStack
                 }//NavigationLink
                 
                 }//Foreach
                 
                
            }//Li
    }
    private func MixupdateGoodness(isGood:Bool,othUserId:String,documentId:String,goodness:Int){
        var db = Firestore.firestore()
        
        let newGoodness = isGood ? goodness + 1 : goodness - 1
        db.collection("user")
            .document(othUserId)
            .collection("Mixposts")
            .document(documentId)
            .updateData(["goodness": newGoodness]) { error in
                if let error = error {
                    print("Firestore 更新エラー: \(error)")
                    return
                }//これはめちゃくちゃ上手いやり方を提案してもらった
            }
        
        /* 条件に応じて変化するのはgoodnessの値のみ
         if isGood{
         db.collection("user")
         .document(othUserId)
         .collection("posts")
         .document(documentId)
         .updateData(["goodness":goodness+1]){error in
         if let error = error{
         print("error")
         }
         }
         }
         else{
         db.collection("user")
         .document(othUserId)
         .collection("posts")
         .document(documentId)
         .updateData(["goodness":goodness-1]){error in
         if let error = error{
         print("error")
         }
         //realmとは異なるよ　realmdb参照変数は即座に変化を見るけどただのStateだし値も変更されていない
         }//もちろんreloadしてからは更新後のfirestore がtoukoulistに入ることになるを見ることになるけどさ
         //結びついているわけではなく手動で追加してる
         }*/
        if let index = mixtoukoulist.firstIndex(where: {$0.documentId == documentId}){
            mixtoukoulist[index].goodness = newGoodness
        }//即座に画面に反映させたいならtoukoulist属性に追加しないと
        
        //guard let
    }


}

struct Toukou: View{
    
    @State private var hasAppeared = false
    @Environment(\.presentationMode) var presentationMode
    
    @State var toukoulist:[Toukouitem] = []
    
    @State var animetoukoulist:[AnimeToukouitem] = []
    
    @State var mixtoukoulist:[MixToukouitem] = []
    
    @State var onTap = false
    
    @State var othUserId:[String] = []
    
    @State var isgoodnessalternate = 0
    
    @State var selectcondition = ""
    
    @State var formatter:DateFormatter = DateFormatter()
    
    var body:some View{
        NavigationStack{
            VStack{
                
                
                HStack(spacing:0){
                    
                    Spacer()
                        .frame(width:100)
                    
                    Text("フォロワーの投稿")
                        .bold()
                        .font(.title2)
                    
                    Spacer()
                        .frame(width:40)
                    
                    if selectcondition == "" {
                        Text("種類")
                            .foregroundColor(.blue)
                    }
                    
                    Picker(selection: $selectcondition) {  //何で$使うんだっけ？？？？？？
                        Text("All")
                            .tag("All")
                        Text("本")  //表面上見えてるもの
                            .tag("本")  //tagの値がselectconditionにはセットされている
                        Text("アニメ")
                            .tag("アニメ")
                    } label: {
                        Text("検索")
                    }
                    .pickerStyle(.menu)
                }
                
                if selectcondition == "本"{
                    BookListView(toukoulist: $toukoulist,formatter:$formatter,onTap:$onTap)
                    
                }
                else if selectcondition == "アニメ"{
                    AnimeListView(animetoukoulist: $animetoukoulist, formatter: $formatter, onTap: $onTap)
                }
                
                
                else if selectcondition == "All"{
                   MixListView(mixtoukoulist: $mixtoukoulist,formatter: $formatter,onTap: $onTap)
                    /*
                    List{
                        
                        ForEach(mixtoukoulist){ mixitem in//State型のリストはすぐさま変化を検知してくれるわけではない
                            Text(mixitem.mixthema)
                            NavigationLink(destination:MixComment(mixitem:mixitem)){
                             VStack{
                             Spacer()
                             .frame(width:10)
                             
                                 HStack{
                                     AsyncImage(url: URL(string:mixitem.imageiconurl)){ image in
                                         image
                                             .resizable()
                                             .scaledToFit()
                                             .frame(width:50,height: 50)
                                             .cornerRadius(40)
                                         
                                     }placeholder: {
                                         ProgressView()
                                     }
                                 
                             
                             Spacer()
                             .frame(width:15)
                             
                             Text("\(mixitem.name)")
                             .bold()
                             
                             Text(formatter.string(from: mixitem.createAt.dateValue()))
                             .font(.system(size:16))
                             
                             Spacer()
                             }//HStack
                             
                             //Divider()
                             
                                 Spacer()
                                 .frame(height:25)
                                 /*
                                     HStack{
                                         Spacer()
                                             .frame(width:2)
                                         VStack{
                                             AsyncImage(url: URL(string:mixitem.image)){ image in
                                                 image
                                                     .resizable()
                                                     .scaledToFit()
                                                     .frame(width:90,height: 100)
                                                 
                                                 
                                             }placeholder: {
                                                 ProgressView()
                                             }
                                         }
                                     }*/
                                
                                 StarRatingView(rating:mixitem.rating)//他のswiftファイルの構造体も参照可
                                 }//VStack
                                 Text(mixitem.title)
                                 
                                 Spacer()
                                 }//HStack
                                 
                                 
                                 Spacer()
                                 .frame(width:10)
                                 
                                 Text(mixitem.overview)
                                 .frame(height:100)
                                 
                                 HStack{
                                 
                                 Spacer()
                                 
                                 /*Button(action:{
                                 onTap.toggle()
                                 MixupdateGoodness(isGood:onTap,othUserId: mixitem.othUserId,documentId: mixitem.documentId,goodness:mixitem.goodness)
                                 },label:{
                                 Image(systemName: onTap ? "heart.fill" : "heart")
                                 .foregroundColor(.pink)
                                 })
                                 .buttonStyle(PlainButtonStyle())
                                 
                                 Spacer()
                                 .frame(width:30)
                                 
                                 Text("\(mixitem.goodness)")
                                 //Text("\(isgoodnessalternate)")
                                 //}//HStack
                                 
                                 
                                 Spacer()*/
                             //}//VStack
                             }//NavigationLink
                             
                             }//Foreach
                             
                            
                        }//List*/
                    }
                    
                    
                    
                    
                    
                }//VStack
                    .navigationBarBackButtonHidden(true)//デフォルトのbackボタンを隠す
                    .toolbar{
                        
                        ToolbarItem(placement: .topBarLeading){
                            
                            Button("< 戻る"){
                                presentationMode.wrappedValue.dismiss()//ここでトリガーをオンにして戻っても良いけど引数関連があると面倒臭い から一つ戻るだけにする
                            }
                        }
                    }
                    .background(EnableSwipeBackGesture()) // ←ここを追加
                
                Spacer()
                
            }//Navigation
            .onAppear(){
                guard !hasAppeared else { return }
                hasAppeared = true
                getUser()
                
                formatter.dateFormat = "yyyy年MM月dd日"
                formatter.locale = Locale(identifier: "ja_JP")
                
                print(animetoukoulist)
                print(mixtoukoulist)
            }
        }
        
        
        func findUidFromUserId(userId: String, completion: @escaping (String?) -> Void) {
            var db = Firestore.firestore()//接続
            
            db.collection("user")
                .whereField("userId",isEqualTo: userId)//ドキュメント丸ごとゲット
                .getDocuments{ snapshot,error in
                    if let error = error {
                        print("error")
                        completion(nil)
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else{
                        completion(nil)
                        return
                    }
                    
                    let uid = document.documentID//本物のid
                    
                    completion(uid)
                }
        }//userIdを直接入力させる形だと長いし面倒だし危ないし8桁の数字にした
        
         func updateGoodness(isGood:Bool,othUserId:String,documentId:String,goodness:Int){
            var db = Firestore.firestore()
            
            let newGoodness = isGood ? goodness + 1 : goodness - 1
            db.collection("user")
                .document(othUserId)
                .collection("posts")
                .document(documentId)
                .updateData(["goodness": newGoodness]) { error in
                    if let error = error {
                        print("Firestore 更新エラー: \(error)")
                        return
                    }//これはめちゃくちゃ上手いやり方を提案してもらった
                }
            
            /* 条件に応じて変化するのはgoodnessの値のみ
             if isGood{
             db.collection("user")
             .document(othUserId)
             .collection("posts")
             .document(documentId)
             .updateData(["goodness":goodness+1]){error in
             if let error = error{
             print("error")
             }
             }
             }
             else{
             db.collection("user")
             .document(othUserId)
             .collection("posts")
             .document(documentId)
             .updateData(["goodness":goodness-1]){error in
             if let error = error{
             print("error")
             }
             //realmとは異なるよ　realmdb参照変数は即座に変化を見るけどただのStateだし値も変更されていない
             }//もちろんreloadしてからは更新後のfirestore がtoukoulistに入ることになるを見ることになるけどさ
             //結びついているわけではなく手動で追加してる
             }*/
            if let index = toukoulist.firstIndex(where: {$0.documentId == documentId}){
                toukoulist[index].goodness = newGoodness
            }//即座に画面に反映させたいならtoukoulist属性に追加しないと
            
            //guard let
        }
        
        private func animeupdateGoodness(isGood:Bool,othUserId:String,documentId:String,goodness:Int){
            var db = Firestore.firestore()
            
            let newGoodness = isGood ? goodness + 1 : goodness - 1
            db.collection("user")
                .document(othUserId)
                .collection("Animeposts")
                .document(documentId)
                .updateData(["goodness": newGoodness]) { error in
                    if let error = error {
                        print("Firestore 更新エラー: \(error)")
                        return
                    }//これはめちゃくちゃ上手いやり方を提案してもらった
                }
            
            /* 条件に応じて変化するのはgoodnessの値のみ
             if isGood{
             db.collection("user")
             .document(othUserId)
             .collection("posts")
             .document(documentId)
             .updateData(["goodness":goodness+1]){error in
             if let error = error{
             print("error")
             }
             }
             }
             else{
             db.collection("user")
             .document(othUserId)
             .collection("posts")
             .document(documentId)
             .updateData(["goodness":goodness-1]){error in
             if let error = error{
             print("error")
             }
             //realmとは異なるよ　realmdb参照変数は即座に変化を見るけどただのStateだし値も変更されていない
             }//もちろんreloadしてからは更新後のfirestore がtoukoulistに入ることになるを見ることになるけどさ
             //結びついているわけではなく手動で追加してる
             }*/
            if let index = animetoukoulist.firstIndex(where: {$0.documentId == documentId}){
                animetoukoulist[index].goodness = newGoodness
            }//即座に画面に反映させたいならtoukoulist属性に追加しないと
            
            //guard let
        }
        
    
    private func MixupdateGoodness(isGood:Bool,othUserId:String,documentId:String,goodness:Int){
        var db = Firestore.firestore()
        
        let newGoodness = isGood ? goodness + 1 : goodness - 1
        db.collection("user")
            .document(othUserId)
            .collection("Mixposts")
            .document(documentId)
            .updateData(["goodness": newGoodness]) { error in
                if let error = error {
                    print("Firestore 更新エラー: \(error)")
                    return
                }//これはめちゃくちゃ上手いやり方を提案してもらった
            }
        
        /* 条件に応じて変化するのはgoodnessの値のみ
         if isGood{
         db.collection("user")
         .document(othUserId)
         .collection("posts")
         .document(documentId)
         .updateData(["goodness":goodness+1]){error in
         if let error = error{
         print("error")
         }
         }
         }
         else{
         db.collection("user")
         .document(othUserId)
         .collection("posts")
         .document(documentId)
         .updateData(["goodness":goodness-1]){error in
         if let error = error{
         print("error")
         }
         //realmとは異なるよ　realmdb参照変数は即座に変化を見るけどただのStateだし値も変更されていない
         }//もちろんreloadしてからは更新後のfirestore がtoukoulistに入ることになるを見ることになるけどさ
         //結びついているわけではなく手動で追加してる
         }*/
        if let index = mixtoukoulist.firstIndex(where: {$0.documentId == documentId}){
            mixtoukoulist[index].goodness = newGoodness
        }//即座に画面に反映させたいならtoukoulist属性に追加しないと
        
        //guard let
    }
    
    
        private func getUser(){//一回だけ呼び出される
            
            var db = Firestore.firestore()//接続
            //usersコレクションの中のdocumentエリアポインタ確保 idも含む
            
            guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
                print("ユーザーがログインしてない")
                return//いったんはカレントユーザid
            }
            let userid = userbase.uid  //uid取得
            
            print("a")
            db.collection("user")
            //.whereField("name", isEqualTo: "陸人")//名前で
                .document(userid)
                .getDocument{snapshot,error in//これだと複数ヒットするから
                    if let error = error{//snapshotは複数要素持ちでその中の一つ一つがdataを持つ
                        print("error")
                        return
                    }
                    print("b")
                    
                    guard let data = snapshot?.data(),let followers = data["followers"] as? [String] else{
                        print("ない")
                        return//ここまででfollowersにアクセス followersにあるはず
                    }
                    
                    for follower in followers {
                        print("b")
                        db.collection("user")
                            .whereField("userId", isEqualTo: follower)//id入力したものと照合
                            .getDocuments{snapshot,error in//8桁のパスワードから本物のidを取得
                                if let error = error{//snapshotは複数要素持ちでその中の一つ一つがdataを持つ
                                    print("error")
                                    return
                                }
                                guard let documents = snapshot?.documents,let otheruserDoc = documents.first else{
                                    return
                                }
                                print("v")
                                //ここまでで他人のポインタ取得
                                let othuserId = otheruserDoc.documentID//それが必要 カギみたいなもの
                                print(othuserId)
                                //othUserId.append(othuserId)//この中だけじゃなくてみんなが使うものになる
                                
                                db.collection("user")
                                    .document(othuserId)
                                    .collection("Profile")
                                    .getDocuments{ profilesnapshot,error in
                                        if let error = error{
                                            print("エラー")
                                            return
                                        }
                                        guard let prodocument = profilesnapshot?.documents.first else{
                                            return//もう該当するdocumentが一つ前提　一つのprofileドキュメントを更新しているからこれで良い
                                        }
                                        let prodata = prodocument.data()
                                        
                                        guard let name  = prodata["name"] as? String,
                                              let imageiconurl = prodata["imageiconurl"] as? String
                                        else{
                                            return
                                        }
                                        
                                        
                                        
                                        print(name)
                                        
                                        
                                        db.collection("user")//本物のuserIdからPostを取得
                                            .document(othuserId)
                                            .collection("posts")//post じゃなくてposts
                                            .getDocuments{ postSnapshot, error in
                                                if let error = error {
                                                    print("投稿の取得エラー: \(error)")
                                                    return
                                                }
                                                
                                                guard let postDocuments = postSnapshot?.documents else { return }//複数Documentの取得？
                                                
                                                for document in postDocuments{//多分ひとつ
                                                    let data = document.data()//一旦一つ前提
                                                    
                                                    if let title = data["title"] as? String,
                                                       let overview = data["overview"] as? String,//Any型をStringに強制変換
                                                       let image = data["image"] as? String,
                                                       let rating = data["rating"] as? Float,
                                                       let createAt = data["createdAt"] as? Timestamp,
                                                       let isComment = data["isComment"] as? [[String:String]],
                                                       let goodness = data["goodness"] as? Int,
                                                       let registerday = data["registerday"] as? Timestamp,
                                                       let genre = data["genre"] as? String{
                                                        let item = Toukouitem(title: title, overview: overview,name: name, imageiconurl: imageiconurl,image:image,rating:rating,goodness: goodness,othUserId: othuserId,documentId:document.documentID,createAt:createAt,isComment: isComment,registerday: registerday,genre:genre)
                                                        
                                                        DispatchQueue.main.async {
                                                            toukoulist.append(item)
                                                        }
                                                        print(item)
                                                        
                                                    }//Stringに変換できなかったらnilにしてもらう
                                                    else{
                                                        print("zsんね")
                                                    }
                                                }//forループ
                                                
                                                //getDocument終了 Postを取得する過程
                                                
                                                db.collection("user").document(othuserId)
                                                    .collection("Animeposts")
                                                    .getDocuments{ animesnapshots,error in
                                                        if let error = error{
                                                            print("error")
                                                        }
                                                        print("a")
                                                        guard let animedocuments = animesnapshots?.documents else {return}
                                                        print(animedocuments)
                                                        for document in animedocuments{
                                                            let data = document.data()
                                                            print("b")
                                                            if let title = data["title"] as? String,
                                                               let episodes = data["episodes"] as? Int,
                                                               let overview = data["overview"] as? String,//Any型をStringに強制変換
                                                               let image = data["image"] as? String,
                                                               let rating = data["rating"] as? Float,
                                                               let createAt = data["createdAt"] as? Timestamp,
                                                               let isComment = data["isComment"] as? [[String:String]],
                                                               let goodness = data["goodness"] as? Int,
                                                               let registerday = data["registerday"] as? Timestamp,
                                                               let genre = data["genre"] as? String{
                                                                
                                                                let item = AnimeToukouitem(episodes:episodes,title: title,overview: overview, name: name, imageiconurl: imageiconurl, image: image, rating: rating, goodness: goodness, othUserId: othuserId, documentId: document.documentID, createAt: createAt, isComment: isComment,registerday: registerday,genre:genre)
                                                                
                                                                DispatchQueue.main.async{
                                                                    animetoukoulist.append(item)
                                                                }
                                                                print(item)
                                                            }
                                                            
                                                        }
                                                    }//animeposts
                                                
                                                db.collection("user").document(othuserId)
                                                    .collection("Mixposts")
                                                    .getDocuments{ animesnapshots,error in
                                                        if let error = error{
                                                            print("error")
                                                        }
                                                        print("a")
                                                        guard let animedocuments = animesnapshots?.documents else {return}
                                                        print(animedocuments)
                                                        for document in animedocuments{
                                                            let data = document.data()
                                                            print("b")
                                                            if let booktitle = data["title"] as? String,
                                                               let animetitle = data["animetitle"] as? String,
                                                               let overview = data["mixoverview"] as? String,//Any型をStringに強制変換
                                                               let bookimage = data["image"] as? String,
                                                               let animeimage = data["animeimage"] as? String,
                                                               let bookrating = data["rating"] as? Float,
                                                               let animerating = data["animerating"] as? Float,
                                                               let createAt = data["createdAt"] as? Timestamp,
                                                               let isComment = data["isComment"] as? [[String:String]],
                                                               let goodness = data["goodness"] as? Int,
                                                               let mixthema = data["mixthema"] as? String,
                                                               let registerday = data["registerday"] as? Timestamp,
                                                               let bookgenre = data["bookgenre"] as? String,
                                                               let animegenre = data["animegenre"] as? String{
                                                                
                                                                let mixitem = MixToukouitem(booktitle: booktitle, animetitle: animetitle, overview: overview, name: name, imageiconurl: imageiconurl, bookimage: bookimage, animeimage: animeimage, bookrating:bookrating, animerating: animerating, goodness: goodness,mixthema: mixthema, othUserId: othuserId, documentId: document.documentID, createAt: createAt, isComment: isComment, registerday: registerday,animegenre:animegenre,bookgenre:bookgenre)
                                                                DispatchQueue.main.async{
                                                                    mixtoukoulist.append(mixitem)
                                                                }
                                                                print(mixitem)
                                                            }
                                                            
                                                        }
                                                    }//mixitem
                                                
                                            }
                                    }
                                
                            }//それを繰り返す　followers分だけ
                        
                        print(animetoukoulist)
                        
                    }
                    
                    
                }
            
            
        }
        
        
    }

