//
//  follower.swift
//  Impress
//
//  Created by user on 2025/05/02.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct OtherProfileitem: Identifiable{
    var id = UUID()
    var Introduce:String
    var othername:String
    var imageiconurl:String
    var imageurl:String
    var registerday:Timestamp
    var othuserId : String
}

struct follower: View {
    
    @State private var isShown = false
    @State var isShown2 = false
    @State var editId = ""
    @State var ismove = false
    @State var otherlist:[OtherProfileitem] = []
    @State private var isShowAlert = false
    
    @State var isnavigation = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {//otherlistにappendするとたくさん出てくるけど同じアイテムは一つで良い
        if let list = otherlist.first{
            NavigationLink(
                destination: Otherprofile(othuserid: list.othuserId, registerday: list.registerday), isActive: $isnavigation
            ) {
                
            }//どうせ検索結果は一つしかない前提で繊維を定義している
        }
        ZStack{

            VStack{
                ZStack{
                    VStack{
                        Text("ヒットしたフォロワー")
                            .bold()
                            .font(.title2)
                        
                        List{
                            ForEach(otherlist){ list in
                                VStack{
                                    Spacer()
                                        .frame(height:15)
                                    
                                    HStack{
                                        Spacer()
                                            .frame(width:10)
                                        
                                        Button(action:{isnavigation = true}){
                                            AsyncImage(url:URL(string: list.imageiconurl)){ image in
                                                image
                                                    .resizable()
                                                //.scaledToFit()
                                                    .frame(width:70,height:70)
                                                    .cornerRadius(50)
                                                
                                            }placeholder:{
                                                ProgressView()//urlを元に画像を撮ってくるときは少し時間がかかってその間にどういう画面を表示しておくか
                                            }
                                        }
                                        
                                        Spacer()
                                            .frame(width: 50)
                                        
                                        Text(list.othername)
                                            .bold()
                                            .font(.title3)
                                        
                                        Spacer()
                                    }//HStack
                                   
                                    VStack{
                                            
                                            Spacer()
                                                .frame(height:20)
                                            Text(list.Introduce)
                                        
                                 
                                        /*VStack{
                                         
                                         Spacer()
                                         .frame(height:10)
                                         
                                         Text(list.Introduce)
                                         }*/
                                        
                                        
                                    }
                                    
                                    
                                    
                                    /*AsyncImage(url:URL(string: list.imageurl)){ image in
                                     image
                                     .resizable()
                                     .scaledToFit()
                                     }placeholder:{
                                     ProgressView()//urlを元に画像を撮ってくるときは少し時間がかかってその間にどういう画面を表示しておくか
                                     }*/
                                    .contentShape(Rectangle())
                                    //空白部分の有効化
                                    .onTapGesture{
                                        isShowAlert = true
                                    }
                                    
                                    Spacer()
                                }
                            }//Foreach
                            .cornerRadius(60)
                        }//list
                        
                        .alert("確認",isPresented:$isShowAlert){
                            Button("戻る"){
                                
                            }
                            Button("フォロー"){
                                addFollowers(editId:editId)
                            }
                        }
                        Spacer()
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
                    
                    if isShown2{
                        
                        Color.black.opacity(0.2)
                            .ignoresSafeArea(.all)
                            .onTapGesture {  //それがここ　タップした時の反応　これって部品全部に持ってるのかな
                                hideKeyboard5()
                            }
                        
                        CustomDialog4(isShown: $isShown, editId: $editId, onSave: {
                            searchFollower(editId:editId){ error in
                                if let error = error{
                                    print("error")
                                }//メソッドを検索してすぐ消されちゃうと困る
                                
                            }
                            isShown2 = false
                        })
                        .frame(width:370,height: 350)
                        .background(Color.white)
                        .cornerRadius(50)
                        
                    }
                }
                
            }
        }
       // .navigationBarBackButtonHidden(true)//Navigationに入っているviewだったらどこでも良い
        .onAppear(){
            if !isShown{
                isShown = true//2枚のトリガーを使うことによってビューの再描画時に起動せず初回のみにする　状態変数との組み合わせ　多分状態変数は再描画時にそのまま
                isShown2 = true
            }
        }
    }
    
    private func addFollowers(editId:String){
        var db = Firestore.firestore()
        guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
            print("ユーザーがログインしてない")
            return
        }
        let userid = userbase.uid  //uid取得
        
        db.collection("user")
            .document(userid)
            .updateData([//setDataでは配列の更新はできても追加はできない updateは配列の追加と特定のフィールドの更新が得意
                "followers": FieldValue.arrayUnion([editId])
                
            ]){error in
                if let error = error {  // それを元にUSErIDの検索をかける
                    print("errror")
                    return
                }
                else{
                    print("追加ok")
                }

                
            }
    }

    
    private func searchFollower(editId:String,completion: @escaping (String?) -> Void){
        var db = Firestore.firestore()
        db.collection("user")
            .whereField("userId", isEqualTo: editId)//id入力したものと照合
            .getDocuments{snapshot,error in
                if let error = error{//snapshotは複数要素持ちでその中の一つ一つがdataを持つ
                    print("error")
                    return
                }
                guard let documents = snapshot?.documents,let otheruserDoc = documents.first else{
                    return
                }
                //ここまでで他人のポインタ取得
                let userId = otheruserDoc.documentID//それが必要 カギみたいなもの
                
                db.collection("user")
                    .document(userId)
                    .collection("Profile")
                    .getDocuments{prosnapshot,error in
                        if let error = error {
                            print("投稿の取得エラー: \(error)")
                            return
                        }
                        
                        guard let otherprofiledocuments = prosnapshot?.documents else{
                            return
                        }
                        print("a")
                        
                        for document in otherprofiledocuments{
                            let data = document.data()//一旦一つ前提
                            print("a")
                            
                            if let Introduce = data["editIntro"] as? String,let imageiconurl = data["imageurl"] as? String,let imageurl = data["imageiconurl"] as? String,
                               let othername = data["name"] as? String
                                , let registerday = data["registerday"] as? Timestamp{//Any型をStringに強制変換
                                
                                let item = OtherProfileitem(Introduce: Introduce, othername: othername,imageiconurl: imageiconurl,imageurl:imageurl,registerday: registerday,othuserId: userId)
                                
                                otherlist.append(item)
                                print(item)
                            }
                            
                            
                        }
                    
                        
                    }
            }
    }
        
}


struct CustomDialog4: View {//こいつを呼び出すだけでviewを表示するんだね
    @Binding var isShown:Bool
    
    @State var userId = ""
    @Binding var editId:String
    
    var onSave: () -> Void//なんでこんな関数みたいになってるの?
    
    var body: some View {//
        VStack {//それぞれの項目が20ずつ空いている
            VStack(alignment: .center){
                Text("フォロワー検索")
                    .font(.title)
                Spacer()
                    .frame(height:20)
                
                HStack{
                    Text("あなたのID")
                        .font(.body)
                    Spacer()
                        .frame(width:20)
                    
                    VStack{
                        Spacer()
                            .frame(height:20)
                        Text(userId)
                            .font(.body)
                    }
                }

                Divider()
                TextField("IDを入力してください",text:$editId)
                    .frame(width:300)
                
                Divider()
                Spacer()
                    .frame(height:40)
                //HStack{
                //こんな感じでVStackの配置というかHStack内にZStack入れて表示させるとかそう言ったことはできないのかもしれない
                //.frame(width:40,height:40)
                // Spacer()
                // .frame(width:20)
                
                
                //}
                

                
                

                    Button("検索") {
                        if editId != ""{
                            onSave()//空のままでは保存させない
                        }
                    }
                    .frame(width:90,height:45)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 8)
                
                
            }//VStack
            .onAppear(){
                getUserID { ID in
                    if let userid = ID {  //これだと全く別のuseridに代入することになる int a = 2; if{int a = 3 別のa}print(a)
                        print("okmaru")
                        userId = userid//state変数に格納
                    }  //クロージャーつき非同期処理が終わった後の処理
                }
            }
            
      
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
                //print(UID)
            }
            //print(UID)
            //return UID
        }  //ここまで
        
    }
                
                
                
                
                
            }
