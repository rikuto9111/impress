//
//  UserAnime.swift
//  Impress
//
//  Created by user on 2025/06/06.

import FirebaseFirestore

struct UserAnime{
    var id:String
    var name:String
    var createAt: Timestamp
    var title: String
    var overview:String
    var image:String
    var rating:Float
    var goodness: Int
    var episodes: Int
    var isComment:[[String:String]]
}

