import Charts
import RealmSwift
import SwiftUI

struct ReadImpress: View {
    @ObservedResults(BookData.self) var bookdatas  //bookデータベース
    @ObservedResults(BookDataCount.self) var bookdatacount

    @State var dictionary: [String: Int] = [:]  //hashmap的なやつ Dictionary型
    @State var count = 0  //ジャンル円グラフを作るため

    @State var bookcount = 0
    
    @State var ismainNavigation = false  //4つのフラグで4画面をメインから制御
    @State var isreadNavigation = false
    @State var ismovieNavigation = false
    @State var isanimeNavigation = false
    @State var isdoramaNavigation = false

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
                destination: EigaImpress(), isActive: $ismovieNavigation
            ) {

            }
            NavigationLink(
                destination: AnimeImpress(), isActive: $isanimeNavigation
            ) {

            }
            NavigationLink(
                destination: DramaImpress(), isActive: $isdoramaNavigation
            ) {

            }

            NavigationLink(
                destination: ReadImpress(), isActive: $isreadNavigation
            ) {

            }
            NavigationLink(destination: Readbooklist(), isActive: $islistActive)
            {}

            NavigationLink(destination: readGraph(), isActive: $isgraphActive) {
            }  //グラフ確認画面へレッツゴー

            
            NavigationLink(destination:Toukou(), isActive: $istoukouActive) {
            }
            
            ZStack {
                Image(.readbackground)
                    .resizable()
                    .ignoresSafeArea()
                    .onTapGesture {  //それがここ　タップした時の反応　これって部品全部に持ってるのかな
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
                        Picker(selection: $selectcondition) {  //何で$使うんだっけ？？？？？？
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
                            bookdatalist.searchBooks(
                                keyword: searchword, count: counter, bool: bool)
                            
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
                                                .chartYAxisLabel("冊数")  // Y軸のラベルを追加
                                            
                                            
                                                /*.chartOverlay { proxy in GeometryReader { geometry in Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                             .gesture( DragGesture(minimumDistance: 0) .onChanged { value in
                                                                 let location = value.location
                                                                 if let monthDouble:Double = proxy.value(atX: location.x){ let month = Int(round(monthDouble))-2 //よくわからんけど2ヶ月ずれるif let month: Int = proxy.value(atX: location.x){
                                                                     if let data = bookdatacount.first(where: { $0.month == month }) { selectedElement = data.pagesumCount // ページ数だけ保持
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
                                                     }*/
                                            
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
                                               
                                        
                                            
                                           .chartOverlay { proxy in GeometryReader { geometry in Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                        .gesture( DragGesture(minimumDistance: 0) .onChanged { value in
                                                            let location = value.location
                                                            if let monthDouble:Double = proxy.value(atX: location.x){ let month = Int(round(monthDouble))-1 //よくわからんけど2ヶ月ずれるif let month: Int = proxy.value(atX: location.x){
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
                                            .onChange(of: selectyear3){//onchangeに入るたびにdictionaryを初期化しないとダメ　じゃないと残っちゃう
                                                print("ghaphfaihfeowaihfaweihfpoahwiofihapw")
                                                dictionary = [:]
                                                let bookselectdatas = bookdatas.filter{ $0.year == selectyear3 }
                                                print(bookselectdatas)
                                                for book in bookselectdatas{  //全部カウント        Chartの中でごちゃごちゃ描くのはダメなのかな？
                                                    bookcount = bookcount + 1  //何本あるかをカウントできる
                                                    print(bookcount)
                                                    if let currentCount = dictionary[
                                                        book.genre]
                                                    {  //ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                                                        dictionary[book.genre] =
                                                        currentCount + 1
                                                        print(currentCount)
                                                    } else {
                                                        dictionary[book.genre] = 1
                                                        print("0")
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
                            
                        } else {
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
                                                    if isAlreadyRegistered(book: book){//LIstビューも要素が少しでも変わったら再描画される falseになって表示しないってなったら早速戻って全体が更新されるつまり全体がfalseのまま更新されるmのかな //hanteiっていう一つの状態変数を使っているとswiftuiはビューごとに状態変数で監視すべきだし思った以上に再描画しまくっているから仮に初めtrueでもtrueじゃないやつにぶち当たって　つまりそんな共通の変数一つで管理できるほどリストというか器用じゃない
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
                                                
                                                AsyncImage(
                                                    url: book.smallThumbnail
                                                ) { image in
                                                    image  //httpsじゃないと許してもらえない
                                                        .resizable()
                                                        .frame(
                                                            width: 80,
                                                            height: 90)
                                                    
                                                    //画面をスクロールして画面外にimageが出た時にまた戻して画像を表示させるのに再読み込みする必要があるのがうざい
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
 
