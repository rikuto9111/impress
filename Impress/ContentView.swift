//
//  ContentView.swift
//  Impress
//
//  Created by user on 2025/03/02.
//

import FirebaseAuth
import FirebaseFirestore
import RealmSwift
import SwiftUI

struct ContentView: View {
    
    @ObservedResults(Key.self) var keydata
    
    @ObservedResults(BookDataCount.self) var bookdatacount
    @ObservedResults(AnimeNumberCount.self) var animenumbercount
    @State var isreadNavigation = false  //4つのフラグで4画面をメインから制御
    @State var ismainNavigation = false  //4つのフラグで4画面をメインから制御
    @State var ismovieNavigation = false
    @State var isanimeNavigation = false
    @State var isdoramaNavigation = false
    @State var searchword = ""
    @State var userid = ""
    var bookdatalist = ReadData()  //まずインスタンス生成　このクラスはObserveマクロ
    
    //var viewModel = Usermodel()
    @State var isshowmenu = false
    
    @State var isPressed1 = false
    @State var isPressed2 = false
    @State var isPressed3 = false
    @State var isPressed4 = false
    
    
    @State var isfollow = false
    @State var isprofile = false
    @State var isfollower = false
    
    @State var bookkey:Int = 0
    @State var animekey:Int = 0
    
    
    /*@State private var progressValue = 0.1
    @State private var progressanimeValue = 0.1*/
    
    @State var sumbookcount:Int = 0
    @State var sumanimecount:Int = 0
 
    
    var jisho:[[String:String]] = [["name":"読書初級者","gazou":"dokusho1","page":"1000"],["name":"読書好き","gazou":"dokusho2","page":"5000"],["name":"読書中級者","gazou":"dokusho3","page":"10000"],["name":"趣味読書","gazou":"dokusho4","page":"50000"],["name":"地元の読書王","gazou":"dokusho5","page":"100000"],["name":"読書王","gazou":"dokusho6","page":"200000"],["name":"読書マスター","gazou":"dokusho7","page":"500000"],["name":"読書の神","gazou":"dokusho8","page":"1000000"]]
    
    var animejisho:[[String:String]] = [["name":"アニメ初級者","gazou":"anime1","page":"1000"],["name":"アニメ好き","gazou":"anime2","page":"5000"],["name":"アニメ中級者","gazou":"anime3","page":"10000"],["name":"趣味アニメ","gazou":"anime4","page":"50000"],["name":"クラスのアニオタ","gazou":"anime5","page":"100000"],["name":"超アニオタ","gazou":"anime6","page":"200000"],["name":"アニメマスター","gazou":"anime7","page":"500000"],["name":"アニメの神","gazou":"anime8","page":"1000000"]]
    
    
    var body: some View {
        
        NavigationStack {  //遷移の範囲を決める
            
            ZStack {
                
                
                VStack {
                    //NavigationLink(destination:ContentView(),isActive: $ismainNavigation){
                    
                    //}
                    
                    NavigationLink(
                        destination: ReadImpress(), isActive: $isreadNavigation
                    ) {
                        
                    }
                    .navigationBarBackButtonHidden(true)
                    NavigationLink(
                        destination: EigaImpress(), isActive: $ismovieNavigation
                    ) {
                        
                    }
                    NavigationLink(
                        destination: AnimeImpress(),
                        isActive: $isanimeNavigation
                    ) {
                        
                    }
                    NavigationLink(
                        destination: DramaImpress(),
                        isActive: $isdoramaNavigation
                    ) {
                        
                    }
                    NavigationLink(
                        destination: profile(), isActive: $isprofile
                    ) {
                        
                    }
                    NavigationLink(
                        destination: follower(), isActive: $isfollow
                    ) {
                        
                    }
                    
                    NavigationLink(
                        destination: Followerlist(), isActive: $isfollower
                    ) {
                        
                    }
                    
                    ZStack {//ZStackがいまだにわからん
                        
                        VStack{
                            Spacer()
                                .frame(height: 20)
                            
                            Text("記録メータ")
                                .font(.largeTitle)
                            //.frame(width: 500, height: 100)
                            //.background(Color.green)
                            
                                .font(.title).bold()  //文字のフォントを太くする
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    //Color.green
                                    Color(red:0.7,green: 0.7,blue: 0.7)
                                )
                                .cornerRadius(20)
                                .shadow(radius: 4)
                            
                            
                            
                            //VStack{//暗転ZStackがこいつの子供になっているせいで範囲が限定されている
                            
                            HStack {
                                Spacer()
                                    .frame(width: 270)
                                
                                Button(action: {
                                    withAnimation {
                                        isshowmenu.toggle()
                                    }
                                }) {
                                    Image(systemName: "line.horizontal.3")  // ハンバーガー
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                            
                            
                            
                            //Spacer()
                               // .frame(height:20)
                            
                            ScrollView{
                                Text("読書メータ")
                                    .bold()
                                    .font(.title3)
                                
                                VStack{
                                    Spacer()
                                        .frame(height:20)
                                    
                                    HStack{
                                        Spacer()
                                            .frame(width:10)
                                        VStack{
                                            if let image = jisho[bookkey]["gazou"]{
                                                Image(image)
                                                    .resizable()
                                                    .frame(width:100,height:30)
                                                    .shadow(radius:2)
                                            }
                                        }
                                        VStack{
                                            if let name = jisho[bookkey]["name"]{
                                                Text("\(name)への道")
                                            }
                                            ZStack{
                                                if let page = jisho[bookkey]["page"],let pagenumber = Float(page){
                                                    
                                                    ProgressView(value:Float(sumbookcount)/(pagenumber))
                                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                                        .frame(height:40)//別にバーの太さは変わらない appleがそうしたから
                                                        .scaleEffect(x:1,y:4)//これは裏技
                                                    
                                                    
                                                    Text("\(sumbookcount)/\(page)")
                                                }
                                                
                                            }
                                            
                                            Button("獲得"){
                                                if let page = jisho[bookkey]["page"],let pagenumber = Float(page), let gazou = jisho[bookkey]["gazou"]{
                                                    if Float(sumbookcount)/(pagenumber) >= 1.0{
                                                        updatebookKey(key:bookkey,label:gazou)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                    .frame(width:340,height: 130)
                                    .background(Color(red:0.4,green:0.8,blue:0.3,opacity: 0.2))
                                    .cornerRadius(15)
                                    //.shadow(radius:1)
                                   
                                    Spacer()
                                        .frame(height:20)
                                    
                                    HStack{
                                        Spacer()
                                        Button(action: {
                                            // 読書登録画面へ遷移する処理
                                            isreadNavigation = true
                                        }) {
                                            Label("読書登録へ　＞", systemImage: "book.fill") // ← ここで📚アイコン
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(width:210)
                                                .background(Color.green.opacity(0.9))
                                                .cornerRadius(10)
                                        }
                                        
                                        Spacer()
                                            .frame(width:30)
                                    }
                                    
                                    Spacer()
                                }
                                
                                .frame(width:360,height:240)
                                .background(Color(red:0.75,green:1.0,blue:0.3,opacity: 0.5))
                                .cornerRadius(15)
                                
                                
                                
                                Spacer()
                                    .frame(height:10)
                                
                                Text("アニメメータ")
                                    .bold()
                                    .font(.title3)
                                
                                VStack{
                                    Spacer()
                                        .frame(height:20)
                                    HStack{
                                        Spacer()
                                            .frame(width:10)
                                        VStack{
                                            if let image = animejisho[animekey]["gazou"]{
                                                Image(image)
                                                   .resizable()
                                                    .frame(width:100,height:30)
                                               // selectImage = image
                                                    .shadow(radius:5)
                                                    
                                            }
                                            
                                        }
                                        
                                        VStack{
                                            if let name = animejisho[animekey]["name"]{
                                                Text("\(name)への道")
                                            }
                                                
                                            
                                            ZStack{
                                                
                                                if let number = animejisho[animekey]["page"],let animenumber = Float(number){
                                                    
                                                    ProgressView(value:Float(sumanimecount)/(animenumber))
                                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                                        .frame(height:40)//別にバーの太さは変わらない appleがそうしたから
                                                        .scaleEffect(x:1,y:4)//これは裏技
                                                    
                                                    Text("\(sumanimecount)/\(number)")
                                                }
                                            }
                                           // .onAppear(){
                                               
                                           // }
                                            
                                            Button("獲得"){
                                                if let number = animejisho[animekey]["page"],let animenumber = Float(number),let gazou = animejisho[animekey]["gazou"]{
                                                    if Float(sumanimecount)/(animenumber) >= 1.0{
                                                        updateanimeKey(key:animekey,label:gazou)
                                                        
                                                    }
                                                    else{
                                                        print("うんこ")
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    .frame(width:340,height: 130)
                                    .background(Color(red:0.7,green:0.8,blue:0.9,opacity: 0.9))
                                   // .background(selectImage ?? Color.green)//backgroundにxcassetにあってもString型を入れることはできないここでエラーになっている
                                    .cornerRadius(15)
                                    .shadow(radius:2)
                                    
                                    Spacer()
                                        .frame(height:20)
                                    
                                    HStack{
                                        Spacer()
                                        Button(action: {
                                            // 読書登録画面へ遷移する処理
                                            isanimeNavigation = true
                                        }) {
                                            Label("アニメ登録へ　＞", systemImage: "film.fill") // ← ここで📚アイコン
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(width:210)
                                                .background(Color.blue.opacity(0.8))
                                                .cornerRadius(10)
                                        }
                                        Spacer()
                                            .frame(width:30)
                                    }
                                    
                                    Spacer()
                                }
                                .frame(width:360,height:240)
                                
                                .background(Color(red:0.5,green:0.8,blue:0.9,opacity: 0.5))
                                .cornerRadius(15)
                                /* if isshowmenu {//よくわからないけどこのままではうまくいかない
                                 VStack{
                                 
                                 Button("フォロワー登録") { }
                                 Divider()
                                 Button("プロフィール") { }
                                 }
                                 .padding()
                                 .frame(width: 180)
                                 .background(Color.white)
                                 .cornerRadius(10)
                                 .shadow(radius: 5)
                                 .transition(.move(edge: .top))
                                 .zIndex(1)
                                 }*/
                                Spacer()
                                
                                
                            }
                            
                            
                            //.zIndex(100)
                        }
                        
                        VStack{
                        Spacer()
                                .frame(height:700)
                            HStack(spacing: 20) {  //4画面へのボタン
                                Button("Home") {
                                    ismainNavigation = true
                                }
                                
                                Button(
                                    action: {
                                        isreadNavigation = true
                                    },
                                    label: {
                                        //VStack(spacing:2){//デフォルト8
                                        Text("読書")
                                            .frame(width: 90, height: 50)
                                            .background(.green)
                                            .foregroundStyle(.white)
                                            .cornerRadius(30)
                                            .scaleEffect(isPressed1 ? 0.90 : 1.0)  // ✅ 押したときに少し縮む　.scaleEffectはサイズ倍率　今回条件を満たすことで変更
                                            .shadow(
                                                color: .black.opacity(0.2),
                                                radius: 4, x: 2, y: 2)  //radiusはぼかし具合らしい　x,yは元に対してどれだけずらすか
                                    })
                                
                                
                                
                                Button(
                                    action: {
                                        isanimeNavigation = true
                                    },
                                    label: {
                                        Text("アニメ")
                                            .frame(width: 90, height: 50)
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .cornerRadius(30)
                                            .scaleEffect(isPressed3 ? 0.90 : 1.0)  // ✅ 押したときに少し縮む　.scaleEffectはサイズ倍率　今回条件を満たすことで変更
                                            .shadow(
                                                color: .black.opacity(0.2),
                                                radius: 4, x: 2, y: 2)
                                        
                                    })
                                
                            }
                            
                        }//H
                        .onAppear(){
                            if let key = keydata.first{//ちゃんと会ってそして取り出す
                                bookkey = key.bookkey
                                animekey = key.animekey
                            }
                            
                            else{//realmに初めてアクセスするとき
                                createKey()

                            }
                            
                            sumbookcount = 0
                            sumanimecount = 0
                            bookdatacount.forEach{ bookcount in //onAppearは画面が表示されるたびに実行される　つまり戻ってきた時もこれが起動される　ただState はここに向かう時しか初期化されていない気がする
                                
                                sumbookcount += bookcount.pagesumCount
                            }
                            
                            animenumbercount.forEach{ count in //forEachはデータ処理用　ForEachは描画処理用
                                 
                                    sumanimecount += count.sumTime
                               
                            }
                            
                            
                            print(bookkey)
                            print(animekey)
                            
                        }
                        
                        
                        
                        if isshowmenu {
                            
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    isshowmenu = false
                                }
                            
                            
                            CustomDialog2(
                                isfollow: $isfollow, isprofile: $isprofile,isfollower: $isfollower,
                                onSave: {
                                    isshowmenu = false
                                }
                            )
                            .frame(width:200,height:200)
                            .background(Color.white)
                            .cornerRadius(30)
                            
                            //Spacer()
                            
                        }
                        
                    }  //HStack
                    .frame(maxHeight:.infinity)
                    
                }
            }
                /*if isshowmenu{
                 HStack{
                 Spacer()
                 .frame(width:150)
                 
                 //List{//Listはzで違う次元に干渉しやがるから使うのやめよ　押し出される
                 VStack{
                 Button("フォロワー登録"){
                 
                 }
                 Divider()
                 Button("プロフィール"){
                 
                 }
                 }
                 }
                 
                 .zIndex(1)
                 .frame(width:200,height:130)
                 .background(.white)
                 }*/
            }
        }  //何でバーだけ変えることをしないのか
        //それだけ変えていけるけど自分の元の画面に戻ってくる時はボタン付きのものを
    
    
    private func updatebookKey(key:Int,label:String){
        do{
            let realm = try Realm()
            
            try realm.write{
                if let bookKey = realm.objects(Key.self).first{
                    bookKey.bookkey = key + 1
                }
            }
        
            try realm.write{
                if let profile = realm.objects(Profilebase.self).first{
                    profile.label.append(label)
                    print(profile.label)
                }
            }
            
        }
        catch{
            print("エラー")
        }
        bookkey = bookkey + 1
        
    }
    
    private func updateanimeKey(key:Int,label:String){
        do{
            let realm = try Realm()
            
            try realm.write{
                if let animeKey = realm.objects(Key.self).first{
                    animeKey.animekey = key + 1
                 
                }
                
            }
            
            try realm.write{
                if let profile = realm.objects(Profilebase.self).first{
                    profile.animelabel.append(objectsIn:[label])
                    print(profile.animelabel)
                }
            }
            
        }
        catch{
            print("エラー")
        }
        print(label)
        animekey = animekey + 1
    }
    
    
    private func createKey(){
        do{
            let realm = try Realm()
            
            try realm.write{
               let Key = Key()
                
                Key.animekey = 0
                Key.bookkey = 0
                
                realm.add(Key)
                
                }
                
            }
        
        catch{
            
        }
        
    }
    }  //くっつけることになるから　自分から他のとこに行く時と戻ってくる時で制御フラグをつけて
    
    
    
    //ボタン以下をviewするか管理してもええけど少し面倒　どっちでも良い
    
    

struct CustomDialog2: View {
    @Binding var isfollow:Bool
    @Binding var isprofile:Bool
    @Binding var isfollower:Bool
    
    var onSave: () -> Void

    var body: some View {
        VStack {

            Button("フォロワー登録") {isfollow = true}
            Divider()
            Button("プロフィール") {isprofile = true}
            Divider()
            Button("フォロワー一覧"){isfollower = true}
        }
        .padding()
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .transition(.move(edge: .top))

    }
}
