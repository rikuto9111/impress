//
//  ReadData.swift
//  Impress
//
//  Created by user on 2025/03/06.
//

import SwiftUI
//4つとも欲しいフィールドとか結構違ったりするから別々に作ろうかな
struct BookItem : Identifiable{//IdentifiableにすることでListやforeachでデータを使用できるようになる
    let id = UUID()//別になくてもできるけどself.idなどで代用するとたとえばListの中身が変化したらダメだし基本型しか使えないとかになる
    let title:String
    let authors:[String]
    let pageCount:Int
    let infoLink :String
    let smallThumbnail:URL
    let overview:String
}

@Observable class ReadData{//Observableマクロはこのクラスのプロパティなどはいちいちインスタンスかしなくても変化を追跡できるように @Observable
    
    struct ResultJson: Codable{//Jsonとして帰ってきた時にパコパコ勝手に嵌め込めるように
        
        struct Item:Codable{//うまくjson形式の構造を反映させる必要があって
            struct VolumeInfo:Codable{//itemの中のvolumeinfoの中のImagelinksの中のだったらそれを全て反映させる必要がある
                let title:String?//つまり複数要素があるならそれを構造体かして階層化する必要がある
                let authors:[String]?
                let description:String?//あらすじ
                let pageCount:Int?
                let infoLink:String?
                
                struct ImageLinks:Codable{
                    let smallThumbnail:URL?
                }
                let imageLinks:ImageLinks?
            }
            let volumeInfo:VolumeInfo?
        }
        let items:[Item]?//複数要素
    }
    
    
     var bookitems:[BookItem] = []//varであるのは中身が検索のたびに変わるから
    //検索のたびにインスタンスかするなら初期代入で良いけど今回はそうではない
    func searchBooks(keyword:String,count:Int,bool: Bool){
        
        Task{//非同期空間を生成
            await search(keyword: keyword,count: count,bool: bool)//こいつが非同期スレッドで終わってからTaskの中のその後の動作を行うけどmainはその間も他ごとはやれる
            //確実に待つことを保証しているだけ
            print("\(keyword)です")//awaitがなかったらこいつがすぐに実行される
            //print(bookitems)
        }//まずは非同期スレッドの非同期メソッドが終わったら確実に連絡をもらうようにする
    }//asyncメソッドは時間かかるから普通はメソッドにかけたらコンパイルエラーじゃない限りは止まることは少ないが、asyncだと中断する可能性がある　読み込み中に他ページを読み込むとか
    //今から特別な非同期メソッドを裏で動かすよと明記 asyncはスレッド跨いだ処理
    
    @MainActor//クラス変数を変更するとその値に応じてuiの状態が変わるからuiviewと密接に結びつくんだよ　だからmainスレッドで行わなくてはならない
    private func search(keyword: String,count: Int,bool: Bool) async{//非同期が処理するメソッド
        //この段階ではメインスレッドが動かす
        guard let keyword_encode = "\"\(keyword)\"".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)//キーワードのエンコード ここで""を入れる
        else{
            return//"q"とqで検索結果が異なり"q"の方が厳密
        }
        
        var Nowurl:URL?
        
        if count == 0 && bool == false{//初期検索かそうでないかの場合わけ またこれは書籍検索
            guard let req_url = URL(string:"https://www.googleapis.com/books/v1/volumes?q=\(keyword_encode)&max=10&order=relevance")//この中に直接q = "\(keyword)"みたいにはできないってことこれだとq = "3621987634286" みたいになるけど実際にはq = %22 2402987403 %22みたいにしなければならないってこと つまり""をエンコード
            else{//relevanceはデフォルトの検索結果順　maxは個数オプション
                return
            }
            print(req_url)
            
            Nowurl = req_url
            
        }
        else if count == 0 && bool == true{//初期検索かそうでないかの場合わけ またこれは作者検索
            guard let req_url2 = URL(string:"https://www.googleapis.com/books/v1/volumes?q=inauthor:\(keyword_encode)")
            else{//relevanceはデフォルトの検索結果順　maxは個数オプション
                return
            }
            
            Nowurl = req_url2
            
        }
        else if count != 0 && bool == false{//初期検索かそうでないかの場合わけ またこれは書籍検索
            guard let req_url3 = URL(string:"https://www.googleapis.com/books/v1/volumes?q=\(keyword_encode)&max=10&startIndex=\(count)&order=relevance")
            else{//relevanceはデフォルトの検索結果順　maxは個数オプション
                return
            }
            
            Nowurl = req_url3
            
        }
        
        else{//それがこれ//作者検索
            guard let req_url4 = URL(string:"https://www.googleapis.com/books/v1/volumes?q=inauthor:\(keyword_encode)&max=10&startIndex=\(count)&order=relevance")
            else{//relevanceはデフォルトの検索結果順　maxは個数オプション
                return
            }
            
            Nowurl = req_url4
            
        }
        
        //print(keyword_encode)
        
        //print(Nowurl)
        
        if let url = Nowurl{//入ってんのか入ってないのかっていう状態をなくす
            do{
                //ここでメインスレッドが開放されている これが結局時間かかるんだよ ui更新と関係ないし
                let (data, _) = try await URLSession.shared.data(from: url)//URLseddion自体が非同期メソッドasyncであり、非同期さんが終わるまで待っている
                //_にはsessionの通信状態などが入っている
                let decoder = JSONDecoder()//デコードするためのメソッド
                
                let json = try decoder.decode(ResultJson.self, from: data)//json　getだぜ　しかもResult形式に合わせて入っている
                //ResultJsonのこと
                //print(json)
                guard let items = json.items//
                else{
                    return
                }
                
                bookitems.removeAll()//検索メソッドを起動したらかけたら前の結果は初期化
                
                //更新　箱に詰め合わせる間はバックグランドは寝るしかないしuiview更新中と同義だから他ごとはできない
                for item in items{//完璧にアンラップされないと本が登録されないからだから10件もないことがあった
                    if let volumeinfo = item.volumeInfo{
                        //if let title = volumeinfo.title ?? "タイトル不明",
                           //let authors = volumeinfo.authors ?? ["著者不明"],
                           //let pageCount = volumeinfo.pageCount ?? 0,
                           //let overview = volumeinfo.description ?? "",
                        let title = volumeinfo.title ?? "タイトル不明" //??を使えば入っていない時の処理ができる
                        //アンラップするならif let a = b elseの時の対応で変数に値を入れるとかしたら同じことができる optionalなデータを入れようとしているのに ""だとオプショナルじゃない
                            let authors = volumeinfo.authors ?? ["著者不明"]
                         let pageCount = volumeinfo.pageCount ?? 0
                        let overview = volumeinfo.description ?? ""
                        
                           if let infoLink = volumeinfo.infoLink{//たくさんあるものの中から10件拾ってきてそこから選別するんじゃなくて全体で選別してから10件取ると確実に取れる気はする
                            if let imageLinks = volumeinfo.imageLinks{
                                if let smallThumbnail1 = imageLinks.smallThumbnail{
                                    let imageUrlString = smallThumbnail1.absoluteString//Stringに変換
                                    
                                    let secureImageUrl = imageUrlString.replacingOccurrences(of: "http://", with: "https://")//Stringの中にある
                                    //"http://をhttpsに変えるよ"
                                    
                                    if let smallThumbnail = URL(string:secureImageUrl){//またURLに戻す{ URL型の初期は空を許すから使う時はアンラップ
                                        
                                        let bookitem = BookItem(title: title, authors: authors, pageCount: pageCount, infoLink: infoLink, smallThumbnail: smallThumbnail,overview: overview)
                                        bookitems.append(bookitem)
                                    }
                                }
                            }
                        }
                    }
                }
                
                print(bookitems)
            }catch{
                print("エラー")
            }
        }
    }
}
