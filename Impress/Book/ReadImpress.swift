import Charts
import RealmSwift
import SwiftUI

struct ReadImpress: View {
    @ObservedResults(BookData.self) var bookdatas  //登録した本に対してのdbの観測者
    @ObservedResults(BookDataCount.self) var bookdatacount//本の合計ページ数の観測者

    @State var dictionary: [String: Int] = [:]  //hashmap的なやつ Dictionary型
    @State var count = 0  //ジャンル円グラフを作るため

    @State var bookcount = 0
    
    @State var ismainNavigation = false  //3つのフラグで3画面を制御
    @State var isreadNavigation = false
    @State var isanimeNavigation = false

    @State var istoukouActive = false
    
    @State var searchword = ""
    @State var counter = 0
    @State var islistActive = false
    @State var isgraphActive = false
    @State var nowmonth = 3  //現在の月
@State var nowyear = 0 // 現在の年
    @State var selectyear = 1//
    @State var selectyear2 = 1
    @State var selectyear3 = 1//円グラフ用
    
    @State var selectcondition = "検索条件"
    @State private var selectedElement: Int? = nil
    @State private var tooltipPosition: CGPoint = .zero
    
    
    @State private var isPressed1 = false
    @State private var isPressed2 = false
    @State private var isPressed3 = false
    @State private var isPressed4 = false
    
    @State private var selectMonth:Int = 0
    @State private var selectpage :Int = 0
    
    @State var bool = false  //0を作品検索 1を作者検索　にする

    @State var isTap = true //ページ数タップ表示
    
    @State var hantei:Bool = false
    
     var bookdatalist = ReadData()  //まずインスタンス生成　このクラスはObserveマクロ

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
            NavigationLink(destination: Readbooklist(), isActive: $islistActive)
            {}


            
            NavigationLink(destination:Toukou(), isActive: $istoukouActive) {
            }
            
            
            ZStack {
                Image(.readbackground)//背景画像の指定
                    .resizable()
                    .ignoresSafeArea()
                    .onTapGesture {  //それがここ　タップしたらフォーカスが離れる
                        hideKeyboard4()
                    }

                VStack {
                    
                    Spacer()
                        .frame(height: 40)
                    
                    Text("読書記録")
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
                        Picker(selection: $selectcondition) {  //検索する際にPickerで選択しなければ検索ワードを入力できないようになっている
                            Text("書籍検索")  //表面上見えてるもの
                                .tag("書籍")  //tagの値がselectconditionにはセットされている
                            Text("作者検索")
                                .tag("作者")
                        } label: {
                            Text("検索")
                        }
                        .pickerStyle(.menu)
                        
                        Spacer()
                    }
                    
                    .onChange(of: selectcondition, initial: true) {//Pickerで選択した値が書籍なのか作者なのかで検索方法を変えている
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
                            bookdatalist.searchBooks(//bookdatalistはReadDataのクラス変数的なもの
                                keyword: searchword, count: counter, bool: bool)//searchBooksは検索入力したものをクエリとして検索してbookitemsの中に検索結果が入る
                            
                        }

                        .frame(width: 45, height: 35)
                        
                        .background(.blue)
 
                        .cornerRadius(10)
                        
                        .foregroundStyle(Color.white)
 

                        
                    }
                    
                    ScrollView{
                        if bookdatalist.bookitems.isEmpty {  //検索していない段階
                            
                            HStack {
                                //Text("うんち")
                                VStack(spacing: 7) {
                                    Spacer()
                                        .frame(height:20)
                                    Text("\(nowmonth)月の読書量")
                                    
                                    List {
                                        if let counting = bookdatacount.filter("month == %@ AND year == %@" , nowmonth,nowyear).first {//その月に追加した本がある時
                                            //print("a")
                                            Text("\(counting.pagesumCount)ページ")
                            
                                            Text("\(counting.number)冊")
                                            Text(
                                                "\(counting.pagesumCount/30)ページ/日"
                                            )
                                        }
                                        else{//その月に追加した本がある時
                                            //print("a")
                                            Text("0ページ")
                            
                                            Text("0冊")
                                            Text(
                                                "0ページ/日"
                                            )
                                        }
                                    }
                                    
                                    .onAppear(){
                                        print(bookdatacount)
                                    }
                                    
                                    
                                    .frame(width: 250, height: 150)
                                    .scrollContentBackground(.hidden)
                                    
                                    Spacer()
                                        .frame(height:20)
                                    
                                    HStack{
                                        Button("読んだ本") {
                                            islistActive = true
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
                                            
                                  
                                            
                                            HStack{
                                                
                                                Spacer()
                                                    .frame(width:45)
                                                
                                                Text("月毎の読んだ冊数")
                                                
                                                Spacer()
                                                    .frame(width:15)
                                                
                                                Picker("",selection: $selectyear2){
                                                    Text("2025").tag(2025)
                                                    Text("2026").tag(2026)
                                                    Text("2027").tag(2027)
                                                    Text("2028").tag(2028)
                                                    
                                                }
                                                
                                 
                                                Spacer()
                                            }
                                            
                                            Chart {
                                                            ForEach(1...12, id: \.self) { month in
                                                                let count = bookdatacount.first { $0.month == month && $0.year == selectyear2}?.number ?? 0
                                                                BarMark(
                                                                    x: .value("月", month),
                                                                    y: .value("冊数", count)
                                                                )
                                                                
                                                            
                                                                .foregroundStyle(.blue)
                                                            }
                                                        }
                                            
                                            .frame(width: 280, height: 320)
                                            
                                            
                                            
                                            .chartXAxis {
                                                AxisMarks(position:.bottom,values:[1,2,3,4,5,6,7,8,9,10,11,12])//デフォルトでメモリの感覚は1な気がするデフォルトでgridline ticklabel全部デフォ
                                                   
                                                    }  // X軸のラベル　指定していないと勝手に最適化されている
                                            
                                            .chartYAxis {//正直要らなかったかもデフォルト(AxisMarks())でもこいつらは表示される
                                                AxisMarks(position: .leading) {
                                                    _ in  //この中にメモリ　グリッド　ラベルを追加
                                                    AxisGridLine()
                                                    AxisTick()
                                                    AxisValueLabel()  //隠れていたラベルを呼び覚ます
                                                }
                                            }
                                        
                                                .chartXAxisLabel("月")  // X軸のラベルを追加
                                                .chartYAxisLabel("冊数")  // Y軸のラベルを追加
                                            
                                            
                                                
                                            
                                                //.chartYScale(domain: 0...10)  // Y軸の範囲を設定
                                        }//V
                                        .frame(width: 280)
                                    }//Z
                                    .frame(width: 350, height: 400)
                                    .cornerRadius(20)
                                    
                                    .onAppear {
                                        
                                        let currentDate = Date()
                                        let calendar = Calendar.current  //ユーザの地域情報を加味した計算ツール
                                        
                                        let month = calendar.component(
                                            .month, from: currentDate)  //月を取り出してくれるツール
                                        
                                        let year = calendar.component(
                                            .year, from: currentDate)
                                        
                                        nowmonth = month
                                        nowyear = year
                                        
                                        selectyear = year
                                        selectyear2 = year
                                        selectyear3 = year
                                        /*for book in bookdatas {  //全部カウント
                                            count = count + 1  //何冊あるかをカウントできる
                                            
                                            if let currentCount = dictionary[
                                                book.genre]
                                            {  //ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                                                dictionary[book.genre] =
                                                currentCount + 1
                                            } else {
                                                dictionary[book.genre] = 1
                                            }  //varはviewに変更があった場合再描画されるんだけどその度に値がリセットされてしまう　stateつけた変数は変わったらview全体を更新する力を持ってる
                                            //viewに直接影響を与えるものに関してはStateが良い 今回はcountもdictionaryもviewにゴリゴリ与えるからStateが良い
                                            //正直難しい
                                        } */ //ジャンル数をカウント
                                        print(dictionary)
                                    }
                                    
                                    Spacer()
                                        .frame(height: 40)
                                    
                                    ZStack {
                                        Color.white
                                            .ignoresSafeArea()
                                            .onTapGesture {
                                                        // グラフ外タップで非表示
                                                isTap = false
                                                    }
                                        VStack {
                                            Spacer()
                                                .frame(height:15)
                                            HStack{
                                                Spacer()
                                                    .frame(width:85)
                                                
                                                Text("月毎の読んだページ数")
                                                
                                                Spacer()
                                                    .frame(width:15)
                                                
                                                Picker("",selection: $selectyear){
                                                    Text("2025").tag(2025)
                                                    Text("2026").tag(2026)
                                                    Text("2027").tag(2027)
                                                    Text("2028").tag(2028)
                                                    
                                                }
                                                Spacer()
                                                    
                                            }
                                            
                                            Chart {
                                                ForEach(1...12, id: \.self) { month in
                                                    let count = bookdatacount.first { $0.month == month && $0.year == selectyear}?.pagesumCount ?? 0
                                                    LineMark(//bookdatacount.first{ book in book.monthのこと 一番最初}
                                                        x: .value("月", month),
                                                        y: .value("冊数", count)
                                                    )
                                                    .symbol(Circle())
                                                    
                                                    
                                                    //.foregroundStyle(selectMonth == month ? .red : .orange)
                                                    .foregroundStyle(.orange)
                                                }
                                            }
                                            
                                            .chartXAxis {//xは強制的に1から12に
                                                AxisMarks(position:.bottom,values:[1,2,3,4,5,6,7,8,9,10,11,12])//デフォルトでメモリの感覚は1な気がするデフォルトでgridline ticklabel全部デフォ
                                                        /*_ in
                                                        AxisGridLine()
                                                        AxisTick()
                                                        AxisValueLabel()
                                                    }*/
                                                    }  // X軸のラベル　指定していないから勝手に最適化されている
                                            
                                            .chartYAxis {//yはどういう指定なんだろうね?
                                                AxisMarks(position: .leading) {
                                                    _ in  //この中にメモリ　グリッド　ラベルを追加
                                                    AxisGridLine()
                                                    AxisTick()
                                                    AxisValueLabel()  //隠れていたラベルを呼び覚ます
                                                }
                                            }
                                        
                                                .chartXAxisLabel("月")  // X軸のラベルを追加
                                                .chartYAxisLabel("冊数")  // Y軸のラベルを追加
                                            
                                                .frame(width: 320,height:320)
                                                //.chartYScale(domain: 0...10)  // Y軸の範囲を設定
                                      /*  .chartOverlay { proxy in
                                                                GeometryReader { geometry in
                                                                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                                        .gesture(
                                                                            TapGesture()
                                                                                .onChanged { value in
                                                                                    let location = value.location(in: geometry)
                                                                                    
                                                                                    if let monthDouble:Double = proxy.value(atX: location.x){
                                                                                        let month = Int(round(monthDouble))-2//よくわからんけど2ヶ月ずれる
                                                                                    //if let month: Int = proxy.value(atX: location.x) {
                                                                                        if let data = bookdatacount.first(where: { $0.month == month }) {
                                                                                                                        selectedElement = data.pagesumCount  // ページ数だけ保持
                                                                                                                        selectMonth = month
                                                                                            /*if let yPos = proxy.position(forX: month, y: data.pagesumCount)?.y {
                                                                                                tooltipPosition = CGPoint(x: location.x, y: yPos - 20) // 上に少しずらす
                                                                                                                                            }*/
                                                                                           // if let pos = proxy.position(forX: month, y: data.pagesumCount) {
                                                                                               // let yPos = pos.y
                                                                                               // tooltipPosition = CGPoint(x: location.x, y: yPos - 20) // 上に少しずらす
                                                                                           // }
                                                                                        }//if let data
                                                                                        else{
                                                                                            selectedElement = 0 // ページ数だけ保持
                                                                                            selectMonth = month
                                                                                        }//データがない月に関しての対処
                                                                                        
                                                                                        
                                                                                    }
                                                                                }
                                                                        )
                                                                }
                                                            }
                                            */
                                               
                                        
                                            
                                           .chartOverlay { proxy in GeometryReader { geometry in Rectangle().fill(Color.clear).contentShape(Rectangle())//グラフ描画領域に透明なビューを重ねる
                                               //GeometryReaderでそれを監視するって感じ この時に形を設定しておく必要がある
                                                        .gesture( DragGesture(minimumDistance: 0)//ドラッグでもタップでも反応する
                                                            .onChanged { value in //valueは現在触っている位置　これが変化するたびに呼ばれる
                                                            let location = value.location//現在位置座標(フレーム座標)
                                                            if let monthDouble:Double = proxy.value(atX: location.x)//proxy.value()でグラフで設定した座標に変換
                                                                { let month = Int(round(monthDouble))-1 //よくわからんけど2ヶ月ずれるif let month: Int = proxy.value(atX: location.x){
                                                                if let data = bookdatacount.first(where: { $0.month == month && $0.year == nowyear}) { selectedElement = data.pagesumCount // ページ数だけ保持
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
                                               /* .chartOverlay { proxy in タップだとできない
                                                    GeometryReader { geometry in
                                                        Rectangle()
                                                            .fill(Color.clear)
                                                            .contentShape(Rectangle())
                                                            .gesture(
                                                                TapGesture()
                                                                    .onEnded { gestureValue in
                                                                        let location = gestureValue.location(in: geometry)
                                                                        
                                                                        // proxy.value(atX:) の結果をまず Any? で受ける
                                                                        let rawMonth = proxy.value(atX: location.x)
                                                                        
                                                                        // Int に変換
                                                                        guard let monthDouble = rawMonth as? Double else { return }
                                                                        let month = Int(round(monthDouble))
                                                                        
                                                                        // データ検索
                                                                        if let data = bookdatacount.first(where: { $0.month == month }) {
                                                                            selectedElement = data.pagesumCount
                                                                            selectMonth = month
                                                                        } else {
                                                                            selectedElement = 0
                                                                            selectMonth = month
                                                                        }
                                                                    }
                                                            )
                                                    }
                                                }
                                                */
                                            HStack{
                                                Spacer()
                                                    .frame(width:180)
                                                
                                                if let selected = selectedElement{
                                                    if isTap,1<=selectMonth,selectMonth<=12{
                                                        Text("\(selectMonth)月　:\(selected)ページ")
                                                            .padding()
                                                            .background(.white)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 1)
                                                            .position(tooltipPosition) // タップ位置に表示
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                }
                                            }
                                         
                                        }
                                        
                                    }
                                    
                                    .frame(width: 370, height: 440)
                                    .cornerRadius(20)
                                    
                                    Spacer()
                                        .frame(height: 40)
                                    
                                    ZStack {
                                        
                                        Color.white
                                        
                                        VStack {
                                            HStack{
                                                Spacer()
                                                    .frame(width:40)
                                                
                                            Text("読んだ本のジャンル")
                                            
                                            Picker("",selection: $selectyear3){
                                                
                                                Text("2025").tag(2025)
                                                Text("2026").tag(2026)
                                                Text("2027").tag(2027)
                                                Text("2028").tag(2028)
                                                
                                            }
                                                //Pickerの値が変わるたびに円グラフで表示するためのdictionaryを変える
                                                
                                            .onChange(of: selectyear3){//onchangeに入るたびにdictionaryを初期化しないとダメ　じゃないと残っちゃう
                                               
                                                dictionary = [:]
                                                let bookselectdatas = bookdatas.filter{ $0.year == selectyear3 }
                                                
                                                for book in bookselectdatas{  //全部カウント        Chartの中でごちゃごちゃ描くのはダメなのかな？
                                                    bookcount = bookcount + 1  //何本あるかをカウントできる
                                                 
                                                    if let currentCount = dictionary[
                                                        book.genre]
                                                    {  //ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                                                        dictionary[book.genre] =
                                                        currentCount + 1
                                              
                                                    } else {
                                                        dictionary[book.genre] = 1
                                      
                                                    }  //varはviewに変更があった場合再描画されるんだけどその度に値がリセットされてしまう　stateつけた変数は変わったらview全体を更新する力を持ってる
                                                    //viewに直接影響を与えるものに関してはStateが良い 今回はcountもdictionaryもviewにゴリゴリ与えるからStateが良い
                                                    //正直難しい
                                                }
                                            }
                                                
                                                Spacer()
                                            }
                                            Chart {  //つまり最低限だとidさえ設定しておけばあとはkey,value　これがあれば同じように使える それをいうならdictionaryがidentifiableに準拠していないとリストも同様
                                                ForEach(
                                                    dictionary.sorted(by: {
                                                        $0.key < $1.key
                                                    }), id: \.key
                                                ) { key, value in  //dictionaryが普通のリストじゃないからちょっと工夫
                                                    SectorMark(  //keyはジャンル名　valueは数  棒だとbarmark
                                                        angle: .value(
                                                            "Count",
                                                            value * 100 / bookcount),  //これを円グラフを構成するcountとして使うよっていう意味のvalue
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
                                                        / Double(bookcount)
                                                        * 100
                                                        
                                                        Text(
                                                            String(
                                                                format:
                                                                    "%.0f%%",
                                                                persent))  //その上に重ねるのがoverlay
                                                    }
                                                }
                                            }
                                            .frame(width: 300, height: 350)
                                        }
                                        .frame(width: 300, height: 380)
                                    }
                                    .frame(width: 350, height: 420)
                                    .cornerRadius(20)
                                }
                                
                            }
                            
                        } else {//検索状態
                            VStack{
                                List {
                                    
                                    ForEach(bookdatalist.bookitems) { book in
                                        NavigationLink(
                                            destination: readRegister(
                                                selectbook: book)
                                        ) {  //選択した本のデータを引き渡す
                                            
                                            HStack {
                                                Spacer()
                                                    .frame(width: 30)
                                                VStack{
                                                    if isAlreadyRegistered(book: book){//LIstビューも要素が少しでも変わったら再描画される
                                                        //realmデータベースに検索したアイテムのタイトルが入っていたら登録済みにしてやる
                                                        
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
                                                                //}
                                                            }
                                                        //hantei = false//判定が変わる　どっちやねんってswiftuiは思うわけかな？　view構築中に判定を変えるな
                                                    }//.onAppearとかは構築後だからいける
                                                        
                                                    
                                                    
                                                    
                                                    Text(book.title)
                                                        .frame(
                                                            width: 270, height: 100)
                                                }
                                                
                                                Spacer()  //AsyncImageをつけないとメインスレッド更新
                                                //故に画像を撮ってきている間に画面がフリーズする
                                      
                                                    .frame(width: 30)
                                                
                                                AsyncImage(
                                                    url: book.smallThumbnail
                                                ) { image in
                                                    image  //httpsじゃないと許してもらえない
                                                        .resizable()
                                                        .frame(
                                                            width: 80,
                                                            height: 90)
                                                    
                                                } placeholder: {
                                                    ProgressView()  //非同期で動かしている間画面のインジゲータ
                                                }//Async画像
                                                
                                            }//HStack
                                        }//Navigation
                                        
                                    }//Foreach
                                    HStack {
                                        Spacer()
                                            .frame(width: 100)
                                        Button("次の10件") {  //次の10件を推したらurlにcount属性追加したやつに切り替える　それで検索をかけるんだけど前のやつは消える
                                            counter += 10
                                            bookdatalist.searchBooks(
                                                keyword: searchword,
                                                count: counter, bool: bool)
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
                                    .frame(width:90,height:50)
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
        
    

    
    func isAlreadyRegistered(book: BookItem) -> Bool {
        let realm = try? Realm()
        return realm?.objects(BookData.self).contains(where: { $0.title == book.title }) ?? false
    }
        
    }

//}


extension View {
    func hideKeyboard4() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }  //UIApplicationアプリ全体の管理を行うみんなのお父さんsharedはそのインスタンス
}  //FirstResponderは現在フォーカスが当てられている部品のこと　それを否定　resignすることでそらす　sendActionはUIkitの持っているメソッド 指定アクションをfromさんからtoさんに送信
 


//使われている技術

/*
 1 ネット画像の表示
 ネットとかで撮ってきたり作った画像をAssets.xcassetsの中に入れる -> それをImage(.名前)で指定するだけで表示できます
 
 2 Pickerの使い方
 Picker(selection:){Text().tag() Text().tag()} 選択された部品のtagの中身がselectionで指定された変数にセットされる なんで$なのかは忘れた
 
 Pickerがstructの中に外のstructを入れる時みたいに隔離？されているから中と外とで値を連動させるために$してるんじゃない？　Binding的な
 
 3 自分で入力するのは
 
 TextEditor 長文用
 TextEditor(text:$z)
 
 
 TextField 一文 入力する前の薄文字が簡単に設定できる
 TextField("xyz" , text:$z) これも隔離されているから連動させるために$をつける
 .disabled(selectcondition=="検索条件") これを設定することで中の条件がtrueにならない限りはTextFieldを使えなくする
 .submitLabel(.search)はキーボードの右下のボタンを何にするか変える
 
 4 NavigationLink{} この中のアイテムは全てボタン扱いになる
 
 5 realmデータベースの使い方
 
 1 追加 realm.write addなど
   含まれているか realm.objects(観測構造体.self).contains(where:{})
   削除  realm.write{この中でrealm.delete(object)してやる}
 
 6 URLでネットの画像を非同期に取ってくる
 AsyncImage(url:) 引数 in{
 
 }
 placeholder:{ProgressView()}
 
 Imageはxcassetにある画像を取ってくる
 
 
 7 グラフの使用
1 外で構造体なりrealmなどIdentifiable準拠の配列を用意して
 
2 Charts{
  ForEach(1.){引数 in
  なんとかMark( BarMarksは棒グラフ, LineMarksは折れ線グラフ,SectorMarksは円グラフ
    x: .value("", 変数),
    y: .value("",変数) (円グラフは別) xとyを指定した変数で各々プロットしていく
 )
 
 }
 
 }
 
 ここまでが基本
 
 .chartXAxis {AxisMarks(position:,values:[1,2,3,])} positionはラベルの値を表示する位置 valuesはラベルの値 デフォルトでは良くも悪くも自動調整されてしまう
 .chartYAxis {} でx軸,y軸の軸の値を指定したりする
 .chartXAxisLabel("月") 軸のラベルを設定
 
 結構応用
 /グラフの中でタップした位置のx座標とそこでの値を表示する
 
 .chartoverlay{
 
 }
 1 透明なビューを重ねる
 2 コントローラーを作る (座標 <-> グラフ)
 3 透明なビューの形を決める
 4 .gesture{.onChangedでタップなどの変化のたびに起動}
 5 座標を取得したりproxyでグラフ座標に対応したりしてそこをkeyとしてvalueを取り出したりする
 
 8 現在の日付の取得
 
 let currentDate = Date()
 ここで手に入れた情報を
 let calendar = Calendar.current  //ユーザの地域情報を加味した計算ツール
 
 こいつ使って
 let month = calendar.component(
     .month, from: currentDate)  //月を取り出してくれるツール
 
 必要なものを取り出す
 
 
 9 アプリ全体でよく使っていたのが、検索とかでフォーカスされた部品の
 フォーカスを戻すために
 extention View{
 func (){
 UIApplication.shared.sendAction()
 }
 }
 を使っていた　これを実際にビューに.onTapgestureつけて起動させる
 */
