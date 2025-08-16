//
//  ReadDatamovie.swift

import SwiftUI //ReadDataと比較してapikeyを埋め込んでいる点　取ってくる情報の型が異なるだけ

//4つとも欲しいフィールドとか結構違ったりするから別々に作ろうかな
struct Movieitem: Identifiable {  //IdentifiableにすることでListやforeachでデータを使用できるようになる
    let id = UUID()  //別になくてもできるけどself.idなどで代用するとたとえばListの中身が変化したらダメだし基本型しか使えないとかになる
    let title: String
    let releaseDate: String
    let overview: String
    let posterLink: URL

}

@Observable class ReadDatamovie {  //Observableマクロはこのクラスのプロパティなどはいちいちインスタンスかしなくても変化を追跡できるように

    struct ResultJson2: Codable {  //Jsonとして帰ってきた時にパコパコ勝手に嵌め込めるように

       
            struct result: Codable{
                let original_title: String?  //つまり複数要素があるならそれを構造体かして階層化する必要がある
                let overview: String?
                let poster_path: URL?
                let release_date: String?
            }
            let results:[result]?

    }

    var Movieitems: [Movieitem] = []  //varであるのは中身が検索のたびに変わるから
    //検索のたびにインスタンスかするなら初期代入で良いけど今回はそうではない
    func searchMovies(keyword: String) {

        Task {  //非同期空間を生成
            await searchm(keyword: keyword)  //こいつが非同期スレッドで終わってからTaskの中のその後の動作を行うけどmainはその間も他ごとはやれる
            //確実に待つことを保証しているだけ
            print("\(keyword)です")
        }
    }
    @MainActor  //クラス変数を変更するとその値に応じてuiの状態が変わるからuiviewと密接に結びつくんだよ　だからmainスレッドで行わなくてはならない
    private func searchm(keyword: String) async {  //非同期が処理するメソッド
        //この段階ではメインスレッドが動かす
        guard
            let keyword_encode = keyword.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed)  //キーワードのエンコード
        else {
            return
        }
        guard
            let req_url = URL(
                string:
                    "https://api.themoviedb.org/3/search/movie?api_key=8e6fc8313337df8adbddf09fd6acce7d&&language=ja-JP&query=\(keyword_encode)"
            )//本来apikey隠した方が良いかも　サーバに情報が残るのはまずい
        else {  //relevanceはデフォルトの検索結果順　maxは個数オプション
            return
        }
        print(req_url)

        do {
            //ここでメインスレッドが開放されている これが結局時間かかるんだよ ui更新と関係ないし
            let (data, _) = try await URLSession.shared.data(from: req_url)  //URLseddion自体が非同期メソッドasyncであり、非同期さんが終わるまで待っている
            //_にはsessionの通信状態などが入っている
            let decoder = JSONDecoder()  //デコードするためのメソッド

            let json = try decoder.decode(ResultJson2.self, from: data)  //json　getだぜ　しかもResult形式に合わせて入っている
            //ResultJsonのこと
            //print(json)
            guard let mitems = json.results  //mitemsは一旦帰ってきたjsondata
            else {
                return
            }

            Movieitems.removeAll()  //検索かけたら前の結果は初期化

            //更新　箱に詰め合わせる間はバックグランドは寝るしかないしuiview更新中と同義だから他ごとはできない
            for mitem in mitems {
                if let title = mitem.original_title,
                   let releaseDate = mitem.release_date,
                   let overview = mitem.overview,
                   let posterLink = mitem.poster_path
                {
                    //posterLinkは完全な画像パスではないから完全にする
                    let imageUrlString = posterLink.absoluteString//Stringに変換
                    let fullimagePath = "https://image.tmdb.org/t/p/w500/"+imageUrlString
                    
                    if let fullURLImage = URL(string:fullimagePath){//またURLに戻す{ URL型の初期は空を許すから使う時はアンラップ
                        print(fullURLImage)
                        let movieitem = Movieitem(
                            title: title,
                            releaseDate: releaseDate,
                            overview: overview,
                            posterLink: fullURLImage
                        )
                        Movieitems.append(movieitem)
                    }
                }
            }
                    
                
            

            print(Movieitems)
        } catch {
            print("エラー")
        }
    }
}
