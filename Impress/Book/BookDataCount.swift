//
//  BookDataCount.swift
//  Impress
//
//  Created by user on 2025/03/30.
//

import RealmSwift//カウントデータベース

class BookDataCount:Object,Identifiable{
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var pagesumCount:Int = 0
    @Persisted var number = 0
    
    @Persisted var month = 0
    @Persisted var year = 0//追加
}
