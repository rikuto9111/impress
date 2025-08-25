//
//  bookdetails.swift
//  Impress
//
//  Created by user on 2025/03/30.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import RealmSwift


struct StarRatingView: View{
    
    var rating: Float = 0.0
    
    var body: some View{
        HStack(spacing:1){
            ForEach(0..<5, id: \.self){ index in
                let full = Float(index) < floor(rating)
                let half = Float(index)+0.5 == rating//最後の半分
                
                Image(systemName: full ? "star.fill": (half ? "star.leadinghalf.filled" : "star"))//条件分岐を一行で済ましている
                    .foregroundColor(.yellow)//Swiftこういうとこあるから嫌
            }//空白の有無でエラーになる
        }
    }
}

struct Bookdetails: View {
    @State var title:String
    @State var image:String
    @State var pagenumber:Int
    @State var overview:String
    @State var Impression:String
    @State var evaluate:Float
    @State var genre:String
    @State var isShowAlert = false
    @State var isShowAlert2 = false
    @State var isShowAlert3 = false
    @State var isShowAlert4 = false
    
    @State var showDoneMessage = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectanime:AnimeData = AnimeData()
    @State var isEdit1 = ""
    @State var isEdit2 = ""
    
    var body: some View {
        ZStack{
            
            Image(.readbackground)
                .resizable()
                .ignoresSafeArea()
            ZStack{
                VStack{
                    
                    Text("読んだ本情報")
                        .font(.largeTitle)
                    //.frame(width: 500, height: 100)
                    //.background(Color.green)
                    
                        .font(.title).bold()//文字のフォントを太くする
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Color.green
                        )
                        .cornerRadius(20)
                        .shadow(radius: 3)
                    
                    Spacer()
                        .frame(height:10)
                    
                    List{
                        HStack{
                            Spacer()
                                .frame(width:5)
                            
                            Text("タイトル")
                                .foregroundColor(.gray)
                            //.frame(width:90)
                            
                            Spacer()
                                .frame(width:70)
                            
                            Text(title)
                        }
                        HStack{
                            Spacer()
                                .frame(width:5)
                            
                            Text("ジャンル")
                                .foregroundColor(.gray)
                            //.frame(width:90)
                            
                            Spacer()
                                .frame(width:70)
                            
                            Text(genre)
                        }
                        
                        HStack{
                            Spacer()
                                .frame(width:5)
                            
                            Text("ページ数")
                                .foregroundColor(.gray)
                            //.frame(width:90)
                            
                            Spacer()
                                .frame(width:70)
                            
                            Text("\(pagenumber)ページ")
                        }
                        
                        /*.overlay(//いまいちわかっていないけどHStackVstackに枠線を囲いたいときに使う
                         RoundedRectangle(cornerRadius: 10)
                         .stroke(Color.green, lineWidth: 2)
                         )*/
                        
                        HStack{
                            
                            Spacer()
                                .frame(width:20)
                            VStack{
                                
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
                                    .frame(height:10)
                                
                                StarRatingView(rating:evaluate)
                            }
                            
                            Spacer()
                                .frame(width:15)
                            
                            Text(overview)
                                .frame(width:210,height:240)
                        }
                        .padding(5)
                        /* .overlay(
                         RoundedRectangle(cornerRadius: 10)
                         .stroke(Color.green, lineWidth: 2)
                         )*/
                        HStack{
                            Spacer()
                                .frame(width:7)
                            
                            Text("感想")
                                .foregroundColor(.gray)
                            //.frame(width:40)
                            
                            Spacer()
                                .frame(width:55)
                            
                            
                            Text(Impression)
                            //.border(Color.black)//言葉の通りでそのまま角張った線を引く
                                .padding(20)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationBarBackButtonHidden(true)//デフォルトのbackボタンを隠す
                    .toolbar{
                        
                        ToolbarItem(placement: .topBarLeading){
                            
                            Button("< 戻る"){
                                presentationMode.wrappedValue.dismiss()//ここでトリガーをオンにして戻っても良いけど引数関連があると面倒臭い から一つ戻るだけにする
                            }
                        }
                    }
                    
                    
                    .frame(width:400)
                    
                    .overlay{
                        if showDoneMessage{
                            Text("投稿完了")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button("投稿する"){
                        
                        
                        isShowAlert = true
                        
                    }
                    .frame(width:100,height:70)
                    
                    .background(Color.blue.opacity(0.4))
                    .cornerRadius(30)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    
                    .alert("投稿してもよろしいですか",isPresented:$isShowAlert){
                        Button("戻る"){
                            
                        }
                        Button("投稿"){
                            //post()
                            isShowAlert2 = true
                        }
                        
                    }
                    .alert("他の本やアニメと合わせて投稿しますか?",isPresented: $isShowAlert2){
                        Button("いいえ"){
                            post()
                        }
                        Button("はい"){
                            isShowAlert3 = true
                        }
                    }
                    
                    Spacer()
                }
            }
            if isShowAlert3{
                Color.black.opacity(0.4)
                    .onTapGesture {
                        isShowAlert3 = false // 背景タップでダイアログを閉じる
                    }
                
                CustomDialog20(
                    
                    isShowAlert3: $isShowAlert3,
                    isShowAlert4: $isShowAlert4,
                    selectanime: $selectanime,
                    onSave: {
                        
                        isShowAlert3 = false
                    }
                )//CustomDialog
                .frame(width:380,height:500)
                
            }
            
            
            if isShowAlert4{
                Color.black.opacity(0.4)
                    .onTapGesture {
                        isShowAlert4 = false // 背景タップでダイアログを閉じる
                    }
                
                CustomDialog21(
                    
                    isShowAlert4: $isShowAlert4,
                    selectanime: $selectanime,
                    title: $title,
                    isEdit1:$isEdit1,
                    isEdit2: $isEdit2,
                    onSave: {
                        
                        mixpost()
                        isShowAlert4 = false
                    }
                )//CustomDialog
                .frame(width:380,height:550)
                
            }
            
        }
    }
    
    private func post(){
        
        saveUser(title:title,overview:overview,rating:evaluate){error in
            if let error = error{
                print("error")
            }
            
        }
        withAnimation {
                    showDoneMessage = true
                }
        DispatchQueue.main.asyncAfter(deadline: .now()+2){//この中の処理を2秒後に非同期で行うよ
            withAnimation {
                        showDoneMessage = false
                    }
        }
        
    }
    
    private func mixpost(){
        
        saveUserMix(title:title, overview: overview, rating:evaluate,anime: selectanime,mixthema:isEdit1,impress:isEdit2) { error in
            if let error = error{print("error")}
            
        }
    
            
        
        withAnimation {
                    showDoneMessage = true
                }
        DispatchQueue.main.asyncAfter(deadline: .now()+2){//この中の処理を2秒後に非同期で行うよ
            withAnimation {
                        showDoneMessage = false
                    }
        }
        
    }
    
    private func saveUser(title:String,overview:String,rating:Float,completion: @escaping (Error?) -> Void){
        
        var db = Firestore.firestore()//接続
        
        guard let userbase = Auth.auth().currentUser else {//現在のuser情報
                print("ユーザーがログインしてない")
                return
            }
        
        guard let originalday = userbase.metadata.creationDate else {return}
        
        db.collection("user").document(userbase.uid)
            .getDocument{snapshot,error in
                print("error")
                guard let data = snapshot?.data() else{return}
                guard let name = data["name"] as? String else{return}
                
                
                let user = User(id: userbase.uid,name:name,createAt: Timestamp(),title: title,overview: Impression,image: image,rating: rating,goodness: 0,isComment: [[:]])//overviewはfirestore上には必要ないからoverviewじゃなくてImpressionを名前を借りて代わりに送っておく
                //usersコレクションの中のdocumentエリアポインタ確保 idも含む
                let docRef = db.collection("user").document(userbase.uid).collection("posts")
                //uid認証した時にこれを使って領域確保
                //docRef.documentIDは適当IDってことだよねそれはやめようx
                
                //let user = User(id: docRef.documentID,name:"陸人",createAt: Timestamp(),title: title,overview: overview)//勝手にタイムスタンプ
                //サブコレクションに追加していくときはaddかなかなかなかなsかな
                docRef.addDocument(data:[
                    "id":user.id,//勝手に作られる
                    "name":user.name,
                    "createdAt":user.createAt,
                    "title":user.title,
                    "overview":user.overview,
                    "image":user.image,//url
                    "rating":user.rating,
                    "goodness": user.goodness,
                    "isComment":user.isComment,
                    "registerday":originalday,
                    "genre":genre
                    /*docRef.setData([
                     "id":user.id,//勝手に作られる
                     "name":user.name,
                     "createdAt":user.createAt,
                     "title":user.title,
                     "overview":user.overview
                     */
                ]){ error in
                    completion(error)
                }
            }
    }
    
    
    private func saveUserMix(title:String,overview:String,rating:Float,anime:AnimeData,mixthema:String,impress:String,completion: @escaping (Error?) -> Void){
        
        var db = Firestore.firestore()//接続
        
        guard let userbase = Auth.auth().currentUser else {//現在のuser情報
                print("ユーザーがログインしてない")
                return
            }
        
        guard let originalday = userbase.metadata.creationDate else {return}
        
        db.collection("user").document(userbase.uid)
            .getDocument{snapshot,error in
                print("error")
                guard let data = snapshot?.data() else{return}
                guard let name = data["name"] as? String else{return}
                
                
                let user = User(id: userbase.uid,name:name,createAt: Timestamp(),title: title,overview: Impression,image: image,rating: rating,goodness: 0,isComment: [[:]])//overviewはfirestore上には必要ないからoverviewじゃなくてImpressionを名前を借りて代わりに送っておく
                //usersコレクションの中のdocumentエリアポインタ確保 idも含む
                let docRef = db.collection("user").document(userbase.uid).collection("Mixposts")
                //uid認証した時にこれを使って領域確保
                //docRef.documentIDは適当IDってことだよねそれはやめようx
                
                //let user = User(id: docRef.documentID,name:"陸人",createAt: Timestamp(),title: title,overview: overview)//勝手にタイムスタンプ
                //サブコレクションに追加していくときはaddかなかなかなかなsかな
                docRef.addDocument(data:[
                    "id":user.id,//勝手に作られる
                    "name":user.name,
                    "createdAt":user.createAt,
                    "title":user.title,
                    "mixoverview":impress,
                    "image":user.image,//url
                    "rating":user.rating,
                    "goodness": user.goodness,
                    "isComment":user.isComment,
                    "registerday":originalday,
                    "animetitle":anime.title,
                    "animeimage":anime.Image,
                    "animerating":anime.evaluate,
                    "mixthema":mixthema,
                    "animegenre":anime.genre,
                    "bookgenre":genre
                    /*docRef.setData([
                     "id":user.id,//勝手に作られる
                     "name":user.name,
                     "createdAt":user.createAt,
                     "title":user.title,
                     "overview":user.overview
                     */
                ]){ error in
                    completion(error)
                }
            }
    }
    
}
struct CustomDialog20: View {//こいつを呼び出すだけでviewを表示するんだね

    @Binding var isShowAlert3: Bool//Bindingにする必要ないかも　連動させる必要ないから
    @Binding var isShowAlert4: Bool
    
    @State var animedatas:[AnimeData] = []
    @Binding var selectanime:AnimeData
    
    var onSave: () -> Void//なんでこんな関数みたいになってるの?
    
    var body: some View {//
        
        ZStack{
            Color.white
            
            VStack{
                Spacer()
                    .frame(height:20)
                
                Text("合わせて投稿するアニメを選択")
                    .font(.title2)
                
                Spacer()
                    .frame(height:10)
                
                List{
                    ForEach(animedatas){ animedata in
                        Button(action:
                                {
                            selectanime = animedata
                            isShowAlert4 = true
                            isShowAlert3 = false
                           }){
                        HStack{
                            if let req_url = URL(string:animedata.Image){
                                
                                AsyncImage(url: req_url) { image in
                                    image
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                } placeholder: {
                                    ProgressView()  //非同期で動かしている間画面のインジゲータ
                                }
                            }
                            Spacer()
                                .frame(width:30)
                            
                            
                            
                            Text(animedata.title)
                        }
                    }
                }
            }
                               }
        }
        
        .onAppear(){
            getAnimeRealm()
        }
        
        
        
    }
    
    private func getAnimeRealm(){
        do{
            let realm = try Realm()
            
            let animes = realm.objects(AnimeData.self)
            
            animes.forEach{ anime in
                animedatas.append(anime)
            }
            
    }catch{
        
    }
}
    
}


struct CustomDialog21: View {//こいつを呼び出すだけでviewを表示するんだね

    @Binding var isShowAlert4: Bool//Bindingにする必要ないかも　連動させる必要ないから
    
    @Binding var selectanime:AnimeData
    @Binding var title:String
    
    @Binding var isEdit1:String
    @Binding var isEdit2:String
    
    var onSave: () -> Void//なんでこんな関数みたいになってるの?
    
    var body: some View {//
        
        ZStack{
            Color(red:0.9,green: 0.9,blue: 0.9)
                .onTapGesture {//それがここ　タップした時の反応　これって部品全部に持ってるのかな
                    dismissKeyboard10()
                }
            
            VStack{
                Spacer()
                    .frame(height:20)
                
                Text(" アニメ:\(selectanime.title)　\n 本:\(title)")
                    .font(.title2)
                    .fixedSize(horizontal: false, vertical: true)

                
                Divider()
                
                Spacer()
                    .frame(height:20)
                
                ScrollView{
                    Section(header: Text("共通点").font(.title3)){
                        Spacer()
                            .frame(height:10)
                        
                        //ForEach(animedatas){ animedata in
                        HStack{
                            
                            ZStack(alignment: .top) {
                                
                                if isEdit2.isEmpty {  // 入力されていない状態
                                    Text("ここに共通点を入力")  // プレースホルダー
                                        .foregroundColor(.gray)
                                    //.padding(.horizontal, 8)
                                        .padding(.vertical, 30)
                                    
                                    //.border(Color.gray, width: 1)
                                        .zIndex(1)  // ← プレースホルダーを前面にする！ こいつのお陰様様
                                }  //読み終わった日とカレンダーの間隔が広いから小さくしたい
                                TextEditor(text: $isEdit2)
                                    .padding(20)//部品内部の感覚　すなわち文字Text箱と実際の文字の感覚
                                    .padding(.horizontal, 8)
                                    .frame(width: 400, height: 160)
                                    .background(Color.white)  // 背景を透明にする
                                //.border(Color.gray, width: 1)
                                
                                    .cornerRadius(40)
                                    .zIndex(0)  // `TextEditor` を後ろに配置
                            }
                            
                        }
                        
                        
                    }
                    Divider()
                    
                    
                    
                    
                    Spacer()
                        .frame(height:15)
                    
                    
                    Section(header: Text("合わせての感想").font(.title3)){
                        Spacer()
                            .frame(height:10)
                        
                        ZStack(alignment: .top) {
                            if isEdit1.isEmpty {  // 入力されていない状態
                                Text("ここに感想を入力")  // プレースホルダー
                                    .foregroundColor(.gray)
                                //.padding(.horizontal, 8)
                                    .padding(.vertical, 30)
                                
                                //.border(Color.gray, width: 1)
                                    .zIndex(1)  // ← プレースホルダーを前面にする！ こいつのお陰様様
                            }  //読み終わった日とカレンダーの間隔が広いから小さくしたい
                            TextEditor(text: $isEdit1)
                                .padding(20)//部品内部の感覚　すなわち文字Text箱と実際の文字の感覚
                                .padding(.horizontal, 8)
                                .frame(width: 400, height: 260)
                                .background(Color.white)  // 背景を透明にする
                            //.border(Color.gray, width: 1)
                                .cornerRadius(40)
                                .zIndex(0)  // `TextEditor` を後ろに配置
                        }
                        //.background(.gray.opacity(0.5))
                    }
                    
                    Spacer()
                        .frame(height:15)
                    
                    
                    Button("投稿する"){
                        onSave()
                    }
                    .frame(width:90,height:60)
                    .background(.blue.opacity(0.8))
                    .cornerRadius(20)
                    
                    .foregroundColor(.white)
                    
                    Spacer()
                        .frame(height:30)
                    
                }
                
            }
                }
            }
        
        

        
        
        
    }

extension View {

        //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        func dismissKeyboard10() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { $0.endEditing(true) }
            }
        
    }//UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}

    

