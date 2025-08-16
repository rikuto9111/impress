import Charts
import RealmSwift
import SwiftUI

struct readGraph: View {
    
    @ObservedResults(BookData.self) var bookdatas
    @ObservedResults(BookDataCount.self) var bookdatacount
    @State var dictionary : [String:Int] = [:] //hashmap的なやつ Dictionary型
    @State var count = 0 //ジャンル円グラフを作るため
    
    var body: some View {
       /* ZStack{
            Image(.readbackground)
                .resizable()
                .ignoresSafeArea()*/
            
        ScrollView{

                VStack{
                    Spacer()
                        .frame(height:50)
                    
                    Text("月毎の読んだ冊数")
                    Chart {
                        ForEach(1...12, id: \.self) { month in  //foreach(bookdatacount)だと該当する月しかグラフに表示しない 1から12まで表示
                            let count =
                            bookdatacount.first(where: { $0.month == month })?
                                .number ?? 0
                            //これは1から12まで見てフィルタにかけて$0はbookdatacountの要素 それぞれ照合してぶつかったらそこのcountを入れる
                            //?はnilを許容するっていう意味  ?? nilの場合 0を入れる
                            BarMark(
                                x: .value("月", month),
                                y: .value("冊数", count)
                            )//ここの月と冊数はなんのために書いたの　中の構造問題
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(width:350,height: 300)
                    
                    
                  
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in  //この中にメモリ　グリッド　ラベルを追加
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()  //隠れていたラベルを呼び覚ます
                        }
                    }
                    .chartXAxisLabel("月") // X軸のラベルを追加
                    .chartYAxisLabel("冊数") // Y軸のラベルを追加
                    .chartYScale(domain: 0...10) // Y軸の範囲を設定
                }
                .onAppear(){
                    for book in bookdatas{//全部カウント
                        count = count + 1 //何冊あるかをカウントできる
                        
                        if let currentCount = dictionary[book.genre]{//ジャンルのデータがあるとき+1 多分optional型じゃないくせにoptionalみたいな処理してるのがだめなのかな「
                            dictionary[book.genre] = currentCount + 1
                        }
                        
                        else{
                            dictionary[book.genre] = 1
                        }//varはviewに変更があった場合再描画されるんだけどその度に値がリセットされてしまう　stateつけた変数は変わったらview全体を更新する力を持ってる
                        //viewに直接影響を与えるものに関してはStateが良い 今回はcountもdictionaryもviewにゴリゴリ与えるからStateが良い
                        //正直難しい
                    }//ジャンル数をカウント
                    print(dictionary)
                }
                
                Spacer()
                    .frame(height:50)
                
                Text("読んだ本のジャンル")
                
                Chart() {//つまり最低限だとidさえ設定しておけばあとはkey,value　これがあれば同じように使える それをいうならdictionaryがidentifiableに準拠していないとリストも同様
                    ForEach(dictionary.sorted(by: { $0.key < $1.key }), id: \.key){ key,value  in //dictionaryが普通のリストじゃないからちょっと工夫
                        SectorMark(//keyはジャンル名　valueは数  棒だとbarmark
                            angle: .value("Count", value*100/count),//これを円グラフを構成するcountとして使うよっていう意味のvalue
                            //innerRadius: .ratio(0.5),//小さい縁の半径
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Genre", key)) //keyっていう変数をbyに使うよっていう意味
                        .annotation(position:.overlay){//それぞれのグラフのパーツに適応させる注釈
                            let persent = Double(value)/Double(count)*100
                            
                            Text(String(format:"%.0f%%",persent))//その上に重ねるのがoverlay
                        }
                    }
                }
                .frame(width: 300, height: 300)
                
                
                
                
                Spacer()
            
            
        }
    }
}
/*
import SwiftUI
import Charts
import RealmSwift

struct readGraph: View {

    @ObservedResults(BookDataCount.self) var bookdatacount

    var body: some View {
        List{
                Chart{
                    ForEach(bookdatacount){ count in

                        BarMark(
                            x: .value("月",count.month),
                            y: .value("冊数",count.number)
                        )
                        .foregroundStyle(.blue) // 色を指定


                }

            }
                .frame(height:300)
        }

    }



*/
