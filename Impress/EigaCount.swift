//
//  EigaCount.swift
//  Impress
//
//  Created by user on 2025/03/31.
//

import RealmSwift//カウントデータベース

class EigaCount:Object,Identifiable{
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var number = 0
}
