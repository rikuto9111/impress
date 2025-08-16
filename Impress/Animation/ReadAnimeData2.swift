//
//  ReadAnimeData2.swift
//  Impress
//
//  Created by user on 2025/06/06.
//

import SwiftUI

@Observable class ReadAnimeData2{//Observableマクロはこのクラスのプロパティなどはいちいちインスタンスかしなくても変化を追跡できるように @Observable
    

    
    struct ResultAnimeJson2: Codable{
        
        let number_of_episodes:Int?
    }
    
    //var keyid:Int = 0
    
    var epn = 0
    
    func searchAnime2(id:Int){
        
        Task{//非同期空間を生成 この中の処理は時間がかかるかもしれないかもしれないかもしれないかもしれないと明記する　すぐに帰ってこなくてもしょうがないよねだから待ったりしなければいけないかもと明記 時間がとてもかかるなら
            //バックグラウンドスレッドが必要に応じて動くかも つまりスレッドを起動するわけではない
            
            await search2(id:id)//こいつが非同期スレッドで終わってからTaskの中のその後の動作を行うけどmainはその間も他ごとはやれる
            //確実に待つことを保証しているだけ
            //await searchepisode(id:keyid)
            //print("\(keyword)です")//awaitがなかったらこいつがすぐに実行される
            print("うんこです")
            print(epn)
           
        }//まずは非同期スレッドの非同期メソッドが終わったら確実に連絡をもらうようにする
    }//asy
    @MainActor
    func search2(id:Int) async{
        
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
                guard let epnumber = json.number_of_episodes//
                else{
                    return
                }
                epn = epnumber
                print(epn)
                
            }catch{print("う")}
            
            
           // episode//検索メソッドを起動したらかけたら前の結果は初期化
            
        }
    
    }
}

