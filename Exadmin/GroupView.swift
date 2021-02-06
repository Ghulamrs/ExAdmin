//
//  groupview.swift
//  Exadmin
//
//  Created by Home on 2/29/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func prefixedWithIcon(named name: String) -> some View {
        HStack {
            Image(systemName: name)
            self
        }
    }
}

struct GroupView: View {
    var userName: String
    @State var name = String("")
    @State var uid = String("0")
    @State var groups = [Member]()
    
    var body: some View {
        NavigationView {
            VStack {
                List(groups, id: \.id) { group in
                    if( self.userName == group.of) {
                        NavigationLink(destination:
                            AdminView(uid: self.uid, user: self.userName, group: group)) {
                            HStack {
                                Text("\(group.id). \(group.name)")
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.green)
                                Text(group.of)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14.0))
                            }
                        }
                    }
                    else {
                        NavigationLink(destination:
                            MemberView(uid: self.uid, user: self.userName, group: group)) {
                            HStack {
                                Text("\(group.id). \(group.name)")
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(group.of)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14.0))
                            }
                        }
                    }
                }
                .navigationBarTitle(Text(self.userName))
                .font(.custom("Times New Roman", size: 24.0))
                .foregroundColor(Color(red: 0, green: 0.5, blue: 0.5))
                .onAppear(perform: loadGroups)
            }
            .navigationBarItems(
                leading: HStack {
                    Text("Name")
                        .font(.callout)
                        .bold()
                    TextField("New group", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .prefixedWithIcon(named: "person.3.fill")
                },
                trailing: HStack {
                    Button(action: {
                        if self.name.count > 0 {
                            self.loadMembers()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                        .font(.largeTitle)
                    }.foregroundColor(.green)
            })
        }
    }
    
    func loadGroups() {
        let url = URL(string: urlPath + "gloginx.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"

        let postString = String("name=") + self.userName + String("&pswd="+self.userName.prefix(3)+"123")
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
                    if lox.result > 0 {
                        self.uid = String(lox.result)
                        self.groups = lox.group.sorted(by: { UInt($0.id)! < UInt($1.id)! } )
//                        let members = lox.member.sorted(by: {$0.id < $1.id} )
//                        print("\(lox.result)\n\(self.groups)\n\(members)")
                    }
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }
    
    func loadMembers() {
        let url = URL(string: urlPath + "glogin.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"

        let postString = String("uid=") + String(self.uid) + String("&name=\(self.name)&option=1")
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
                    if lox.result > 0 {
                        self.groups = lox.group.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                        //self.members = lox.member.sorted(by: {$0.id < $1.id} )
                        //let members = lox.member
                        //print("\(lox.result)\n\(self.groups)\n\(self.members)")
                    }
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }
}
