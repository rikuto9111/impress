//
//  AnimeList.swift
//  Impress
//
//  Created by user on 2025/06/03.
//

import SwiftUI

import RealmSwift
import SwiftUI
import FirebaseFirestore

struct AnimeList: View {
    
    @ObservedResults(AnimeData.self) var animedatas
    
    @Environment(\.presentationMode) var presentationMode
    @State var channel = ""
    @State var showDialog = false //リスト表示するための画面を表示させるか否か
    @State var animedatalists:[AnimeData] = []
    
    
    @State var ismistery = true //ボタンチェックのためだけにある
    @State var isSF = true
    @State var isfantacy = true
    @State var isaction = true
    @State var iskyouyou = true
    @State var isnitijou = true
    @State var isrennai = true
    @State var ishora = true
    @State var issports = true
    @State var iskomedhi = true
    @State var issonota = true
    
    @State var customColor: Color = Color.red
    
    var list:[String] = ["ミステリー","SF","ファンタジー","アクション","教養","日常","恋愛","ホラー","スポーツ","コメディ","その他"]//Text("ミステリー")//表面上見えてるもの
    
    var body: some View {
        
        ZStack {

                
        Color(red: 0.7, green: 0.8, blue: 0.9,opacity: 0.8)
                //.resizable()
            //Color(red:0,green: 0,blue: 1,opacity: 0.8)
                //.resizable()
            .ignoresSafeArea()
            
            NavigationStack {
                
                VStack{
                    Text("視聴したアニメリスト")
                        .font(.title2)
                        .bold()
                   
                    Spacer()
                        .frame(height:10)
                    
                    HStack{
                        Spacer()
                            .frame(width:270)
                        
                        Button("絞り込み"){
                            showDialog = true
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    
                    .onAppear(){
                        animedatalists = Array(animedatas)
                        
                    }
                   /* Picker(selection: $channel){
                        ForEach(list,id:\.self){ item in
                            Text(item).tag(item)
                        }
                    }label:{
                        Text("切り替え")
                    }
                    .pickerStyle(.menu)
                    */
                    
                   
                    
                    
                    
                    
                  /*  .onChange(of: channel){ newValue in
                        bookdatalists = selectBook(channel:channel)
                    }*/

                    ZStack{
                        Color(red: 0.7, green: 0.8, blue: 0.9,opacity: 0.5)
                            //.ignoresSafeArea()
                        List {//今回表示する対象を選択することになるんだけどもしanimedatasでやると
                            //dbを直接見ることになる　ジャンルで表示範囲を限定するとかまず一旦全体を配列で取得してその中から選択するとかの方がやりやすい
                            //別にselectdatalistsにして初めは全部入れておいててかResult型のままでも多分できなくはない けどまあ表示するだけじゃなくてそれらのアイテムを操作するときは
                            //Arrayにする方が良いかも
                            ForEach(animedatalists) { anime in
                                AnimeRow(anime:anime)
                            }
                            .onDelete(perform: deleteAnime)
                        }
                        
                        .scrollContentBackground(.hidden)
                        
                        
                        if showDialog {
                            Color.black.opacity(0.4) // 背景の暗転
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    showDialog = false // 背景タップでダイアログを閉じる
                                }
                            
                            CustomDialog8(
                                list: list,
                                ismistery:$ismistery,//ボタンチェックのためだけにある
                                isSF:$isSF,
                                isfantacy:$isfantacy,
                                isaction:$isaction,
                                iskyouyou:$iskyouyou,
                                isnitijou:$isnitijou,
                                isrennai:$isrennai,
                                ishora:$ishora,
                                issports:$issports,
                                iskomedhi:$iskomedhi,
                                
                                issonota:$issonota,
                                
                                showDialog: $showDialog,
                                onSave: {
                                    
                                    
                                    let selectedGenres: [String] = {
                                        var genres = [String]()
                                        if ismistery { genres.append("ミステリー") }
                                        if isSF { genres.append("SF") }
                                        if isfantacy { genres.append("ファンタジー") }
                                        if isaction { genres.append("アクション") }
                                        if iskyouyou { genres.append("教養") }
                                        if isnitijou { genres.append("日常") }
                                        if isrennai { genres.append("恋愛") }
                                        if ishora { genres.append("ホラー") }
                                        if issports { genres.append("スポーツ") }
                                        if iskomedhi { genres.append("コメディ") }
                                        if issonota   { genres.append("その他") }
                                        
                                        return genres
                                    }()
                                    animedatalists = selectAnime2(channel:selectedGenres)
                                    
                                    showDialog = false
                                }
                            )//CustomDialog
                            .frame(width:380,height:500)
                            .zIndex(1) // 最前面に出す
                        }//Showdialog
                    }
                    
                    .toolbar {
                        
                        ToolbarItem(placement: .topBarLeading) {
                            
                            Button("< 戻る") {
                                presentationMode.wrappedValue.dismiss()  //ここでトリガーをオンにして戻っても良いけど引数関連があると面倒臭い から一つ戻るだけにする
                            }
                        }
                    }//toolbar
                    .background(EnableSwipeBackGesture8()) // ←ここを追加
                }
            }
        }
    }
    private func selectAnime(channel: String) -> [AnimeData] {  //本の場合はページ数も減らしておく
        do {
            let realm = try Realm()
            let selectanimedata = realm.objects(AnimeData.self).filter("genre == %@",channel)
            
            //print(selectbookdata)
            
            return Array(selectanimedata)
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
            return []
        }
    }
    private func selectAnime2(channel: [String]) -> [AnimeData] {  //本の場合はページ数も減らしておく
        do {
            let realm = try Realm()
            let selectanimedata = realm.objects(AnimeData.self).filter("genre IN %@",channel)
            
            //print(selectbookdata)
            
            return Array(selectanimedata)
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
            return []
        }
    }
    
    
    
    private func deleteCountAnime(sumTime: Int) {  //本の場合はページ数も減らしておく
        do {
            let realm = try Realm()
            try realm.write {
                if let animeCount = realm.objects(AnimeNumberCount.self).first {  //存在する場合とそうでない場合
                    animeCount.number -= 1
                    animeCount.sumTime -= sumTime
                    realm.add(animeCount,update: .modified)
                }
            }
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    
   
    
    

    
    private func deleteAnime(at offsets: IndexSet) {  //スワイプした番号をリストから教えてもらった
        
        
        do{
            let realm = try Realm()
            
            for index in offsets {
                let filteredAnime = animedatalists[index]  // 表示中のリストから対象を取得
                print(type(of:filteredAnime))

                deleteCountAnime(sumTime:filteredAnime.episode*30)//Countデータベースの値も減らしておく
                // id からライブな Realm オブジェクトを取得（Frozen を避ける）
                if let liveAnime = realm.object(ofType: AnimeData.self, forPrimaryKey: filteredAnime.id) {
                    print(liveAnime)
                    print(type(of:liveAnime))
                    try realm.write {
                        realm.delete(liveAnime)
                    }
                   
                }
                else{
                    print("うんこ")
                }
                print(offsets)
                

                //deleteCountbook(pageCount:book.pageCount)//Countデータベースの値も減らしておく
                
                let selectedGenres: [String] = {
                    var genres = [String]()
                    if ismistery { genres.append("ミステリー") }
                    if isSF { genres.append("SF") }
                    if isfantacy { genres.append("ファンタジー") }
                    if isaction { genres.append("アクション") }
                    if iskyouyou { genres.append("教養") }
                    if isnitijou { genres.append("日常") }
                    if isrennai { genres.append("恋愛") }
                    if ishora { genres.append("ホラー") }
                    if issports { genres.append("スポーツ") }
                    if iskomedhi { genres.append("コメディ") }
                    if issonota   { genres.append("その他") }
                    
                    return genres
                }()
                animedatalists = selectAnime2(channel:selectedGenres)
                //$bookdatas.remove(book)  // Realm のデータを削除
                
            }
                
            }//さっきまでのエラーは画面上で矛盾が起きていたから画面には残っている当たり前消してもリストには残っていたから
        
        catch{}
        
        }//さっきまでのエラーは画面上で矛盾が起きていたから画面には残っている当たり前消してもリストには残っていたから
    
        
    }//選択しているところで消したらそこの中で消してやる画面を再描画するつもりででもそのタイミングをStateとかに任せられるかって話でもそうはいっても冗長な気がする



struct EnableSwipeBackGesture8: UIViewControllerRepresentable {//UIViewControllerは監督
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


struct CustomDialog8: View {//こいつを呼び出すだけでviewを表示するんだね

    var list: [String]
    
    @Binding var ismistery: Bool
    @Binding var isSF :  Bool
    @Binding var isfantacy: Bool
    @Binding var isaction : Bool
    @Binding var iskyouyou: Bool
    @Binding var isnitijou: Bool
    @Binding var isrennai   : Bool
    @Binding var ishora   : Bool
    @Binding var issports   : Bool
    @Binding var iskomedhi  : Bool
    @Binding var issonota  : Bool
    
    @Binding var showDialog: Bool//Bindingにする必要ないかも　連動させる必要ないから
    
    var onSave: () -> Void//なんでこんな関数みたいになってるの?
    
    var body: some View {//
        ZStack{
            Color.white
            VStack(spacing: 15) {//それぞれの項目が20ずつ空いている
                Text("表示する本のジャンルを選択")
                    .font(.headline)
                    .padding()
                List{
                    Button("all"){
                        ismistery = true
                        isSF = true
                        isfantacy = true
                        isaction = true
                        iskyouyou = true
                        isnitijou = true
                        isrennai = true
                        ishora = true
                        issports = true
                        iskomedhi = true
                        issonota = true
                    }
                    Button("reset"){
                        ismistery = false
                        isSF = false
                        isfantacy = false
                        isaction = false
                        iskyouyou = false
                        isnitijou = false
                        isrennai = false
                        ishora = false
                        issports = false
                        iskomedhi = false
                        issonota = false
                    }
                    
                    ForEach(list,id:\.self){ item in
                        HStack{
                            Button(action: {
                                if item == "ミステリー"{
                                    ismistery.toggle()
                                    
                                }
                                else if item == "SF"{
                                    isSF.toggle()
                                }
                                else if item == "ファンタジー"{
                                    isfantacy.toggle()
                                }
                                else if item == "アクション"{
                                    isaction.toggle()
                                }
                                else if item == "教養"{
                                    iskyouyou.toggle()
                                }
                                else if item == "日常"{
                                    isnitijou.toggle()
                                }
                                else if item == "恋愛"{
                                    isrennai.toggle()
                                }
                                else if item == "ホラー"{
                                    ishora.toggle()
                                }
                                else if item == "スポーツ"{
                                    issports.toggle()
                                }
                                else if item == "コメディ"{
                                    iskomedhi.toggle()
                                }
                                else if item == "その他"{
                                    issonota.toggle()//裏表逆にする  trueにするだとタップ何回してもtrueになるだけなんよ
                                }
                            })
                            {
                                        HStack {
                                            Text(item)
                                            Spacer()
                                            if isSelected(item: item) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }//しっかりボタンはButton()で作るのはやめた方が良い
                            }
                        }
                    }
                    
                }//List
                .frame(width:320)
                .cornerRadius(30)
                .navigationBarBackButtonHidden(true)
                
                HStack {
                    Spacer()
                        .frame(width:60)
                    
                    Button("キャンセル") {
                        showDialog = false // ダイアログを閉じる
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button("適用") {
                        onSave()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: 250)
                }
                
                Spacer()
                    .frame(height:10)
            }
            .cornerRadius(30)
        }
        .cornerRadius(30)
    }
    private func isSelected(item: String) -> Bool {
        switch item {
        case "ミステリー": return ismistery
        case "SF": return isSF
        case "ファンタジー": return isfantacy
        case "アクション": return isaction
        case "教養": return iskyouyou
        case "日常": return isnitijou
        case "恋愛": return isrennai
        case "ホラー": return ishora
        case "スポーツ":return issports
        case "コメディ": return iskomedhi
        case "その他": return issonota
        default: return false
        }
    }
}


struct AnimeRow: View {
    let anime: AnimeData

    var body: some View {
        NavigationLink(
            destination: AnimeDetails(
                title: anime.title,
                image: anime.Image,
                overview: anime.overview,
                Impression: anime.Impression,
                firstdate:anime.firstdate,
                evaluate: anime.evaluate,
                episode: anime.episode,
                genre:anime.genre
                )
        ) {
            VStack {
                HStack {
                    Spacer().frame(width:10)
                    
                    Text(anime.genre)
                        .frame(width:115,height:40)
                        .background(changebackcolor(genre: anime.genre))
                        .cornerRadius(20)
                    
                    Spacer().frame(width: 20)
                    
                    Text(anime.title)
                        .frame(width:160)
                    
                    Spacer().frame(width:40)
                }
                .frame(height: 50)

                HStack {
                    Spacer().frame(width:30)
                    
                    if let req_url = URL(string: anime.Image) {
                        AsyncImage(url: req_url) { image in
                            image
                                .resizable()
                                .frame(width: 80, height: 80)
                        } placeholder: {
                            ProgressView()
                        }
                    }

                    Spacer().frame(width:25)
                    
                    Text(anime.overview)
                        .frame(width: 220, height: 150)
                    
                    Spacer().frame(width:20)
                }
            }
        }
    }
    private func changebackcolor(genre: String) -> Color{
        
        if genre == "ミステリー"{
            let selectcolor =
            Color(red:0.1,green:0.3,blue:0.5,opacity:0.5)
            return selectcolor
        }
        if genre == "SF"{
            let selectcolor =
            Color(red:0.3,green:0.35,blue:0.6,opacity:0.5)
            return selectcolor
        }
        if genre == "ファンタジー"{
            let selectcolor =
            Color(red:0.4,green:0.6,blue:0.9,opacity:0.9)
            return selectcolor
        }
        if genre == "日常"{
            let selectcolor =
            Color(red:0.4,green:0.6,blue:0.9,opacity:0.9)
            return selectcolor
        }
        if genre == "教養"{
            let selectcolor =
            Color(red:0.5,green:0.8,blue:0.82,opacity:0.5)
            return selectcolor
        }
        if genre == "ホラー"{
            let selectcolor =
            Color(red:0.4,green:0.6,blue:0.9,opacity:0.5)
            return selectcolor
        }
        if genre == "スポーツ"{
            let selectcolor =
            Color(red:0.8,green:0.9,blue:0.2,opacity:0.5)
            return selectcolor
        }
        if genre == "コメディ"{
            let selectcolor =
            Color(red:1,green:1,blue:0,opacity:0.5)
            return selectcolor
        }
        if genre == "その他"{
            let selectcolor =
            Color(red:1.0,green:1.0,blue:1,opacity:0.5)
            return selectcolor
        }
        
        
        
        else{
            return Color.white
        }
        
    }
}
