//
//  Otherprofile.swift
//  Impress
//
//  Created by user on 2025/05/31.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI//フォトライブラリ用
import FirebaseStorage
import RealmSwift
import FirebaseFirestore

    /*struct MyToukouitem:Identifiable{
        var id = UUID()
        var title:String
        var overview:String
        var name: String
        var Imageiconurl: String
        var image: String
        var rating: Float
        var goodness:Int
        var othUserId:String//これあったらそれぞれのアイテムに良いねをつけた時にそのアイテムの持ち主のIDをすぐ特定できる
        var documentId:String//都合良くするためだけに無理やり追加したけど良かったのかな
        var createAt: Timestamp
        var isComment:[[String:String]]
    }*/

struct Introduce:Identifiable{
    var id = UUID()
    var introduce:String
    var imagebackground:String
    var imageiconurl : String
    var name : String
    //var createAt:Timestamp
    var label: String
    var animelabel:String
    
}


struct Otherprofile: View {
    
    //@State var book:Toukouitem
    @State var othuserid:String
    @State var registerday:Timestamp
    
    @State var introlist:Introduce = Introduce(introduce: "", imagebackground: "",imageiconurl: "",name: "",label:"",animelabel: "")
    
    @State var toukoulists: [MyToukouitem] = []
    @State var animetoukoulists:[AnimeToukouitem] = []
    
    @State var mixtoukoulists: [MixToukouitem] = []
    
    @Environment(\.presentationMode) var presentationMode//アプリ画面全てを管理する監督 Environment 今画面のviewが表示されているかどうか
    //@State var photoPickerSelectedImage:PhotosPickerItem? = nil//選択したアイテムを格納する状態変数
    
    
    
    @State var isToukoubook = false
    @State var isToukouanime = false
    @State var isToukouall = false
    
    
    @State var formatter:DateFormatter = DateFormatter()
    
    var body: some View {
        // ZStack{
        VStack{
            
            
            AsyncImage(url:URL(string:introlist.imagebackground)){image in
                image
                    .resizable()
                    .ignoresSafeArea()
                    .frame(width:400,height:60)
                
            }placeholder: {
                ProgressView()
            }
            
            HStack{
                Spacer()
                    .frame(width:10)
                
                VStack{
                    Spacer()
                        .frame(height:20)
                    
                    Text("読書称号")
                        .frame(height:10)
                        .foregroundColor(.gray)
                    
                    Image(introlist.label)
                        .resizable()
                        .frame(width:120,height:30)
                        .cornerRadius(20)
                    
                    Spacer()
                        .frame(height:10)
                    
                    Text("アニメ称号")
                        .frame(width:90,height:15)
                        .foregroundColor(.gray)
                    
                    Image(introlist.animelabel)
                        .resizable()
                        .frame(width:120,height:30)
                        .cornerRadius(20)
                    
                }
            
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
                    .frame(width:30)
                
                
                AsyncImage(url:URL(string:introlist.imageiconurl)){image in
                    image
                        .resizable()
                        .ignoresSafeArea()
                        .frame(width:70,height:70)
                        .cornerRadius(35)
                    
                }placeholder: {
                    ProgressView()
                }
                
                Spacer()
                    .frame(width:140)
                
            }
        
                    
                    
                   
                    
                    
                

            Spacer()
                .frame(height:10)
            
            Text("名前:\(introlist.name)")
            Text("アプリ登録日:\(formatter.string(from: registerday.dateValue()))")
            
            HStack{
                
                Spacer()
                    .frame(width:80)
                
                Text("自己紹介:\(introlist.introduce)")
                    .fixedSize(horizontal: false, vertical: true)//縦方向は必要な分だけ広がる
                
                Spacer()
            }
            .frame(width:400)
            
            Spacer()
                .frame(height:30)
            
            
            
            HStack{
                
                Spacer()
                    .frame(width:40)
                
                Button("投稿した本"){
                    isToukoubook.toggle()
                    isToukouanime = false
                    isToukouall = false
                    
                }
                
                Spacer()
                    .frame(width:40)
                
                Button("投稿したアニメ"){
                    isToukouanime.toggle()
                    isToukoubook = false
                    isToukouall = false
                }
                Spacer()
                    .frame(width:40)
                
                Button("All"){
                    isToukouanime = false
                    isToukoubook = false
                    isToukouall.toggle()
                }
                
                Spacer()
                
                
            }
            
            if isToukoubook{
                
                List{//全く一緒
                    
                    ForEach(toukoulists){ mybook in
                        
                        NavigationLink(destination:MyComment(book:mybook)){
                            VStack{
                                Spacer()
                                    .frame(width:10)
                                
                                HStack{
                                    AsyncImage(url: URL(string:mybook.Imageiconurl)){ image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:50,height: 50)
                                            .cornerRadius(30)
                                        
                                    }placeholder: {
                                        ProgressView()
                                    }
                                    
                                    Spacer()
                                        .frame(width:15)
                                    
                                    Text("\(mybook.name)")
                                        .bold()
                                    
                                    Text(formatter.string(from: mybook.createAt.dateValue()))
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
                                        AsyncImage(url: URL(string:mybook.image)){ image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:90,height: 100)
                                            
                                            
                                        }placeholder: {
                                            ProgressView()
                                        }
                                        StarRatingView(rating:mybook.rating)//他のswiftファイルの構造体も参照可
                                    }//VStack
                                    VStack{
                                        Text(mybook.title)
                                        Spacer()
                                            .frame(height:20)
                                        HStack{
                                            Text("ジャンル")
                                                .foregroundColor(.gray)
                                            Text(mybook.genre)
                                        }
                                    }
                                    Spacer()
                                }//HStack
                                
                                
                                Spacer()
                                    .frame(width:10)
                                
                                Text(mybook.overview)
                                    .frame(height:100)
                                
                                
                                
                                Spacer()
                            }//VStack
                        }//NavigationLink
                        
                    }//Foreach
                    
                    
                }
                
                
            }
            
            
            
            if isToukouanime{
                List{//全く一緒
                    
                    ForEach(animetoukoulists){ myanime in
                        
                        NavigationLink(destination:MyComment2(anime:myanime)){
                            VStack{
                                Spacer()
                                    .frame(width:10)
                                
                                HStack{
                                    AsyncImage(url: URL(string:myanime.imageiconurl)){ image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:50,height: 50)
                                            .cornerRadius(30)
                                        
                                    }placeholder: {
                                        ProgressView()
                                    }
                                    
                                    Spacer()
                                        .frame(width:15)
                                    
                                    Text("\(myanime.name)")
                                        .bold()
                                    
                                    Text(formatter.string(from: myanime.createAt.dateValue()))
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
                                        AsyncImage(url: URL(string:myanime.image)){ image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:90,height: 100)
                                            
                                            
                                        }placeholder: {
                                            ProgressView()
                                        }
                                        StarRatingView(rating:myanime.rating)//他のswiftファイルの構造体も参照可
                                    }//VStack
                                    VStack{
                                        Text(myanime.title)
                                        Spacer()
                                            .frame(height:20)
                                        HStack{
                                            Text("ジャンル")
                                                .foregroundColor(.gray)
                                            Text(myanime.genre)
                                        }
                                    }
                                    Spacer()
                                }//HStack
                                
                                
                                Spacer()
                                    .frame(width:10)
                                
                                Text(myanime.overview)
                                    .frame(height:100)
                                
                                
                                
                                Spacer()
                            }//VStack
                        }//NavigationLink
                        
                    }//Foreach
                    
                    
                }
                
                
            }//ifAnime
            
            if isToukouall{
                List{
                ForEach(mixtoukoulists){ mymixitem in
                    
                    NavigationLink(destination:MyComment3(mixitem:mymixitem)){
                        VStack{
                            Spacer()
                                .frame(width:10)
                            
                            HStack{
                                AsyncImage(url: URL(string:mymixitem.imageiconurl)){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:50,height: 50)
                                        .cornerRadius(30)
                                    
                                }placeholder: {
                                    ProgressView()
                                }
                                
                                Spacer()
                                    .frame(width:15)
                                
                                Text("\(mymixitem.name)")
                                    .bold()
                                
                                Text(formatter.string(from: mymixitem.createAt.dateValue()))
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
                                    AsyncImage(url: URL(string:mymixitem.bookimage)){ image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:80,height: 80)
                                        
                                        
                                    }placeholder: {
                                        ProgressView()
                                    }
                                    StarRatingView(rating:mymixitem.bookrating)//他のswiftファイルの構造体も参照可
                                }//VStack
                                VStack{
                                    
                                    Text(mymixitem.booktitle)
                                    Spacer()
                                        .frame(height:20)
                                    HStack{
                                        Text("ジャンル")
                                            .foregroundColor(.gray)
                                        Text(mymixitem.bookgenre)
                                    }
                                }
                                
                                Spacer()
                            }//HStack
                            
                            HStack{
                                Spacer()
                                    .frame(width:2)
                                VStack{
                                    AsyncImage(url: URL(string:mymixitem.animeimage)){ image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:80,height: 80)
                                        
                                        
                                    }placeholder: {
                                        ProgressView()
                                    }
                                    StarRatingView(rating:mymixitem.animerating)//他のswiftファイルの構造体も参照可
                                }//VStack
                                VStack{
                                    Text(mymixitem.animetitle)
                                    Spacer()
                                        .frame(height:20)
                                    HStack{
                                        Text("ジャンル")
                                            .foregroundColor(.gray)
                                        Text(mymixitem.animegenre)
                                    }
                                }
                                Spacer()
                            }//HStack
                            
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
                                       Text(mymixitem.mixthema)
                                   
                                       
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
                                       
                                       Text(mymixitem.overview)
                                           .lineLimit(nil) // 行数制限なし
                                           .fixedSize(horizontal: false, vertical: true) // 縦
                                       
                                       Spacer()
                                   }
                            
                            Spacer()
                        }//VStack
                    }//NavigationLink
                    
                }//Foreach
                
            
            }
            }
            
        
        
        
        Divider()
        
        Spacer()
        
        
    }

        .onAppear(){
            formatter.dateFormat = "yyyy年MM月dd日"
            formatter.locale = Locale(identifier: "ja_JP")
            
            getIntroduce(uid:othuserid)//鍵を元に取ってくる
            getToukoubook(uid:othuserid)//.onAppearのタイミングでも良いのかな？ これだとButtonを押すたびにappendされるようになるから
            //同じ内容でも追加されてしまう 一回にしよ
            
            
        }
    }
    
    private func getIntroduce(uid:String){
        var db = Firestore.firestore()
        
        print("うんちうんちうんちうんちうんちうんち")
        
        db.collection("user").document(uid)
            .collection("Profile")
            .getDocuments{snapshots,error in
                if let error = error{
                    print("エラー")
                    return
                }
                print(uid)
                print(snapshots)
                guard let document = snapshots?.documents.first else {return}
                let data = document.data()
                print(data)
                print("おしっこ")
                if let editIntro = data["editIntro"] as? String,let imageurl = data["imageurl"] as? String
                    ,let imageiconurl = data["imageiconurl"] as? String,let name = data["name"] as? String,let label = data["label"] as? String,let animelabel = data["animelabel"] as? String{
                    let intro = Introduce(introduce: editIntro, imagebackground: imageurl,imageiconurl: imageiconurl,name:name,label:label,animelabel: animelabel)
                    introlist = intro
                    print(introlist)
                    print("a")
                }
                else{
                    print("残念でした笑")
                }
                
            }
    }
    
    
    
    private func getToukoubook(uid:String){//一回だけ呼び出される
        
        var db = Firestore.firestore()//接続
        //usersコレクションの中のdocumentエリアポインタ確保 idも含む
        print("うんちうんちうんちうんちうんち")
        //uid取得
        
        toukoulists = []
        animetoukoulists = []
        
        db.collection("user")//本物のuserIdからPostを取得
            .document(uid)
            .collection("posts")//post じゃなくてposts
            .getDocuments{ postSnapshot, error in
                if let error = error {
                    print("投稿の取得エラー: \(error)")
                    return
                }
                
                guard let postDocuments = postSnapshot?.documents else { return }//複数Documentの取得？
                
                for document in postDocuments{//多分ひとつ
                    let data = document.data()//一旦一つ前提
                    print("a")
                    if let title = data["title"] as? String,
                       let overview = data["overview"] as? String,//Any型をStringに強制変換
                       let image = data["image"] as? String,
                       let rating = data["rating"] as? Float,
                       let createAt = data["createdAt"] as? Timestamp,
                       let isComment = data["isComment"] as? [[String:String]],
                       let goodness = data["goodness"] as? Int,
                       let genre = data["genre"] as? String{
                        let item = MyToukouitem(title: title, overview: overview,name: introlist.name, Imageiconurl:/*Mytoukouitemの型は使い回し*/ introlist.imageiconurl,image:image,rating:rating,goodness: goodness,othUserId: uid,documentId:document.documentID,createAt:createAt,isComment: isComment,genre:genre)
                        
                        DispatchQueue.main.async {
                            toukoulists.append(item)
                        }
                        print(item)
                        
                    }//Stringに変換できなかったらnilにしてもらう
                }//forループ
                
                
                db.collection("user").document(uid)
                    .collection("Animeposts")
                    .getDocuments{ animesnapshots,error in
                        if let error = error{
                            print()
                        }
                        
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
                                
                                let item = AnimeToukouitem(episodes:episodes,title: title,overview: overview, name: introlist.name, imageiconurl: introlist.imageiconurl, image: image, rating: rating, goodness: goodness, othUserId: "", documentId: document.documentID, createAt: createAt, isComment: isComment,registerday: registerday,genre:genre)
                                
                                DispatchQueue.main.async{
                                    animetoukoulists.append(item)
                                }
                                print(item)
                            }
                        }
                    }//getDocument終了 Postを取得する過程
                
                db.collection("user").document(uid)
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
                               let animegenre = data["animegenre"] as? String,
                               let bookgenre = data["bookgenre"] as? String,
                               let animegenre = data["animegenre"] as? String{
                                
                                let mixitem = MixToukouitem(booktitle: booktitle, animetitle: animetitle, overview: overview, name: introlist.name, imageiconurl: introlist.imageiconurl, bookimage: bookimage, animeimage: animeimage, bookrating:bookrating, animerating: animerating, goodness: goodness,mixthema: mixthema, othUserId: "", documentId: document.documentID, createAt: createAt, isComment: isComment, registerday: registerday,animegenre:animegenre,bookgenre:bookgenre)
                                
                                DispatchQueue.main.async{
                                    mixtoukoulists.append(mixitem)
                                }
                                print(mixitem)
                            }
                            
                        }
                    }//mixitem
                
            }
    }
}


    extension View {
        func hideKeyboard8() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                for: nil)
        }  //UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
    }

