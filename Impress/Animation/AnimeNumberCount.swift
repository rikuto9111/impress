//
//  AnimeNumberCount.swift
//  Impress
//
//  Created by user on 2025/06/06.
//

import RealmSwift

class AnimeNumberCount:Object,Identifiable{
   // Realmに保存したい型はObjectプロトコルにする 継承 idを使ってforeachとかでswiftuiで識別するためにIdentifiable
    @Persisted(primaryKey: true) var id :ObjectId
    @Persisted var number = 0//アニメ本数
    
    @Persisted var month = 0
    
    @Persisted var sumTime:Int = 0//総視聴時間
    
}
