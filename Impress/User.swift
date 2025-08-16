//
//  User.swift
//  Impress
//
//  Created by user on 2025/04/25.
//

import FirebaseFirestore

struct User{
    var id:String
    var name:String
    var createAt: Timestamp
    var title: String
    var overview:String
    var image:String
    var rating:Float
    var goodness: Int
    var isComment:[[String:String]]
}
