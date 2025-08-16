//
//  Key.swift
//  Impress
//
//  Created by user on 2025/06/15.
//

import SwiftUI

import RealmSwift//カウントデータベース

class Key:Object,Identifiable{
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var bookkey:Int = 0
    @Persisted var animekey:Int = 0
    
}
