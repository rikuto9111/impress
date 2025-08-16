
import SwiftUI
//4つとも欲しいフィールドとか結構違ったりするから別々に作ろうかな
struct AnimeItem : Identifiable{//IdentifiableにすることでListやforeachでデータを使用できるようになる
    let id = UUID()//別になくてもできるけどself.idなどで代用するとたとえばListの中身が変化したらダメだし基本型しか使えないとかになる
    let title:String
    //let infoLink :String
    let image:URL
    let During:String
    //let episodes:Int = 0
    let overview:String
    let keyid: Int
}

@Observable class ReadAnimeData{//Observableマクロはこのクラスのプロパティなどはいちいちインスタンスかしなくても変化を追跡できるように @Observable
    
    struct ResultAnimeJson: Codable {  //Jsonとして帰ってきた時にパコパコ勝手に嵌め込めるように

       
            struct result: Codable{
                let name: String?  //つまり複数要素があるならそれを構造体かして階層化する必要がある
                let overview: String?
                let poster_path: URL?
                let first_air_date: String?
                let id: Int?
            }
            let results:[result]?

    }
    
    struct ResultAnimeJson2: Codable{
       
        let episode_number:Int?
        
    }
    
    
    
     var animeitems:[AnimeItem] = []//varであるのは中身が検索のたびに変わるから
    let episode_n:Int = 0
    
    var keyid:Int = 0
    
    //検索のたびにインスタンスかするなら初期代入で良いけど今回はそうではない
    func searchAnimes(keyword:String,count:Int){
        
        Task{//非同期空間を生成 この中の処理は時間がかかるかもしれないかもしれないかもしれないかもしれないと明記する　すぐに帰ってこなくてもしょうがないよねだから待ったりしなければいけないかもと明記 時間がとてもかかるなら
            //バックグラウンドスレッドが必要に応じて動くかも つまりスレッドを起動するわけではない
            
            await search(keyword: keyword,count: count)//こいつが非同期スレッドで終わってからTaskの中のその後の動作を行うけどmainはその間も他ごとはやれる
            //確実に待つことを保証しているだけ
            //await searchepisode(id:keyid)
            print("\(keyword)です")//awaitがなかったらこいつがすぐに実行される
            print(animeitems)
        }//まずは非同期スレッドの非同期メソッドが終わったら確実に連絡をもらうようにする
    }//asyncメソッドは時間かかるから普通はメソッドにかけたらコンパイルエラーじゃない限りは止まることは少ないが、asyncだと中断する可能性がある　読み込み中に他ページを読み込むとか
    //今から特別な非同期メソッドを裏で動かすよと明記 asyncは時間かかるかもしれないよこの処理はつまりすぐに結果を返すわけではないよメソッド
    
    @MainActor
    private func searchepisode(id:Int) async{
        var url :URL?
        guard let requrl = URL(string:"https://api.themoviedb.org/3/tv/\(id)?api_key=8e6fc8313337df8adbddf09fd6acce7d&language=ja-JP") else{return}
        url = requrl
        
        if let url = url{//入ってんのか入ってないのかっていう状態をなくす
            do{
                //ここでメインスレッドが開放されている これが結局時間かかるんだよ ui更新と関係ないし
                let (data, _) = try await URLSession.shared.data(from: url)//URLseddion自体が非同期メソッドasyncであり、非同期さんが終わるまで待っている
                //_にはsessionの通信状態などが入っている
                let decoder = JSONDecoder()//デコードするためのメソッド
                
                let json = try decoder.decode(ResultAnimeJson2.self, from: data)//json　getだぜ　しかもResult形式に合わせて入っている
                //ResultJsonのこと
                print(json)
                guard let items = json.episode_number//
                else{
                    return
                }
            }catch{print("う")}
            
           // episode//検索メソッドを起動したらかけたら前の結果は初期化
            
        }
    }
    
    @MainActor//クラス変数を変更するとその値に応じてuiの状態が変わるからuiviewと密接に結びつくんだよ　だからmainスレッドで行わなくてはならない
    private func search(keyword: String,count: Int) async{//非同期が処理するメソッド つまりasyncでは
        //この段階ではメインスレッドが動かす
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)//キーワードのエンコード
        else{
            return
        }
        
        var Nowurl:URL?
        
        if count == 1 {//初期検索かそうでないかの場合わけ またこれは作品名検索
            guard let req_url = URL(string:"https://api.themoviedb.org/3/search/tv?api_key=8e6fc8313337df8adbddf09fd6acce7d&query=\(keyword_encode)&language=ja-JP")
            else{//relevanceはデフォルトの検索結果順　maxは個数オプション
                return
            }
            
            Nowurl = req_url
            
        }
    
        else if count != 1 {//初期検索かそうでないかの場合わけ またこれは書籍検索
            guard let req_url3 = URL(string:"https://api.themoviedb.org/3/search/tv?api_key=8e6fc8313337df8adbddf09fd6acce7d&query=\(keyword_encode)&language=ja-JP&page=1")
            else{//relevanceはデフォルトの検索結果順　maxは個数オプション
                return
            }
            
            Nowurl = req_url3
            
        }
        
       
        
        //print(keyword_encode)
        
        print(Nowurl)
        
        if let url = Nowurl{//入ってんのか入ってないのかっていう状態をなくす
            do{
                //ここでメインスレッドが開放されている これが結局時間かかるんだよ ui更新と関係ないし
                let (data, _) = try await URLSession.shared.data(from: url)//URLseddion自体が非同期メソッドasyncであり、非同期さんが終わるまで待っている
                //_にはsessionの通信状態などが入っている
                let decoder = JSONDecoder()//デコードするためのメソッド
                
                let json = try decoder.decode(ResultAnimeJson.self, from: data)//json　getだぜ　しかもResult形式に合わせて入っている
                //ResultJsonのこと
                print(json)
                guard let items = json.results//
                else{
                    return
                }
                
                animeitems.removeAll()//検索メソッドを起動したらかけたら前の結果は初期化
                
                //更新　箱に詰め合わせる間はバックグランドは寝るしかないしuiview更新中と同義だから他ごとはできない
                for item in items{
                    if let images = item.poster_path,let title = item.name,let overview = item.overview,let fdate = item.first_air_date,let id = item.id{
                    
                        keyid = id
                                /*let imageUrlString = smallThumbnail1.absoluteString//Stringに変換
                                
                                let secureImageUrl = imageUrlString.replacingOccurrences(of: "http://", with: "https://")//Stringの中にある
                                //"http://をhttpsに変えるよ"
                                
                                if let smallThumbnail = URL(string:secureImageUrl){//またURLに戻す{ URL型の初期は空を許すから使う時はアンラップ*/
                        
                                    
                        let animeitem = AnimeItem(title: title,image: images, During: fdate,overview: overview,keyid:id)
                                    animeitems.append(animeitem)
                                }
                            }
                                

                
                //print(bookitems)
            }catch{
                print("エラー")
            }
        }
    }
}

