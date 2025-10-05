//
//  Profilebase.swift
//  Impress
//
//  Created by user on 2025/05/12.
//
import RealmSwift

class Profilebase :Object,Identifiable{
    @Persisted(primaryKey: true) var id :ObjectId
    
    @Persisted var Imagebackground : Data?  //Uiimageはrealmには入らないらしいからこそ中継構造を作ってやる
    @Persisted var Introduce : String = ""//問屋さん
    
    @Persisted var username : String = ""
    
    @Persisted var ImageIcon: Data?
    
    @Persisted var label: List<String> 
    @Persisted var animelabel: List<String>
    
    var image: UIImage? {
        get{
            guard let Imagebackground else {return nil}
            return UIImage(data:Imagebackground)
        }
        set{
            Imagebackground = newValue?.jpegData(compressionQuality: 0.8)//jpeg形式のdata型に変換　0から1
        }//setの中で使える特別性がnewValue 新しいセットされる値が入る
    }
    
    var imageicon: UIImage? {
        get{
            guard let ImageIcon else {return nil}
            return UIImage(data:ImageIcon)
        }
        set{
            ImageIcon = newValue?.jpegData(compressionQuality: 0.8)//jpeg形式のdata型に変換　0から1
        }//setの中で使える特別性がnewValue 新しいセットされる値が入る
    }
}

/*
 RealmはUIimage型を保存できない -> 表にdata型をvarで出しておいて 外からUIImage型にアクセスしてsetするとクラス定義の中でData型に変換して保存
 
 -> 取り出す時はvar UIImage型に外からアクセスすると自然とかわりにUIImage型に変換されたData型のものがgetできる
 
 get setの仕組みを作っておく!
 */
