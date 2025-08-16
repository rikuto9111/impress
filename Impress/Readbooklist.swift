import RealmSwift
import SwiftUI
import FirebaseFirestore

struct Readbooklist: View {
    @ObservedResults(BookData.self) var bookdatas
    @ObservedResults(BookDataCount.self) var bookdataCount
    @Environment(\.presentationMode) var presentationMode
    @State var channel = ""
    @State var showDialog = false //リスト表示するための画面を表示させるか否か
    @State var bookdatalists:[BookData] = []
    
    @State var nowmonth = 0
    @State var ismistery = true //ボタンチェックのためだけにある
    @State var isSF = true
    @State var isfantacy = true
    @State var issyakai = true
    @State var iskyouyou = true
    @State var isbusiness = true
    @State var isrikou = true
    @State var isjidousho = true
    @State var issonota = true
    
    @State var customColor: Color = Color.red
    
    var list:[String] = ["ミステリー","SF","ファンタジー","社会小説","教養","ビジネス","理工系","児童書","その他"]//Text("ミステリー")//表面上見えてるもの
    
    var body: some View {
        
        ZStack {

                
            //Image(.readbackground)
                //.resizable()
            Color(red:0.75,green: 1.0,blue:0.5,opacity: 0.5)
                .ignoresSafeArea()
            
            NavigationStack {
                
                VStack{
                    Text("読んだ本リスト")
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
                    
                    .onAppear(){
                        bookdatalists = Array(bookdatas)
                        
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
                        
                        Color(red:0.75,green: 1.0,blue:0.5,opacity: 0.7)
                        
                        List {
                            ForEach(bookdatalists) { book in
                                NavigationLink(
                                    destination: Bookdetails(
                                        title: book.title,
                                        image: book.Image,
                                        pagenumber: book.pageCount,
                                        overview: book.overview,
                                        Impression: book.Impression,
                                        evaluate: book.evaluate,
                                        genre:book.genre)
                                ) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                                .frame(width:10)
                                            
                                            Text(book.genre)
                                                .frame(width:115,height:40)
                                                .background(changebackcolor(genre: book.genre))
                                                .cornerRadius(20)
                                            
                                            Spacer()
                                                .frame(width: 20)
                                            
                                            Text(book.title)
                                                .frame(width:160)//defaultで文字が長すぎるとviewの中に収めようとして...や下に逃がそうとする
                                            Spacer()
                                                .frame(width:40)
                                            //Text("\(book.pageCount)ページ")
                                        }
                                        
                                        .frame(height: 50)
                                        
                                        HStack {
                                            Spacer()
                                                .frame(width:30)
                                            
                                            if let req_url = URL(string: book.Image) {
                                                AsyncImage(url: req_url) { image in
                                                    image
                                                        .resizable()
                                                        .frame(width: 80, height: 80)
                                                } placeholder: {
                                                    ProgressView()  //非同期で動かしている間画面のインジゲータ
                                                }
                                            }
                                            
                                            Spacer()
                                                .frame(width:25)
                                            
                                            Text(book.overview)
                                                .frame(width: 220, height: 150)
                                            Spacer()
                                                .frame(width:20)
                                            
                                            
                                        }
                                        
                                    }//VStack
                                    
                                }//NavigationLinl
                            }//Foreach
                            .onDelete(perform: deleteBook)
                            
                        }//List
                        .scrollContentBackground(.hidden)  //なんか背景色つかねえなと思ってたらリストの初期色に上書きされていたわ
                        .navigationBarBackButtonHidden(true)  //デフォルトのbackボタンを隠す
                        
                        
                        if showDialog {
                            Color.black.opacity(0.4) // 背景の暗転
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    showDialog = false // 背景タップでダイアログを閉じる
                                }
                            
                            CustomDialog(
                                list: list,
                                ismistery:$ismistery,//ボタンチェックのためだけにある
                                isSF:$isSF,
                                isfantacy:$isfantacy,
                                issyakai:$issyakai,
                                iskyouyou:$iskyouyou,
                                isbusiness:$isbusiness,
                                isrikou:$isrikou,
                                isjidousho:$isjidousho,
                                issonota:$issonota,
                                
                                showDialog: $showDialog,
                                onSave: {
                                    
                                    
                                    let selectedGenres: [String] = {
                                        var genres = [String]()
                                        if ismistery { genres.append("ミステリー") }
                                        if isSF { genres.append("SF") }
                                        if isfantacy { genres.append("ファンタジー") }
                                        if issyakai { genres.append("社会小説") }
                                        if iskyouyou { genres.append("教養") }
                                        if isbusiness { genres.append("ビジネス") }
                                        if isrikou { genres.append("理工系") }
                                        if isjidousho { genres.append("児童書") }
                                        if issonota   { genres.append("その他") }
                                        
                                        return genres
                                    }()
                                    bookdatalists = selectBook2(channel:selectedGenres)
                                    
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
                    .background(EnableSwipeBackGesture()) // ←ここを追加
                }
            }
        }
    }
    private func selectBook(channel: String) -> [BookData] {  //本の場合はページ数も減らしておく
        do {
            let realm = try Realm()
            let selectbookdata = realm.objects(BookData.self).filter("genre == %@",channel)
            
            //print(selectbookdata)
            
            return Array(selectbookdata)
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
            return []
        }
    }
    private func selectBook2(channel: [String]) -> [BookData] {  //本の場合はページ数も減らしておく
        do {
            let realm = try Realm()
            let selectbookdata = realm.objects(BookData.self).filter("genre IN %@",channel)
            
            //print(selectbookdata)
            
            return Array(selectbookdata)
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
            return []
        }
    }
    
    
    
    private func deleteCountbook(pageCount: Int,month:Int) {  //本の場合はページ数も減らしておく
        /*let currentDate = Date()
        let calendar = Calendar.current  //ユーザの地域情報を加味した計算ツール
        
        let month = calendar.component(
            .month, from: currentDate)  //月を取り出してくれるツール
        
        nowmonth = month*/
        
        do {
            let realm = try Realm()
            try realm.write {
                if let bookCount = realm.objects(BookDataCount.self).filter("month == %@", month).first {  //存在する場合とそうでない場合
                    bookCount.number -= 1
                    bookCount.pagesumCount -= pageCount
                    realm.add(bookCount)
                }
            }
            
        } catch {
            print("Error adding task: \(error.localizedDescription)")
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
        if genre == "社会小説"{
            let selectcolor =
            Color(red:0.4,green:0.6,blue:0.9,opacity:0.9)
            return selectcolor
        }
        if genre == "教養"{
            let selectcolor =
            Color(red:0.5,green:0.8,blue:0.82,opacity:0.5)
            return selectcolor
        }
        if genre == "ビジネス"{
            let selectcolor =
            Color(red:0.4,green:0.6,blue:0.9,opacity:0.5)
            return selectcolor
        }
        if genre == "理工系"{
            let selectcolor =
            Color(red:0.8,green:0.9,blue:0.2,opacity:0.5)
            return selectcolor
        }
        if genre == "児童書"{
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
    
   
    
    

    
    private func deleteBook(at offsets: IndexSet) {  //スワイプした番号をリストから教えてもらった
        
        do{
            let realm = try Realm()
            
            for index in offsets {
                let filteredBook = bookdatalists[index]  // 表示中のリストから対象を取得
                print(type(of:filteredBook))
               print(index)
                deleteCountbook(pageCount:filteredBook.pageCount,month:filteredBook.month)//Countデータベースの値も減らしておく
                // id からライブな Realm オブジェクトを取得（Frozen を避ける）
                if let liveBook = realm.object(ofType: BookData.self, forPrimaryKey: filteredBook.id) {
                    print(liveBook)
                    print(type(of:liveBook))
                    try realm.write {
                        realm.delete(liveBook)
                    }
                   
                }
                else{
                    print("うんこ")
                }
                print(offsets)
                
                let selectedGenres: [String] = {
                    var genres = [String]()
                    if ismistery { genres.append("ミステリー") }
                    if isSF { genres.append("SF") }
                    if isfantacy { genres.append("ファンタジー") }
                    if issyakai { genres.append("社会小説") }
                    if iskyouyou { genres.append("教養") }
                    if isbusiness { genres.append("ビジネス") }
                    if isrikou { genres.append("理工系") }
                    if isjidousho { genres.append("児童書") }
                    if issonota   { genres.append("その他") }
                    
                    return genres
                }()
                bookdatalists = selectBook2(channel:selectedGenres)
                
                //$bookdatas.remove(book)  // Realm のデータを削除
                
            }
                
            }//さっきまでのエラーは画面上で矛盾が起きていたから画面には残っている当たり前消してもリストには残っていたから
        
        catch{}
        
    }//選択しているところで消したらそこの中で消してやる画面を再描画するつもりででもそのタイミングをStateとかに任せられるかって話でもそうはいっても冗長な気がする
}


struct EnableSwipeBackGesture: UIViewControllerRepresentable {//UIViewControllerは監督
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


struct CustomDialog: View {//こいつを呼び出すだけでviewを表示するんだね

    var list: [String]
    
    @Binding var ismistery: Bool
    @Binding var isSF :  Bool
    @Binding var isfantacy: Bool
    @Binding var issyakai : Bool
    @Binding var iskyouyou: Bool
    @Binding var isbusiness: Bool
    @Binding var isrikou   : Bool
    @Binding var isjidousho   : Bool
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
                        issyakai = true
                        iskyouyou = true
                        isbusiness = true
                        isrikou = true
                        isjidousho = true
                        issonota = true
                    }
                    Button("reset"){
                        ismistery = false
                        isSF = false
                        isfantacy = false
                        issyakai = false
                        iskyouyou = false
                        isbusiness = false
                        isrikou = false
                        isjidousho = false
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
                                else if item == "社会小説"{
                                    issyakai.toggle()
                                }
                                else if item == "教養"{
                                    iskyouyou.toggle()
                                }
                                else if item == "ビジネス"{
                                    isbusiness.toggle()
                                }
                                else if item == "理工系"{
                                    isrikou.toggle()
                                }
                                else if item == "児童書"{
                                    isjidousho.toggle()
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
        case "社会小説": return issyakai
        case "教養": return iskyouyou
        case "ビジネス": return isbusiness
        case "理工系": return isrikou
        case "児童書": return isjidousho
        case "その他": return issonota
        default: return false
        }
    }
}
