//
//  AnimeImpress.swift
//  Impress
//
//  Created by user on 2025/03/06.
//
import RealmSwift

class AnimeData:Object,Identifiable{
   // Realmに保存したい型はObjectプロトコルにする 継承 idを使ってforeachとかでswiftuiで識別するためにIdentifiable
    @Persisted(primaryKey: true) var id :ObjectId
    
    @Persisted var Image:String = ""
    @Persisted var title:String = ""
    @Persisted var finDate : Date
    @Persisted var Impression:String = ""
    @Persisted var overview : String = ""
    @Persisted var genre    : String = ""
    
    @Persisted var firstdate: String = ""
    @Persisted var evaluate : Float  = 0.0
    
    @Persisted var episode:Int = 0
    @Persisted var year : Int = 0
}
