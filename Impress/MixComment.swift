//
//  Comment.swift
//  Impress
//
//  Created by user on 2025/05/26.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MixComment: View {
    
    @State var mixitem :MixToukouitem
    
    @State var onTap = false
    
    @State var formatter:DateFormatter = DateFormatter()
    
    @State var isEdit = ""
    
    @State var isShown = false
    
    @State var istouchButton = false
    
    @State var isotProfilenavigation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        NavigationLink(
            destination:Otherprofile(othuserid: mixitem.othUserId, registerday: mixitem.registerday),isActive: $isotProfilenavigation){}
        
        ZStack{
            VStack{
                Spacer()
                    .frame(height:10)
                
                HStack{
                    
                    
                    Button(action:{isotProfilenavigation = true}){
                        AsyncImage(url: URL(string:mixitem.imageiconurl)){ image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width:50,height: 50)
                                .cornerRadius(40)
                            
                        }placeholder: {
                            ProgressView()
                        }
                    }
                    
                    Spacer()
                        .frame(width:15)
                    
                    Text("\(mixitem.name)の投稿")
                        .bold()
                    
                    Text(formatter.string(from: mixitem.createAt.dateValue()))
                        .foregroundColor(.gray)
                    // .font(.system(size:16))
                    
                    Spacer()
                }//HStack
                Divider()
                    .navigationBarBackButtonHidden(true)//デフォルトのbackボタンを隠す
                    .toolbar{
                        
                        ToolbarItem(placement: .topBarLeading){
                            
                            Button("< 戻る"){
                                presentationMode.wrappedValue.dismiss()//ここでトリガーをオンにして戻っても良いけど引数関連があると面倒臭い から一つ戻るだけにする
                            }
                        }
                    }
                    .background(EnableSwipeBackGesture()) // ←ここを追加
                //Divider()
                
                Spacer()
                    .frame(height:25)
                
                HStack{
                    Spacer()
                        .frame(width:2)
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
                }//HStack
                
                HStack{
                    Spacer()
                        .frame(width:2)
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
                    }//VStack
                 
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
                }//HStack
                
                Divider()
                    
                       Spacer()
                           .frame(height:20)
                       
                       HStack{
                           Spacer()
                               .frame(width:30)
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
                               .frame(width:30)
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
                    .frame(height:15)
                
                //横は親ビュー
                HStack{
                    
                    Spacer()
                        .frame(width:1)
                    
                    Button(action:{
                        isShown = true
                    },label:{
                        Image(systemName: "bubble.left")
                        //.foregroundColor(.pink)
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                        .frame(width:150)
                    
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
                    
                    Spacer()
                        .frame(width:15)
                    //Text("\(isgoodnessalternate)")
                }//HStack
                Divider()
                
                Spacer()
                    .frame(height:10)
                
                Button("コメントを表示する"){
                    istouchButton.toggle()
                }
                .frame(width:180,height:40)
                .background(Color(red:0.9,green: 0.9,blue:0.9,opacity: 0.4))
                .foregroundColor(.black)
                
                Spacer()
                    .frame(height:20)
                
                if istouchButton{
                    ForEach(mixitem.isComment,id:\.self){ comment in
                        
                        Divider()
                        HStack{
                            //Text(comment["text"] ?? "なし")//添字アクセス君はできません 帰ってくる値はOptional　だってあるかわかんないしなかったらクラッシュする
                            
                            if let url = comment["icon"]{
                                
                                Spacer()
                                    .frame(width:10)
                                
                                AsyncImage(url: URL(string:url)){image in
                                    image
                                        .resizable()
                                        .frame(width:50,height:50)
                                        .cornerRadius(40)
                                    
                                }placeholder: {
                                    ProgressView()
                                }
                            }
                            
                            Spacer()
                                .frame(width:15)
                            
                            Text(comment["name"] ?? "なし")
                                .bold()
                            
                            Spacer()
                                .frame(width:20)
                            
                            Text(comment["date"] ?? "なし")
                                .foregroundColor(.gray)
                            Spacer()
                            
                            
                            
                        }
                        Text(comment["text"] ?? "なし")
                        
                        Divider()
                    }

                    
                }
                
                Spacer()
            }//VStack
            
            .onAppear(){
                formatter.dateFormat = "yyyy年MM月dd日"
                formatter.locale = Locale(identifier: "ja_JP")
            }
            
            if isShown{
                Color.black.opacity(0.1) // 半透明の背景（モーダル感を出す）
                            .edgesIgnoringSafeArea(.all)
                
                CustomDialog25(isShown:$isShown,isEdit:$isEdit,onSave:
                                {
                    let dating = Date()
                    let day = formatter.string(from: dating)
                    
                    updateEditMix(isComment:isEdit,othUserId:mixitem.othUserId,documentId:mixitem.documentId,date:day)
                    
                    //今見ている本は一つ それのidを送る
                    isShown = false
                }
                )
                    .frame(width:380,height:500)
                    .background(Color.white)
                    .cornerRadius(50)
            }

        }
    }//
    
    private func updateEditMix(isComment:String,othUserId:String,documentId:String,date:String){
        
        var db = Firestore.firestore()
        
        guard let userbase = Auth.auth().currentUser else{
            return//投稿主の情報　唾をつける
        }
        let UID = userbase.uid
        
        db.collection("user")
            //.document(othUserId)
            .document(UID)
            .collection("Profile")
            .document("main")//documentはもう特定されてる
            .getDocument{snapshot,error in
                if let error = error {
                    print("投稿の取得エラー: \(error)")
                    return
                }
                guard let document = snapshot?.data() else{return}
                guard let icon = document["imageiconurl"] as? String else{return}
                guard let name = document["name"] as? String else{return}
            
                
                let newComment:[String:String] = ["text":isComment,"icon":icon,"name":name,"date":date]
                
                db.collection("user")
                    .document(othUserId)
                    .collection("Mixposts")
                    .document(documentId)
                    .updateData(["isComment":FieldValue.arrayUnion([newComment])]){error in
                        if let error = error{//
                            print("error")
                            return
                        }
                    }
                mixitem.isComment.append(newComment)
            }
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
        mixitem.goodness = newGoodness
       //guard let
   }
       
    
    }


struct CustomDialog25: View {//こいつを呼び出すだけでviewを表示するんだね
   
    @Binding var isShown: Bool//Bindingにする必要ないかも　連動させる必要ないから
    @Binding var isEdit:String
    
    var onSave: () -> Void//なんでこんな関数みたいになってるの?
    
    var body: some View {//
        VStack{

            Spacer()
                .frame(height:20)
            HStack{
                
                Spacer()
                    .frame(width:40)
                
                Text("コメントを残す")
                    .font(.title2)
                    .bold()
                
                Spacer()
                    .frame(width:120)
                
                Button(action:{
                    isShown = false
                },label:{
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.black)
                })
                .frame(width:50,height:50)
            }
            
            Divider()
            
            TextEditor(text:$isEdit)
                //.fixedSize(horizontal: false, vertical: true)//自動で動的に常に計算し続けるのはできない　つまり固定の長さが最初からないTextEditorでは支えない縦方向は必要な分だけ広がる
                .frame(width:370,height:320)
            Button("投稿"){
                onSave()
            }
            .frame(width:80,height:60)
            
            .background(.gray)
            .foregroundColor(.white)
            .cornerRadius(30)
            

            Spacer()
        }
    }
}


