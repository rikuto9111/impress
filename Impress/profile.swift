//
//  profile.swift
//  Impress
//
//  Created by user on 2025/05/02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI//フォトライブラリ用
import FirebaseStorage
import RealmSwift
import FirebaseFirestore


struct MyToukouitem:Identifiable{
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
    var genre:String
}

struct profile: View {
    
    
    @ObservedResults(Profilebase.self) var profiling

    @ObservedResults(Key.self) var key
    
    @State var userid = ""
    @State var useryear:Int = 0
    @State var usermonth:Int = 0
    @State var userday:Int = 0
    
    @State var isedit:Bool = false
    @Environment(\.presentationMode) var presentationMode//アプリ画面全てを管理する監督 Environment 今画面のviewが表示されているかどうか
    //@State var photoPickerSelectedImage:PhotosPickerItem? = nil//選択したアイテムを格納する状態変数
    
    @State var photoPickerSelectedImageIcon:PhotosPickerItem? = nil//選択したアイテムを格納する状態変数
    
    @State var captureImage:UIImage?
    @State var selectedImage:UIImage?
    
    @State var showCropper = false
    @State var captureImageIcon:UIImage?
    
    @State var editname = ""
    @State var editintro = ""
    
    @State var imageurl:String = ""
    @State var imageiconurl:String = ""
    
    @State var profile:Profilebase?//?する必要ある？？？？
    
    
    
    @State var isToukoubook = false
    @State var isToukouanime = false
    @State var isToukouall = false
    
    @State var toukoulist:[MyToukouitem] = []
    
    @State var animetoukoulists:[AnimeToukouitem] = []
    
    @State var mixtoukoulists: [MixToukouitem] = []
    
    @State var formatter:DateFormatter = DateFormatter()
    
    
    
    @State var label:String = ""
    @State var animelabel:String = ""
    
    
    var body: some View {
       // ZStack{
            
            VStack(alignment:.center){
                
                ZStack{
                    /*if let captureImage = captureImage{
                     if let croppedImage = cropImageToCenter(image: captureImage, cropSize: CGSize(width: 2000, height: 2000)){
                     //if let captureImage{
                     Image(uiImage: croppedImage)
                     .resizable()//画像サイズを変更するときは必要
                     .frame(height:90)
                     .clipped()//resizableがなかったら機能すると思うんだけどresizableがあったらframeに合うように拡大縮小されるはずだから切り取る部分がない
                     //}
                     //}
                     }*/
                    if let image = selectedImage{//リアルタイムに変化を追跡するのはstate型ならできるし、それでよかった
                        Image(uiImage: image)//保存したら入るよ
                            .resizable()//変更するには保存が必要
                        //.scaledToFit()
                            .frame(height: 90)
                    }
                    else{//🦏ビュー構成するときはcaptureImageが空になるっていう問題点があったから保存したやつを取り出す captureImageの最後の履歴
                        if let pr = profiling.first{
                            if let cap = pr.image{//dbに入ってたらそれを使う
                                //captureImage = cap
                                Image(uiImage: cap)//保存したら入るよ
                                    .resizable()//変更するには保存が必要
                                //.scaledToFit()
                                    .frame(height: 90)
                            }
                        }
                        
                        
                        else{
                            Color.yellow
                                .frame(height:90)
                        }
                    }
                
                    
                    HStack{
                        Spacer()
                            .frame(width:20)
                        Button("< 戻る") {
                            presentationMode.wrappedValue.dismiss()  //ここでトリガーをオンにして戻っても良いけど引数関連があると面倒臭い から一つ戻るだけにする 画面を把握していないとできない管理していないとね
                        }
                        

                        
                        Spacer()
                    }
                }
                .frame(height:100)
                .onTapGesture {
                    
                }
                
                

                
                ZStack{
                    
                    //ここからrealmなりから部品を拾ってきて画面に表示するだけゾーン
                    
                    //とりあえず称号表示
                    VStack(alignment:.center){
                        HStack{
                            Spacer()
                                .frame(width:1)
                            VStack{
                                Spacer()
                                    .frame(height:20)
                                
                                Text("読書称号")
                                    .frame(height:10)
                                    .foregroundColor(.gray)
                                
                                if let profile = profiling.first{
                                    if let key = key.first{
                                        Image(profile.label[key.bookkey])
                                            .resizable()
                                            .frame(width:120,height:30)
                                            .cornerRadius(20)
                                        
                                        Spacer()
                                            .frame(height:10)
                                        
                                        Text("アニメ称号")
                                            .frame(width:90,height:10)
                                            .foregroundColor(.gray)
                                        
                                        Image(profile.animelabel[key.animekey])
                                            .resizable()
                                            .frame(width:120,height:30)
                                            .cornerRadius(20)
                                    }
                                }
                                
                                
                            }
                            
                            Spacer()
                                .frame(width:20)
                            
                            
                            //自分のイメージアイコンを表示
                            ZStack{
                                if let captureImageIcon{
                                    Image(uiImage: captureImageIcon)
                                        .resizable()
                                        .frame(width:70,height:70)
                                        .cornerRadius(50)
                                }
                                else{
                                    if let pr = profiling.first{//Realmの自分のプロフィールの箱(Profilingは複数用だが一つしか入ってない)
                                        if let cap = pr.imageicon{//dbに入ってたらそれを使う
                                            
                                            Image(uiImage: cap)
                                                .resizable()
                                                .frame(width:70,height:70)
                                                .cornerRadius(50)
                                        }
                                    }
                                    else{
                                        Text("")
                                            .frame(width: 70,height:70)
                                            .background(Color.gray)
                                            .cornerRadius(35)
                                    }
                                }
                                
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                            Spacer()
                                .frame(width:60)
                            
                            //編集ボタン　押したらトリガーがオンになる
                            Button("編集"){
                                isedit = true
                            }
                            .frame(width:60,height: 40)
                            .background(Color(red:0.8,green: 0.8,blue:0.8))
                            .foregroundStyle(.white)
                            .cornerRadius(20)
                        }
                        
                        
                        
                        Spacer()
                            .frame(height:10)
                        
                        //名前なりなんなり
                        if let pr = profiling.first{//letだとOptionalではなくなる letに入ったらつまりから出ないならそのまま入れれる
                            Text("名前: \(pr.username)")
                        }
                        else{
                            Text("名無し")
                                .font(.title)
                        }
                        
                        
                        Text("ユーザID:\(userid)")
                        Text("アプリ登録日:\(String(useryear))年\(String(usermonth))月\(String(userday))日")//javaみたいに何でも変数そのまま文字列にのせて連結はできないらしい
                        
                        /* if profile.Introduce.isEmpty{//isEmptyはコレクションとかで使うイメージが強い
                         Text(profile.Introduce)
                         }*/
                        if let pro = profiling.first{//letだとOptionalではなくなる letに入ったらつまりから出ないならそのまま入れれる
                            Text("自己紹介: \(pro.Introduce)")
                        }
                        else{
                            Text("自己紹介:")//"e"+aみたいにしたらなんかうまくいかないからswift通りの手法でやろ
                        }
                        
                        Spacer()
                            .frame(height:30)
                        
                        
                        //3つ本、アニメ、本アニメボタンを用意したからそれぞれ押したらトリガーをオンにしてビューを表示する
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
                        
                        
                        Divider()
                            .background(.gray)
                        
                        
                        if isToukoubook{//本用のビュー
                            List{
                                ForEach(toukoulist){ mybook in
                                    
                                    NavigationLink(destination:MyComment(book:mybook)){
                                        VStack{
                                            Spacer()
                                                .frame(width:10)
                                            
                                            HStack{
                                                AsyncImage(url: URL(string:mybook.Imageiconurl)){ image in
                                                    image
                                                        .resizable()
                                                    //.scaledToFit()
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
                                .onDelete(perform:deleteBook)
                                
                            }
                            
                            
                        }
                        
                        if isToukouanime{//アニメ用のビュー
                            List{
                                ForEach(animetoukoulists){ myanime in
                                    
                                    NavigationLink(destination:MyComment2(anime:myanime)){
                                        VStack{
                                            Spacer()
                                                .frame(width:10)
                                            
                                            HStack{
                                                AsyncImage(url: URL(string:myanime.imageiconurl)){ image in
                                                    image
                                                        .resizable()
                                                    //.scaledToFit()
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
                                    
                                }
                                .onDelete(perform: deleteAnime)
                                
                            }
                        }
                        
                        if isToukouall{//本アニメ用のビュ-
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
                                                    //.scaledToFit() 画像が崩れないように比率を維持したままになる つまり正方形にはならない　フレームには大きい方を合わせる
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
                        
                        Spacer()//Spacer()おかないと真ん中に寄せられる
                    }//ここで一旦mainで表示したい部分終了
                    
                    .onAppear {
                        getUserID { ID in
                            if let userd = ID {  //これだと全く別のuseridに代入することになる int a = 2; if{int a = 3 別のa}print(a)
                                print("okmaru")
                                userid = userd
                            }  //クロージャーつき非同期処理が終わった後の処理
                        }
                        if let user = Auth.auth().currentUser{//自分のアプリの登録日を取得するためにAuthにアクセスして
                            if let originalday = user.metadata.creationDate{//currentUserのcreationDateにアクセスしている(Date型)
                                print("ok")
                                //userday = originalday
                                let calendar = Calendar.current//ユーザの地域情報を加味した計算ツール
                                
                                let year = calendar.component(.year, from: originalday)//年を取り出してくれるツール
                                let month = calendar.component(.month, from: originalday)//月を取り出してくれるツール
                                let day = calendar.component(.day, from: originalday)//日を取り出してくれるツール
                                
                                useryear = year
                                usermonth = month
                                userday = day
                                
                                
                                
                            }
                        }
                        
                        formatter.dateFormat = "yyyy年MM月dd日" //timestamp -> string整形ツール
                        formatter.locale =  Locale(identifier: "ja_JP")
                        
                        
                        getToukouitem() //投稿した本あにめなどを全部取得
                        
                        //多分profile.labelには達成した称号の名前とかじゃなくて番号が追加されいくわけであり、keyには現在持っている最新の称号の番号が保存されていると思うからそれでlabelを取得する
                        if let profile = profiling.first{
                            if let key = key.first{
                                label = profile.label[key.bookkey]
                                animelabel = profile.animelabel[key.animekey]
                            }
                        }
                    }
                    
                    if isedit{//ZStackの中に入っている状態
                        Color.black.opacity(0.4)
                            .ignoresSafeArea(.all)
                            .onTapGesture {  //それがここ　タップした時の反応　これって部品全部に持ってるのかな
                                hideKeyboard5()
                            }
                        
                        CustomDialog3(isedit: $isedit,
                                      editname: $editname,
                                      editintro: $editintro,
                                      selectedImage: $selectedImage,
                                      captureImageIcon: $captureImageIcon,
                                      onSave:{
                            if let selectedImage,let captureImageIcon{//selectImage,captureImageは編集ボタンを押したなら変更されなくてはならない
                                
                                addProfile(image: selectedImage, editIntro: editintro, editname: editname,imageicon: captureImageIcon)
                                uploadImage(selectedImage){ url in//第三者はセットで置いておく
                                    uploadImageIcon(captureImageIcon){ iconurl in
                                        saveUserProfile(imageurl: url, editIntro: editintro,editname:editname,imageiconurl:iconurl,label:label,animelabel:animelabel){error in
                                            if let error = error{
                                                print("error")
                                            }
                                        }
                                    }
                                }
                                
                            }//オフライン用
                            else{//これがないとビューを構成して感想名前だけ更新したいっていう時にできなくなる 一応背景画像は表示されているのに
                                if let pro = profiling.first,let image = pro.image,let icon = pro.imageicon{//
                                    addProfile(image: image, editIntro: editintro, editname: editname,imageicon: icon)
                                    uploadImage(image){url in
                                        uploadImageIcon(icon){iconurl in
                                            saveUserProfile(imageurl: url, editIntro: pro.Introduce,editname:pro.username,imageiconurl:iconurl,label:label ,animelabel:animelabel){error in
                                                if let error = error{
                                                    print("error")
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                else{
                                    print("aaa")
                                }
                            }
                            
                            
                            //オンライン用
                            
                            
                            
                            
                            isedit = false
                            
                            
                        })
                        .frame(width:400,height:600)
                    }
                    
                }

                    }
               
                .navigationBarBackButtonHidden(true)//Navigationに入っているviewだったらどこでも良い
                

            }

     //   }
    
    
    private func deleteBook(at offsets:IndexSet){
        
        let db = Firestore.firestore()
        
        for index in offsets {
            let filteredBook = toukoulist[index]  // 表示中のリストから対象を取得
            db.collection("user").document(filteredBook.othUserId).collection("posts").document(filteredBook.documentId)
                .delete{error in
                    if let error = error {
                        print("error")
                    }
                }
        }
    }
    
    private func deleteAnime(at offsets:IndexSet){
        
        let db = Firestore.firestore()
        
        for index in offsets {
            let filteredAnime = animetoukoulists[index]  // 表示中のリストから対象を取得
            print(filteredAnime)
            db.collection("user").document(filteredAnime.othUserId).collection("Animeposts").document(filteredAnime.documentId)
                .delete{error in
                    if let error = error {
                        print("error")
                    }
                }
        }
    }
    
    private func getToukouitem(){//一回だけ呼び出される
        
        var db = Firestore.firestore()//接続
        
        toukoulist = []
        animetoukoulists = []
        //usersコレクションの中のdocumentエリアポインタ確保 idも含む
        print("うんちうんちうんちうんちうんち")
        guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
            print("ユーザーがログインしてない")
            return//いったんはカレントユーザid
        }
        
        //ここからはただアクセスしてstruct構造体の型を元に追加するだけ
        let userid = userbase.uid  //uid取得
                            db.collection("user")
                                .document(userid)
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
                                        .document(userid)
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
                                                    let item = MyToukouitem(title: title, overview: overview,name: name, Imageiconurl: imageiconurl,image:image,rating:rating,goodness: goodness,othUserId: userid,documentId:document.documentID,createAt:createAt,isComment: isComment,genre:genre)
                                                    
                                                    DispatchQueue.main.async {
                                                        toukoulist.append(item)
                                                    }
                                                    print(item)
                                                    
                                                }//Stringに変換できなかったらnilにしてもらう
                                            }//forループ
                                            
                                            
                                            db.collection("user").document(userid)
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
                                                            
                                                            let item = AnimeToukouitem(episodes:episodes,title: title,overview: overview, name: name, imageiconurl: imageiconurl, image: image, rating: rating, goodness: goodness, othUserId: userid, documentId: document.documentID, createAt: createAt, isComment: isComment,registerday: registerday,genre:genre)
                                                            
                                                            DispatchQueue.main.async{
                                                                animetoukoulists.append(item)
                                                            }
                                                            print(item)
                                                        }
                                                    }
                                                }
                                            
                                            
                                            db.collection("user").document(userid)
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
                                                            
                                                            let mixitem = MixToukouitem(booktitle: booktitle, animetitle: animetitle, overview: overview, name: name, imageiconurl: imageiconurl, bookimage: bookimage, animeimage: animeimage, bookrating:bookrating, animerating: animerating, goodness: goodness,mixthema: mixthema, othUserId: "", documentId: document.documentID, createAt: createAt, isComment: isComment, registerday: registerday,animegenre:animegenre,bookgenre:bookgenre)
                                                            DispatchQueue.main.async{
                                                                mixtoukoulists.append(mixitem)
                                                            }
                                                            print(mixitem)
                                                        }
                                                        
                                                    }
                                                }//mixitem
                                            
                                                    
                                        }//getDocument終了 Postを取得する過程
                                }
                        }
                
            
                    
                    
    func cropImageToCenter(image: UIImage, cropSize: CGSize) -> UIImage? {
        let cgImage = image.cgImage!
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // 画像の中央から切り取る範囲
        let cropRect = CGRect(
            x: (imageWidth - cropSize.width) / 2,
            y: (imageHeight - cropSize.height) / 2,
            width: cropSize.width,
            height: cropSize.height
        )
        
        // 画像の中央部分をクロップ
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage)
        }
        return nil
    }
    
    //背景画像
    
    //firestoreはUIImage型とかData型は直接保存できない
    //Storageを経由するけどStorageもData型しか保存できない
    
    func uploadImage(_ image: UIImage,completion: @escaping (String) -> Void) {//completionをつけることでこいつが終わった後の処理をかける
        
        let storageRef = Storage.storage().reference()//storageを起動している 参照権get　ルートディレクトリ
        let imageRef = storageRef.child("profile_images/\(UUID().uuidString).jpg")//適当なstring.jpg被らないように その中のprofile_imagesの下にあるjpg参照
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {//Data型への変換 圧縮率
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in//参照の中のputData
                if let error = error {
                    print("アップロード失敗: \(error)")
                } else {
                    imageRef.downloadURL { url, error in//アップロードした画像のURLを直接ゲットしたい
                        if let url = url {
                            print("画像のURL: \(url.absoluteString)")
                            // FirestoreにこのURLを保存する
                            imageurl = url.absoluteString
                            completion(url.absoluteString)
                        }
                        else{
                            print("いくーーーーすーーーーー")
                        }
                    }
                    
                }
            }
            
            
        }
    }
            
    //ImageIcon用
    
    func uploadImageIcon(_ imageicon: UIImage,completion: @escaping (String) -> Void) {
        
        let storageRef = Storage.storage().reference()//storageを起動している 参照権get　ルートディレクトリ
        let imageRef = storageRef.child("profile_images/\(UUID().uuidString).jpg")//適当なstring.jpg被らないように その中のprofile_imagesの下にあるjpg参照
        
        if let imageData = imageicon.jpegData(compressionQuality: 0.8) {//Data型への変換
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in//参照の中のputData
                if let error = error {
                    print("アップロード失敗: \(error)")
                } else {
                    imageRef.downloadURL { url, error in//アップロードした画像のURLを直接ゲットしたい
                        if let url = url {
                            print("画像のURL: \(url.absoluteString)")
                            // FirestoreにこのURLを保存する
                            completion(url.absoluteString)
                            imageiconurl = url.absoluteString
                            
                        }
                        else{
                            print("アンアン行く")
                        }
                    }
                    
                }
            }
            
            
        }
    }
    
    private func saveUserProfile(imageurl:String,editIntro:String,editname:String,imageiconurl:String,label:String,animelabel:String,completion: @escaping (Error?) -> Void){
        //オンライン用
        var db = Firestore.firestore()//接続
        
        guard let userbase = Auth.auth().currentUser else {//現在のuser情報
                print("ユーザーがログインしてない")
                return
            }
        
        let user = UserProfile(id: userbase.uid,name:editname,imageurl: imageurl,editIntro: editIntro,imageiconurl:imageiconurl)//直接画像を保存できないからStorageっていう第三者を経由して保存したり取り出したりする
        //usersコレクションの中のdocumentエリアポインタ確保 idも含む
        let docRef = db.collection("user").document(userbase.uid).collection("Profile").document("main")
        //uid認証した時にこれを使って領域確保
        //docRef.documentIDは適当IDってことだよねそれはやめようx
        
        //let user = User(id: docRef.documentID,name:"陸人",createAt: Timestamp(),title: title,overview: overview)//勝手にタイムスタンプ
        //サブコレクションに追加していくときはaddかなかなかなかなsかな
        /*docRef.addDocument(data:[
            "name":user.name,
            "imageurl":user.imageurl,
            "editIntro":user.editIntro,
            "imageiconurl":user.imageiconurl
        */
        guard let originalday = userbase.metadata.creationDate else {return}
        docRef.setData([//setDataを使うときはProfileの中でidを指定しなければならない 今回idはmainにしてある
                "name": user.name,
                "imageurl": user.imageurl,
                "editIntro": user.editIntro,
                "imageiconurl": user.imageiconurl,
                "label":label,
                "animelabel":animelabel,
                "registerday":originalday
                
        ]){ error in
            completion(error)
        }
        let namelef = db.collection("user").document(userbase.uid)
        //別に親と子を勝手に連動する素晴らしい仕組みはないから手動で設定
        namelef.setData([
            "name": user.name
        ], merge: true){error in//mergeをつけることで上書き保存になる
            print(error)
        }
        
    }
    //オフライン用プロフィール保存
    private func addProfile(image:UIImage,editIntro:String,editname:String,imageicon: UIImage){//オフライン用
        do{
            if let profile = profiling.first?.thaw() {//初回編集じゃない時
                
                
                let realm = try Realm()
                try realm.write{
                    profile.image = image
                    profile.Introduce = editintro
                    profile.username = editname
                    profile.imageicon = imageicon
                    
                }
            }
            
            else{
                
                let realm = try Realm()
                
                let profile = Profilebase()
                
                profile.image = image
                profile.Introduce = editintro
                profile.username = editname
                profile.imageicon = imageicon
                profile.label.append(objectsIn:["ketu"])
                profile.animelabel.append(objectsIn:["ketu"])
                
                try realm.write{
                    realm.add(profile)
                }
            }
        }
        catch{
            print("danger")
        }
    }
    private func getUserID(completion: @escaping (String?) -> Void) {  //completionは非同期処理が終わったらに何かを実行するクロージャを渡す
        
        var db = Firestore.firestore()
        
        var UID: String = ""
        guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
            print("ユーザーがログインしてない")
            return
        }
        let userid = userbase.uid  //uid取得
        
        db.collection("user").document(userid).getDocument {
            snapshot, error in  //非同期処理
            if let error = error {  // それを元にUSErIDの検索をかける
                print("errror")
            } else {
                if let data = snapshot?.data(),
                   let fetchid = data["userId"] as? String
                {
                    UID = fetchid  //uidのkeyがないと中まで潜り込めない
                    print("a")
                    print(UID)
                    completion(UID)  //""を爆速で返すことになる 呼び出し元に返す
                } else {
                    completion(nil)
                }

            }

        }  //ここまで
        
    }
}

struct CustomDialog3: View {//こいつを呼び出すだけでviewを表示するんだね
    @Binding var isedit:Bool
    @Binding var editname:String
    @Binding var editintro:String
    @Binding var selectedImage:UIImage?
    @State var photoPickerSelectedImage:PhotosPickerItem? = nil
    
    @State var showCropper = false
    @State var captureImage:UIImage?
    
    
    @State var photoPickerSelectedImageIcon:PhotosPickerItem? = nil
    @Binding var captureImageIcon:UIImage?
    
    @ObservedResults(Profilebase.self) var profiling
    
    var onSave: () -> Void//なんでこんな関数みたいになってるの?
    
    var body: some View {//
        VStack {//それぞれの項目が20ずつ空いている
            VStack(alignment: .leading){
                HStack{
                    
                    Text("背景画像")
                    Spacer()
                        .frame(width:70)

                    
                    PhotosPicker(selection: $photoPickerSelectedImage, matching:.images,preferredItemEncoding: .automatic,photoLibrary: .shared()){//PhotosPicker
                        //だけでアルバムを呼び出し権限やらなんやらも自動で処理してくれる
                        
                        //selection　選択した写真 matching:.image　画像にアクセス .automatic　エンコードは自動で shared 共有ライブラリからの選択
                        //ユーザに選んでもらうUIを表示する

                        if let image = selectedImage{
                            Image(uiImage: image)//保存したら入るよ
                                .resizable()//変更するには保存が必要
                            //.scaledToFit()
                                .frame(height: 90)
                        }
                        else{
                            if let pr = profiling.first{
                                if let cap = pr.image{//dbに入ってたらそれを使う
                                    //captureImage = cap
                                    Image(uiImage: cap)//保存したら入るよ
                                        .resizable()//変更するには保存が必要
                                    //.scaledToFit()
                                        .frame(height: 90)
                                }
                            }
                            else{
                                ZStack{
                                    Color.yellow
                                }
                                .frame(width:70,height: 50)
                            }
                        }
                        
                    }//ボタン代わり ボタンプラス押したら写真を取ってくる
                    
                    .onChange(of: photoPickerSelectedImage,initial: true){oldValue,newValue in//変化したらnewValueに入る
                        if let newValue {
                            
                            Task {
                                // 画像のデータをロード
                                do {
                                    if let data = try? await newValue.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        captureImage = uiImage
                                        // 画像が正常に読み込まれたら、cropperを表示
                                        DispatchQueue.main.async {
                                            showCropper = true
                                        }
                                    }
                                } catch {
                                    // エラー処理
                                    print("画像の読み込みに失敗しました: \(error)")
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                HStack{
                    Text("アイコン")
                    Spacer()
                        .frame(width:70)
                    
                    PhotosPicker(selection: $photoPickerSelectedImageIcon, matching:.images,preferredItemEncoding: .automatic,photoLibrary: .shared()){
                        
                        if let captureImageIcon{
                            Image(uiImage: captureImageIcon)
                                .resizable()
                                .frame(width:70,height:70)
                                .cornerRadius(50)
                        }
                        else{
                            
                            if let pr = profiling.first{
                                if let cap = pr.imageicon{//dbに入ってたらそれを使う
                                    //captureImage = cap
                                    Image(uiImage: cap)//保存したら入るよ
                                        .resizable()//変更するには保存が必要
                                    //.scaledToFit()
                                        .frame(width:70,height: 70)
                                        .cornerRadius(50)
                                }
                            }
                            
                            else{
                                Text("")
                                    .frame(width: 70,height:70)
                                    .background(Color.gray)
                                    .cornerRadius(50)
                            }
                        }
                    }
                    
                }//ボタン代わり ボタンプラス押したら写真を取ってくる
                
                .onChange(of: photoPickerSelectedImageIcon,initial: true){oldValue,newValue in//変化したらnewValueに入る
                    if let newValue {
                        newValue.loadTransferable(type: Data.self){ result in //取得した写真情報の中で実用的なData型の部分を取り出す
                            switch result{
                            case .success(let data):
                                if let data{
                                    captureImageIcon = UIImage(data: data)

                                }
                            case .failure:
                                return
                            }
                        }
                    }
                }
                
                Divider()
                
                Spacer()
                    .frame(height:20)
                
                HStack{
                    Text("名前")
                    
                    Spacer()
                        .frame(width:20)
                    
                    TextField("名前を入力してください",text:$editname)
                }
                Divider()
                Spacer()
                    .frame(height:10)
               //HStack{
                    Text("自己紹介")  //こんな感じでVStackの配置というかHStack内にZStack入れて表示させるとかそう言ったことはできないのかもしれない
                        //.frame(width:40,height:40)
                   // Spacer()
                       // .frame(width:20)
                    
                    ZStack(alignment: .top) {
                        if editintro.isEmpty {  // 入力されていない状態
                            Text("自己紹介")  // プレースホルダー
                                .foregroundColor(.gray)
                            //.padding(.horizontal, 8)
                                .padding(.vertical, 5)
                            
                            //.border(Color.gray, width: 1)
                                .zIndex(1)  // ← プレースホルダーを前面にする！ こいつのお陰様様
                        }  //読み終わった日とカレンダーの間隔が広いから小さくしたい
                        TextEditor(text: $editintro)
                        //.padding(20)//部品内部の感覚　すなわち文字Text箱と実際の文字の感覚
                            .padding(.horizontal, 3)
                            .frame(width: 280, height: 180)
                            .background(Color.clear)  // 背景を透明にする
                        //.border(Color.gray, width: 1)
                        //.cornerRadius(80)
                            .zIndex(0)  // `TextEditor` を後ろに配置
                    }
                //}
                
                
                
                
                    
                    
                    Divider()
                
                
                HStack{
                    Spacer()
                        .frame(width:20)
                    
                    Button("キャンセル") {
                        isedit = false
                    }
                    .frame(width:90,height:45)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 8)
                    
                    Spacer()
                        .frame(width:60)
                    
                    Button("保存") {
                        if editname != "",editintro != ""{
                            onSave()//空のままでは保存させない
                        }
                    }
                    .frame(width:90,height:45)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 8)
                }
            }
            
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
        .sheet(
            isPresented: Binding(
                get: { captureImage != nil },
                set: { newValue in
                    if !newValue {
                        captureImage = nil
                    }
                }
            )
        ) {
            if let img = captureImage {
                CropViewControllerWrapper(image: img, croppedImage: $selectedImage, isPresented: $showCropper,onDismiss: {
                    captureImage = nil // ← これが呼ばれて閉じるようになる
                })

            }
         
        }
    }
}


struct UserProfile{
    var id:String
    var name:String
    var imageurl: String
    var editIntro: String
    var imageiconurl:String
}

extension View {
    func hideKeyboard5() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }  //UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}


/*
 かなりたくさんのポイントが詰まったView
 
 1  Text(formatter.string(from: mybook.createAt.dateValue()))
 
 Textは中身はStringである必要があるため無理やりString化してほしい
 
 dateValueはdate型変換 -> formatter.stringでstringに変換
 この時DateFormatter()のままだとよくわからない文字列のままだから
 formatter.dateFormat = "yyyy月MM日dd  みたいにformatを作ってから変換すると良い
 
 
 @State var formatter:DateFormatter = DateFormatter()
 
 2  firestoreのアイテムの消し方
 
 let filteredBook = toukoulist[index]  // 表示中のリストから対象を取得
 
 アイテムを取得したら
 
 db.collection("user").document(filteredBook.othUserId).collection("posts").document(filteredBook.documentId)
 
 アイテムのfirestoreでのdocumentIdを元にdocumentを取得して
 .delete({error in})するだけ
 
     .delete{error in
         if let error = error {
             print("error")
         }
     }
 
 3  if isEditの枠で firestoreのオンライン用とrealmのオフライン用に追加してるけど
 オンラインだけにするとネットワークがない時には自分のプロフィールが何もなくなるし何も見れないし
 オフラインがあるおかげでそこまではいつでも見れるようにというちょっとした気遣い
 
 4 uploadImage ImageIcon
 
 firestoreはData型もUIImage型も保存できない
 から
 Storageを使ってData型を保存 -> そこにアクセスできるようにurlを取り出し
 firestoreでurlを保存
 
 let storageRef = Storage.storage().reference()//storageを起動している 参照権get　ルートディレクトリ
 ルート参照権
 
 
 let imageRef = storageRef.child("profile_images/\(UUID().uuidString).jpg")//適当なstring.jpg被らないように その中のprofile_imagesの下にあるjpg参照
 profile_imageは手動じゃなくて勝手に作られる
 
 適当な名前のjpgを作り参照権を取得
 
 if let imageData = image.jpegData(compressionQuality: 0.8) {//Data型への変換 圧縮率
 UIImage型をjpgのData型変換 この時圧縮率も決めておく
 
 imageRef.putData(imageData, metadata: nil) { metadata, error
 
 ここで参照している場所にぶち込む
 
 imageRef.downloadURL { url, error in/
 
 参照しているurlを取得
 
 5 completionが必要な理由
 
 firestoreの通信などはすべて非同期で行われており、completionがないとそのまま関数から出てしまい特に通信した結果を返したい時　もう関数が終わってるから何も返せなくなる
 
 completionはその非同期処理が終わるのを待っていてくれる
 
 private func getUserID(completion: @escaping (String?) -> Void) {  //completionは非同期処理が終わったらに何かを実行するクロージャを渡す
     
     var db = Firestore.firestore()
     
     var UID: String = ""
     guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
         print("ユーザーがログインしてない")
         return
     }
     let userid = userbase.uid  //uid取得
     
     db.collection("user").document(userid).getDocument {
         snapshot, error in  //非同期処理
         if let error = error {  // それを元にUSErIDの検索をかける
             print("errror")
         } else {
             if let data = snapshot?.data(),
                let fetchid = data["userId"] as? String
             {
                 UID = fetchid  //uidのkeyがないと中まで潜り込めない
                 print("a")
                 print(UID)
                 completion(UID)  //""を爆速で返すことになる 呼び出し元に返す
             } else {
                 completion(nil)
             }

         }

     }  //ここまで
     
 }
}
 
 completion(UID) は渡さないと呼び出し元には結果が返っていかない
 
 6
 
 PhotosPicker(selection: $photoPickerSelectedImage, matching:.images,preferredItemEncoding: .automatic,photoLibrary: .shared()){//PhotosPicker
     //だけでアルバムを呼び出し権限やらなんやらも自動で処理してくれる
     
     //selection　選択した写真 matching:.image　画像にアクセス .automatic　エンコードは自動で shared 共有ライブラリからの選択
 
 }
 
 editからの流れ
 
 
 1  PhotosPickerでアルバムからの選択photosPickerImage(PhotosPickerItem型)に入る
 .onChangeで変化を追跡して
 
 Task {
     // 画像のデータをロード
     do {
         if let data = try? await newValue.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data) {
             captureImage = uiImage
             // 画像が正常に読み込まれたら、cropperを表示
             DispatchQueue.main.async {
                 showCropper = true
             }
         }
     } catch {
         // エラー処理
         print("画像の読み込みに失敗しました: \(error)")
     }
 }
 
 PhotosPickerItem型からData型への変換 loadTrasferableも非同期に回されるから 処理が終わるまでawaitで待って置けるようにする
 変換したらdataをUIImageに変換してcaptureImageに保存 - > showcropper起動(なくてもよい) captureimageにセットされるだけで良い気がする
 ->
 
 
 .sheet の基本
 .sheet(isPresented: Bool, content: () -> View
 
 今回
 
 isPresented: Binding(
     get: { captureImage != nil },
     set: { newValue in
         if !newValue {
             captureImage = nil
         }
     }
 )
) {
 
 Bindingはよくわからない
 get: 実際のトリガー
 
 set: newValueがnilになったらcaptureImageもnilに連携する  まあ正直あまりよくわかんない　この書き方
 
 もっと簡単な書き方ないの？
 
 
 CropViewControllerWrapper　を作って
 それを構造体として呼び出しているだけで中のアクションを勝手に拾って勝手に内部で処理しているからよくわかんない
 
 delegateとかってなんだっけ？
 UIKitの通知とswiftUiの橋渡し　通知人
 
 delegateに指定したclass　に本体が任せたい処理をその中に書いておくと
 その処理はswiftuiに通知されることができる
 
 UIViewControllerRepresentableにしなければならないの？　これにしておくと何ができるの？
 SwiftUI の世界は 全部 View。
 でも UIKit には View と ViewController があるから、そのまま持ち込めない。
 だから：
 UIKit の UIView を使いたいときは UIViewRepresentable
 UIKit の UIViewController を使いたいときは UIViewControllerRepresentable

 UIViewControllerRepresentableはプロトコル　プロトコルに従うことでViewController を使うことができるようになる
 プロトコルは共通言語的な？ 備えるべき機能
 
 
 
 makeUIViewControllerRepresentableプロトコルがあればinit()的な感じでmakeUIviewControllerが実行されて、ToCropViewControllerっていうのが作られて、シート設定もしているからUIとして出てきて、完了,キャンセル処理に関してはdelegateで指定したものに任せていて、そうすることでdelegateで任されたものはSwiftUiと繋がっているんだよね
 
 ViewControllerのシート表示はControllerが管理している画面が出てくる
 */
