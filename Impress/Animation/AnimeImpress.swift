//
//  AnimeImpress.swift
//  Impress
//
//  Created by user on 2025/03/06.
//

import Charts
import RealmSwift
import SwiftUI

struct AnimeImpress: View {
    @ObservedResults(AnimeData.self) var animedatas  //animeデータベース
    @ObservedResults(AnimeNumberCount.self) var animedatacounts
    @State var dictionary: [String: Int] = [:]  //hashmap的なやつ Dictionary型//ジャンルごとの本数を見たい
    @State var count = 0  //ジャンル円グラフを作るため

    @State var ismainNavigation = false  //4つのフラグで4画面をメインから制御
    @State var isreadNavigation = false
    @State var ismovieNavigation = false
    @State var isanimeNavigation = false
    @State var isdoramaNavigation = false

    @State var istoukouActive = false
    
    @State var searchword = ""
    @State var counter = 1//次の10件検索用のカウント
    
    @State var isAnimelistActive = false//登録アニメのリスト表示用のflag
    
    @State var isgraphActive = false
    @State var nowmonth = 3  //現在の月
    @State var nowyear = 0//現在の年
    
    @State var selectAnimeyear2 = 1
    @State var selectAnimeyear = 1
     
    @State var selectcount = 0
    
    
    @State var isTap = false
    @State var selectedElement:Int? = nil
    @State var selectMonth = 0
    
    
    @State var selectcondition = "検索条件"

    
    
    @State private var isPressed1 = false
    @State private var isPressed2 = false
    @State private var isPressed3 = false
    @State private var isPressed4 = false
    

    @State private var selectpage :Int = 0
    
    @State var bool = false  //0を作品検索 1を作者検索　にする

    
    @State var hantei:Bool = false
    
     var animedatalist = ReadAnimeData()  //まずインスタンス生成　このクラスはObserveマクロ

    var body: some View {

        NavigationStack {  //遷移の範囲を決める

            NavigationLink(
                destination: ContentView(), isActive: $ismainNavigation
            ) {

            }
            .navigationBarBackButtonHidden(true)

            NavigationLink(
                destination: AnimeImpress(), isActive: $isanimeNavigation
            ) {

            }


            NavigationLink(
                destination: ReadImpress(), isActive: $isreadNavigation
            ) {

            }
            NavigationLink(destination: AnimeList(), isActive: $isAnimelistActive)
            {}

            
            NavigationLink(destination:Toukou(), isActive: $istoukouActive) {
            }
            
            
            ZStack {
                Color(red:0.7,green: 0.8,blue:0.9,opacity: 0.5)
                    //.resizable()
                    .ignoresSafeArea()
                    .onTapGesture {  //それがここ　タップした時の反応　これって部品全部に持ってるのかな
                        hideKeyboard9()
                    }

                VStack {
                    
                    Spacer()
                        .frame(height: 40)
                    
                    Text("アニメ記録")
                        .font(.largeTitle)
                        //.frame(width: 500, height: 100)
                        //.background(Color.green)
                    
                        .font(.title).bold()//文字のフォントを太くする
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Color.blue
                        )
                        .cornerRadius(20)
                        .shadow(radius: 4)
                    
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack(spacing:0) {
                        Spacer()
                            .frame(width: 50)
                        
                        if selectcondition == "検索条件" {
                            Text("検索条件")
                                .foregroundColor(
                                    Color(
                                        red: 0, green: 0, blue: 1.0,
                                        opacity: 0.5))
                        }
                        Picker(selection: $selectcondition) {  //何で$使うんだっけ？？？？？？
                            Text("作品名検索")  //表面上見えてるもの
                                .tag("書籍")  //tagの値がselectconditionにはセットされている
                            Text("作者検索")
                                .tag("作者")
                        } label: {
                            Text("検索")
                        }
                        .pickerStyle(.menu)
                        
                        Spacer()
                    }
                    .onChange(of: selectcondition, initial: true) {
                        oldValue, newValue in
                        
                        if newValue == "書籍" {
                            bool = false  //switch
                        } else if newValue == "作者" {
                            bool = true
                        }
                    }
                    
                    Spacer()
                        .frame(height: 10)
                    
                    HStack {
                        TextField("search for book", text: $searchword)
                        //.onSubmit(){bookdatalist.searchBooks(keyword: searchword)}
                            .disabled(selectcondition=="検索条件")//disabledの中身はboolean条件　を満たしている間は使えない
                        
                            .submitLabel(.search)
                            .textFieldStyle(RoundedBorderTextFieldStyle())  //枠がつけれる
                            .frame(width: 300)
                        
                        Button("検索") {
                            animedatalist.searchAnimes(
                                keyword: searchword, count: counter)
                            
                        }

                        .frame(width: 45, height: 35)
                        
                        .background(.blue)
 
                        .cornerRadius(10)
                        
                        .foregroundStyle(Color.white)
 

                        
                    }
                    
                    ScrollView{
                        if animedatalist.animeitems.isEmpty {  //検索していない段階
                            
                            HStack {
                                //Text("うんち")
                                VStack(spacing: 7) {
                                    Spacer()
                                        .frame(height:20)
                                    Text("\(nowmonth)月のアニメ視聴量")
                                    
                                    List {
                                        if let counting = animedatacounts.filter("month == %@ AND year == %@", nowmonth,selectAnimeyear2).first {
                                            //print("a")
                                            Text("\(counting.sumTime)分")
                                            Text("\(counting.number)本")
                                            Text(
                                                "\(counting.sumTime/30)分/日"
                                            )
                                        }
                                    }
                                    
                                    
                                    .frame(width: 250, height: 150)
                                    .scrollContentBackground(.hidden)
                                    
                                    Spacer()
                                        .frame(height:20)
                                    
                                    HStack{
                                        Button("視聴アニメ") {
                                            isAnimelistActive = true
                                        }
                                        .frame(width:140,height:40)
                                        .background(.blue.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                        
                                        Spacer()
                                            .frame(width:30)
                                        
                                        Button("投稿本・アニメ"){
                                            istoukouActive = true
                                        }
                                        .frame(width:140,height:40)
                                        .background(.blue.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                        
                                    }
                                    
                                    Spacer()
                                        .frame(height:40)
                                    
                                    ZStack {
                                        Color.white
                                        VStack {
                                            Spacer()
                                                .frame(height:15)
                                            HStack{
                                                Text("月毎のアニメ試聴時間")
                                                
                                                Picker("",selection: $selectAnimeyear2){
                                                    
                                                    Text("2025").tag(2025)
                                                    Text("2026").tag(2026)
                                                    Text("2027").tag(2027)
                                                    Text("2028").tag(2028)
                                                    
                                                }
                                            }
                                            Chart {
                                                            ForEach(1...12, id: \.self) { month in
                                                                let count = animedatacounts.first { $0.month == month && $0.year == selectAnimeyear2}?.sumTime ?? 0 //ない月は0にする
                                                                LineMark(
                                                                    x: .value("月", month),
                                                                    y: .value("視聴時間", count)
                                                                )//これだけで基本設定は終了
                                                                .symbol(Circle())
                                                            
                                                                .foregroundStyle(.blue)
                                                            }
                                                        }
                                            
                                            .frame(width: 280, height: 320)
                                            
                                            
                                            
                                            .chartXAxis {//ラベルとか
                                                AxisMarks(position:.bottom,values:[1,2,3,4,5,6,7,8,9,10,11,12])//デフォルトでメモリの感覚は1な気がするデフォルトでgridline ticklabel全部デフォ
                                                        /*_ in
                                                        AxisGridLine()
                                                        AxisTick()
                                                        AxisValueLabel()
                                                    }*/
                                                    }  // X軸のラベル　指定していないから勝手に最適化されている
                                            
                                            .chartYAxis {
                                                AxisMarks(position: .leading) {
                                                    _ in  //この中にメモリ　グリッド　ラベルを追加
                                                    AxisGridLine()
                                                    AxisTick()
                                                    AxisValueLabel()  //隠れていたラベルを呼び覚ます
                                                }
                                            }
                                        
                                                .chartXAxisLabel("月")  // X軸のラベルを追加
                                                .chartYAxisLabel("視聴時間(m)")  // Y軸のラベルを追加
                                                //.chartYScale(domain: 0...10)  // Y軸の範囲を設定
                                            
                                            
                                            
                                                .chartOverlay { proxy in GeometryReader { geometry in Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                             .gesture( DragGesture(minimumDistance: 0) .onChanged { value in
                                                                 let location = value.location
                                                                 if let monthDouble:Double = proxy.value(atX: location.x){ let month = Int(round(monthDouble))-1 //よくわからんけど2ヶ月ずれるif let month: Int = proxy.value(atX: location.x){
                                                                     if let data = animedatacounts.first(where: { $0.month == month && $0.year == nowyear}) { selectedElement = data.sumTime // ページ数だけ保持
                                                                         selectMonth = month
                                                                         isTap = true
                                                                     }
                                                                         else{ selectedElement = 0 // ページ数だけ保持
                                                                             selectMonth = month
                                                                             isTap = true
                                                                         }
                                                                     }
                                                                 
                                                             }
                                                             )
                                                     }
                                                     }
                                            HStack{
                                                Spacer()
                                                    .frame(width:80)
                                                
                                                if let selected = selectedElement{
                                                    if isTap,1<=selectMonth,selectMonth<=12{
                                                        Text("\(selectMonth)月　:\(selected)ページ")
                                                            .padding()
                                                            .background(.white)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 1)
                                                            //.position(tooltipPosition) // タップ位置に表示
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                }
                                            }
                                            
                                        }//V
                                        .frame(width: 340,height:320)
                                    }//Z
                                    .frame(width: 370, height: 440)
                                    .cornerRadius(20)
                                    
                                    .onAppear {
                                        
                                        let currentDate = Date()
                                        let calendar = Calendar.current  //ユーザの地域情報を加味した計算ツール
                                        
                                        let month = calendar.component(
                                            .month, from: currentDate)  //月を取り出してくれるツール
                                        
                                        let year = calendar.component(
                                            .year, from: currentDate)  //月を取り出してくれるツール
                                        
                                        nowmonth = month
                                        nowyear = year
                                        
                          
                                        selectAnimeyear2 = year
                                        selectAnimeyear = year
                                        
                                        //dictionary all
                                       /*for anime in animedatas {  //全部カウント
                                            count = count + 1  //何本あるかをカウントできる
                                            
                                            if let currentCount = dictionary[
                                                anime.genre]
                                            {  //ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                                                dictionary[anime.genre] =
                                                currentCount + 1
                                            } else {
                                                dictionary[anime.genre] = 1
                                            }  //varはviewに変更があった場合再描画されるんだけどその度に値がリセットされてしまう　stateつけた変数は変わったらview全体を更新する力を持ってる
                                            //viewに直接影響を与えるものに関してはStateが良い 今回はcountもdictionaryもviewにゴリゴリ与えるからStateが良い
                                            //正直難しい
                                        }  //ジャンル数をカウント*/
                                        //print(dictionary)
                                    }
                                    
                                    Spacer()
                                        .frame(height: 50)
                                    
                                    
                                    ZStack {
                                        
                                        Color.white
                                        
                                        VStack {
                                            
                                            HStack{
                                                
                                                Spacer()
                                                    .frame(width:40)
                                                
                                                Text("視聴したアニメのジャンル")
                                                
                                                Spacer()
                                                    .frame(width:15)
                                                
                                                Picker("",selection: $selectAnimeyear){
                                                    
                                                    Text("2025").tag(2025)
                                                    Text("2026").tag(2026)
                                                    Text("2027").tag(2027)
                                                    Text("2028").tag(2028)
                                                    
                                                }
                                                .onChange(of: selectAnimeyear){//onchangeに入るたびにdictionaryを初期化しないとダメ　じゃないと残っちゃう
                                                    print("ghaphfaihfeowaihfaweihfpoahwiofihapw")
                                                    dictionary = [:]
                                                    let animeselectdatas = animedatas.filter{ $0.year == selectAnimeyear }
                                                    print(animeselectdatas)
                                                    for anime in animeselectdatas{  //全部カウント        Chartの中でごちゃごちゃ描くのはダメなのかな？
                                                        selectcount = selectcount + 1  //何本あるかをカウントできる
                                                        print(selectcount)
                                                        if let currentCount = dictionary[
                                                            anime.genre]
                                                        {  //ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                                                            dictionary[anime.genre] =
                                                            currentCount + 1
                                                            print(currentCount)
                                                        } else {
                                                            dictionary[anime.genre] = 1
                                                            print("0")
                                                        }  //varはviewに変更があった場合再描画されるんだけどその度に値がリセットされてしまう　stateつけた変数は変わったらview全体を更新する力を持ってる
                                                        //viewに直接影響を与えるものに関してはStateが良い 今回はcountもdictionaryもviewにゴリゴリ与えるからStateが良い
                                                        //正直難しい
                                                    }
                                                }
                                                
                                                Spacer()
                                                   
                                            }
                                            
                                            Chart {  //つまり最低限だとidさえ設定しておけばあとはkey,value　これがあれば同じように使える それをいうならdictionaryがidentifiableに準拠していないとリストも同様
                                                
                                               // let animeselectdatas = animedatas.first{ $0.year == selectAnimeyear } filterで複数取れる
                                                //let animeselectdatas = animedatas.filter{ $0.year == selectAnimeyear }
                                                
                                                /*for anime in animeselectdatas{  //全部カウント        Chartの中でごちゃごちゃ描くのはダメなのかな？
                                                    selectcount = selectcount + 1  //何本あるかをカウントできる
                                                    
                                                    if let currentCount = dictionary[
                                                        anime.genre]
                                                    {  //ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                                                        dictionary[anime.genre] =
                                                        currentCount + 1
                                                    } else {
                                                        dictionary[anime.genre] = 1
                                                    }  //varはviewに変更があった場合再描画されるんだけどその度に値がリセットされてしまう　stateつけた変数は変わったらview全体を更新する力を持ってる
                                                    //viewに直接影響を与えるものに関してはStateが良い 今回はcountもdictionaryもviewにゴリゴリ与えるからStateが良い
                                                    //正直難しい
                                                }*/
                                                
                                                ForEach(
                                                    dictionary.sorted(by: {
                                                        $0.key < $1.key
                                                    }), id: \.key
                                                ) { key, value in  //dictionaryが普通のリストじゃないからちょっと工夫
                                                    SectorMark(  //keyはジャンル名　valueは数  棒だとbarmark
                                                        angle: .value(
                                                            "Count",
                                                            value * 100 / selectcount),  //これを円グラフを構成するcountとして使うよっていう意味のvalue
                                                        //innerRadius: .ratio(0.5),//小さい縁の半径
                                                        angularInset: 1.5
                                                    )
                                                    .foregroundStyle(
                                                        by: .value("Genre", key)
                                                    )  //keyっていう変数をbyに使うよっていう意味
                                                    .annotation(
                                                        position: .overlay
                                                    ) {  //それぞれのグラフのパーツに適応させる注釈
                                                        let persent =
                                                        Double(value)
                                                        / Double(selectcount)
                                                        * 100
                                                        
                                                        Text(
                                                            String(
                                                                format:
                                                                    "%.0f%%",
                                                                persent))  //その上に重ねるのがoverlay
                                                    }
                                                }
                                            }
                                            .frame(width: 320, height: 350)
                                        }
                                        .frame(width: 350, height: 380)
                                    }
                                    .frame(width: 370, height: 440)
                                    .cornerRadius(20)
                                }
                                
                            }
                            
                        } else {
                            VStack{
                                List {
                                    
                                    ForEach(animedatalist.animeitems) { anime in
                                        NavigationLink(
                                            destination: AnimeRegister(
                                                selectanime: anime)
                                        ) {  //選択した本のデータを引き渡す*/
                                            
                                            HStack {
                                                Spacer()
                                                    .frame(width: 30)
                                                VStack{
                                                    if isAlreadyRegistered(anime: anime){//LIstビューも要素が少しでも変わったら再描画される falseになって表示しないってなったら早速戻って全体が更新されるつまり全体がfalseのまま更新されるmのかな //hanteiっていう一つの状態変数を使っているとswiftuiはビューごとに状態変数で監視すべきだし思った以上に再描画しまくっているから仮に初めtrueでもtrueじゃないやつにぶち当たって　つまりそんな共通の変数一つで管理できるほどリストというか器用じゃない
                                                        HStack{
                                                            Spacer()
                                                                .frame(width:30)
                                                            Text("登録済み⭐️")//Viewを表示てしている間に
                                                                .foregroundColor(.gray)
                                                            Spacer()
                                                                
                                                        }
                                                        
                                                            .onAppear(){
                                                                print(hantei)
                                                                //DispatchQueue.main.async{//具体的にしっかり表示し終わった後にやることを明記
                                                                    hantei = false
                                                                }
                                                            }
                                                        //hantei = false//判定が変わる　どっちやねんってswiftuiは思うわけかな？　view構築中に判定を変えるな
                                                    //.onAppearとかは構築後だからいける
                                                        
                                                    
                                                    
                                                    
                                                    Text(anime.title)
                                                        .frame(
                                                            width: 270, height: 100)
                                                }
                                                /*.onAppear(){
                                                    do {
                                                        let realm = try Realm()
                                                        if let bookCount = realm.objects(BookData.self).filter("title == %@",book.title).first{  //存在する場合とそうでない場合
                                                            hantei = true
                                                        }
                                                        
                                                    } catch {
                                                        print("Error adding task: \(error.localizedDescription)")
                                                    }
                                                    
                                                }*/
                                                Spacer()  //AsyncImageをつけないとメインスレッド更新
                                                //故に画像を撮ってきている間に画面がフリーズする
                                                //それが嫌だったら非同期でimage(url)を撮ってきたい
                                                //それがviewの中だけどAsyncImage
                                                    .frame(width: 30)
                                                
                                                let animeimage = anime.image.absoluteString
                                                
                                                AsyncImage(
                                                    url: URL(string:"https://image.tmdb.org/t/p/w500/\(animeimage)")
                                                ) { image in
                                                    image  //httpsじゃないと許してもらえない
                                                        .resizable()
                                                        .frame(
                                                            width: 80,
                                                            height: 90)
                                                    
                                                }placeholder: {
                                                    ProgressView()  //非同期で動かしている間画面のインジゲータ
                                                }
                                               
                                               
                                                
                                            }//HStack
                                        }//Navigation
                                        
                                    }//Foreach
                                    HStack {
                                        Spacer()
                                            .frame(width: 100)
                                        Button("次の10件") {  //次の10件を推したらurlにcount属性追加したやつに切り替える　それで検索をかけるんだけど前のやつは消える
                                            counter += 1
                                            animedatalist.searchAnimes(
                                                keyword: searchword,
                                                count: counter)
                                        }
                                    }//HStack
                                    
                                }//List
                                .frame(width:450,height:1400)
                                .scrollContentBackground(.hidden)  //リストの要素の背景じゃなくて　リストの枠の背景を隠す
                            }
                            
                        }//else
                        Spacer()
                    }

                    HStack(spacing:20){  //4画面へのボタン
                        Button("Home") {
                            ismainNavigation = true
                        }
                        
                            Button(action:{
                                isreadNavigation = true
                            },label:{
                                //VStack(spacing:2){//デフォルト8
                                  Text("読書")
                                    .frame(width:85,height:50)
                                    .background(.green)
                                    .foregroundStyle(.white)
                                    .cornerRadius(30)
                                    .scaleEffect(isPressed1 ? 0.90 : 1.0) // ✅ 押したときに少し縮む　.scaleEffectはサイズ倍率　今回条件を満たすことで変更
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)//radiusはぼかし具合らしい　x,yは元に対してどれだけずらすか
                            })
                            
                                    
                            
                      

                   
                        
                    Button(action:{
                            isanimeNavigation = true
                    },label:{
                        Text("アニメ")
                          .frame(width:90,height:50)
                          .background(.blue)
                          .foregroundStyle(.white)
                          .cornerRadius(30)
                          .scaleEffect(isPressed3 ? 0.90 : 1.0) // ✅ 押したときに少し縮む　.scaleEffectはサイズ倍率　今回条件を満たすことで変更
                          .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
             
                })
                
                    
                

            
                
                
                }
                    }//HStack
                }
            }
       }
        
    

    
    func isAlreadyRegistered(anime: AnimeItem) -> Bool {
        let realm = try? Realm()
        return realm?.objects(AnimeData.self).contains(where: { $0.title == anime.title }) ?? false
    }
        
    }

//}


extension View {
    func hideKeyboard9() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }  //UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}  //FirstResponderは現在フォーカスが当てられている部品のこと　それを否定　resignすることでそらす　sendActionはUIkitの持っているメソッド 指定アクションをfromさんからtoさんに送信
 
