//
//  ImpressApp.swift
//  Impress
//
//  Created by user on 2025/03/02.
//

import SwiftUI
import RealmSwift
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,//.onAppearの前 //applicationにdidfinishlauntchオプションをつけることで初めの初めの一回きりの設定モード
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()//ファイアベースにこのアプリが来たよって通知する　初期化

    return true// アプリのライフスタイルイベントを管理するのがAppDelegateらしい
  }
}//swiftuiの外


@main
struct ImpressApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate//UIkit用の関数とswiftuiの橋渡し
    
    @State var issignedIn : Bool = false
    
    init(){
        migrationRealm()
    }

        //state使えないらしい
var body: some Scene {
    WindowGroup {
        Group{
            if issignedIn{
                ContentView()
            }
            else{
                LoginView(issignedIn: $issignedIn)
            }
        }
        .onAppear(){//windowgroupに対してはできなさそう
            checkSignInStatus()
        }
    }
    
}
    func checkSignInStatus() {//いちいち認証するのが面倒だからこれを作った
        Auth.auth().addStateDidChangeListener{ auth,user in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation{//画面を変更させるスイッチをカチカチじゃなくて連続なふわふわにする
                    if let user = user{//サインインしたことがあればuser情報が入っている authはログイン情報
                        issignedIn = true//user.useridすればそのユーザーのid科が取得できたりする
                    }//一回認証したことがあったらskip
                    else{
                        issignedIn = false
                    }
                }
            }
        }
    }
        
        
        
        
        func migrationRealm(){
            let config = Realm.Configuration(
                schemaVersion: 23, // 新しいスキーマバージョン
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 23
                    {
                        migration.enumerateObjects(ofType: BookData.className()) { oldObject,newObject in //グループリスト情報の更新Grouplistclassnamemigrate
                            //newObject!["label"] = List<String>()
                            newObject!["year"] = 0

                        }
                    }
                }
                
            )

            Realm.Configuration.defaultConfiguration = config
            //Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true//こいつのせいで古いバージョンは消される
    }
}
