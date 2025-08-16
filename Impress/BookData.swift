//
//  Untitled.swift
//  Impress
//
//  Created by user on 2025/03/29.
//
import RealmSwift

class BookData:Object,Identifiable{ //Realmに保存したい型はObjectプロトコルにする idを使ってforeachとかでswiftuiで識別するためにIdentifiable
    @Persisted(primaryKey: true) var id :ObjectId
    @Persisted var Image:String = ""
    @Persisted var title:String = ""
    @Persisted var pageCount:Int = 0
    @Persisted var finDate : Date
    @Persisted var Impression:String = ""
    @Persisted var overview : String = ""
    @Persisted var genre    : String = ""
    @Persisted var evaluate : Float  = 0.0
    @Persisted var month:Int = 0
}

