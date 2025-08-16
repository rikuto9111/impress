//
//  LoginView.swift
//  Impress
//
//  Created by user on 2025/04/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email:String = ""
    @State private var password:String = ""
    @Binding var issignedIn: Bool
    
    var body: some View {
        
        VStack{
            
                //Color(red:0.4,green: 0.6,blue:0.8,opacity: 0.7)
                
                Spacer()
                    .frame(height:40)
                
                Text("記憶と記録")
                    .font(.largeTitle)
                //.frame(width: 500, height: 100)
                //.background(Color.green)
                
                    .font(.title).bold()//文字のフォントを太くする
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color(red:0.4,green: 0.6,blue:0.8,opacity: 0.7)
                    )
                    .cornerRadius(20)
                    .shadow(radius: 4)
                
                Spacer()
                    .frame(height:70)
                Text("ログイン画面")
                    .font(.title)
            
            
            Divider()
            Spacer()
                .frame(height:60)
            
            Text("メールアドレスを入力")
            
            TextField("入力してください",text:$email)
                .submitLabel(.search)
                .textFieldStyle(RoundedBorderTextFieldStyle())  //枠がつけれる
                .frame(width: 300)
            
            Spacer()
                .frame(height:30)
            
            Text("パスワードを入力")
            
            TextField("入力してください",text:$password)
                .submitLabel(.search)
                .textFieldStyle(RoundedBorderTextFieldStyle())  //枠がつけれる
                .frame(width: 300)
            
            Spacer()
                .frame(height:50)
            
            HStack{
                Button("サインイン"){
                    signInWithmale(email: email, password: password)
                }
                .frame(width: 100,height: 50)
                .background(Color(red:0.9,green: 0.9,blue:0.9,opacity: 0.9))
                .cornerRadius(20)
                
                
                Spacer()
                    .frame(width:40)
                
                Button("サインアップ"){
                    signUpWithmale(email: email, password: password)
                    
                }
                .frame(width: 100,height: 50)
                .background(Color(red:0.9,green: 0.9,blue:0.9,opacity: 0.9))
                .cornerRadius(20)
            }
        }
        Spacer()
    }
    
    func signInWithmale(email: String, password: String){//入力したメアドパスワードを照合してサインインする
        Auth.auth().signIn(withEmail: email, password: password){ (result,error) in
         if let error = error{
         print("エラー")
         return
         }
         print("認証完了")
            issignedIn = true
         }//決まった型に合わせてね */
    }//Auth.auth()はfirebaseのログイン情報に関するコレクション

    
    
    func signUpWithmale(email: String, password: String){//入力したメアドパスワードでそれを多分authenticationに登録する
        Auth.auth().createUser(withEmail: email, password: password){ (result,error) in
         if let error = error{
         print("エラー")
         return
         }//認証ユーザ情報を含めてresultには複数の認証情報が含まれる
         print("サインアップ認証完了")
            
            guard let uid = result?.user.uid else{//今登録したuid
                return
            }
            
            let db = Firestore.firestore()
            let userId = String(format:"%8d",Int.random(in: 0..<100_000_000))
            
            let userData:[String:Any] = [//Any型ほおれるんだね
                "name":[],
                "userId":userId,
                "followers":[],
                "followings":[]
            ]
            
            db.collection("user").document(uid).setData(userData){error in
                print("エラー")
            }
         }
         }
    }

//AppCheckをGoogleでするのはFirebaseはGoogleの手下機能だから　追加とかそういったリクエストが怪しいアクセス
//かどうかをチェックしてくれる　つまりこいつをonにしないとアプリを認めない
