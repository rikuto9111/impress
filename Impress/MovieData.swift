//
//  MovieData.swift
//  Impress
//
//  Created by user on 2025/03/30.
//

import RealmSwift

class MovieData:Object,Identifiable{
    
    @Persisted(primaryKey: true) var id :ObjectId
   // @Persisted(primarykey: true) var id: ObjectId
    @Persisted var Image:String = ""
    @Persisted var title:String = ""
    @Persisted var finDate : Date
    @Persisted var Impression:String = ""
    @Persisted var overview : String = ""

    @Persisted var genre    : String = ""
    @Persisted var evaluate : Float  = 0.0
    
}
