//
//  Followerlist.swift
//  Impress
//
//  Created by user on 2025/06/01.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct fo:Identifiable{
    var id = UUID()
    var name:String
    var editIntro:String
    var imageiconurl:String
    var registerday : Timestamp
    var othuserId : String
}

struct Followerlist: View {
    
    @State var followerList:[fo] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            Text("フォロワー一覧")
                .bold()
                .font(.title2)
            
            List{
                ForEach(followerList){follower in
                    NavigationLink(destination: Otherprofile(othuserid: follower.othuserId, registerday: follower.registerday)){
                            HStack{
                                AsyncImage(url:URL(string: follower.imageiconurl)){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:60,height:60)
                                        .cornerRadius(40)
                                    
                                }placeholder:{
                                    ProgressView()//urlを元に画像を撮ってくるときは少し時間がかかってその間にどういう画面を表示しておくか
                                }
                                
                                Spacer()
                                    .frame(width:20)
                                
                                
                                Text(follower.name)
                                    .bold()
                                
                                Text(follower.editIntro)
                                
                                
                            }
                            
                        }
                }//foreach
                .onDelete(perform: deleteFollower)
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
            
            
        }
        .onAppear(){
            getFollower()
        }
        
    }
    private func deleteFollower(at offsets: IndexSet){//スワイプしたインデックス
        
        var db = Firestore.firestore()
        
        guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
            print("ユーザーがログインしてない")
            return//いったんはカレントユーザid
        }
        let userid = userbase.uid  //uid取得
        
        db.collection("user").document(userid)
            .getDocument{ snapshot,error in
                if let error = error{
                    print("error")
                }
                
                guard let document = snapshot?.data(),let userId = document["userId"] as? String else{return}
                
                
                db.collection("user").document(userid)
                    .setData(["followers":FieldValue.arrayRemove([userId])]){error in
                        if let error = error{
                            print("削除に失敗")
                        }
                    }
            }
    }
    
    private func getFollower(){
        
        var db = Firestore.firestore()//接続
        //usersコレクションの中のdocumentエリアポインタ確保 idも含む
        
        guard let userbase = Auth.auth().currentUser else {  //現在のuser情報
            print("ユーザーがログインしてない")
            return//いったんはカレントユーザid
        }
        let userid = userbase.uid  //uid取得
        
        followerList = []
        
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
                            
                            db.collection("user")
                                .document(othuserId)
                                .collection("Profile")
                                .getDocuments{ followersnapshots,error in
                                    guard let followdocument = followersnapshots?.documents.first else{return}
                                    
                                    let fdata = followdocument.data()
                                    
                                    if let editIntro = fdata["editIntro"] as? String,
                                       let name = fdata["name"] as? String,
                                       let imageiconurl = fdata["imageiconurl"] as? String,
                                       let registerday = fdata["registerday"] as? Timestamp
                                    {
                                    
                                        let F = fo(name: name, editIntro: editIntro, imageiconurl: imageiconurl,registerday:registerday,othuserId:othuserId)
                                        followerList.append(F)
                                    }
                                }
                            
                }//followers
                
            }//getdocuments
    }//2
}
}

#Preview {
    Followerlist()
}
