//
//  AdminView.swift
//  Exadmin
//
//  Created by Home on 3/1/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import SwiftUI

struct AdminView: View {
    var uid: String
    var user: String
    var group: Member
    
    @State var option = Int(0)
    @State var members = [Member]()
    @State var request = [Member]()
    @State var selected = String("0")
    @State var selectmr = String("0")

    var body: some View {
        NavigationView {
            VStack {
                if self.request.count==0 {
                    List(members, id: \.id) { member in
                        HStack {
                            Text("\(member.id). \(member.name)")
                            Spacer()
                            if member.id==self.selectmr {
                                Image(systemName: "star.fill")
                                .foregroundColor(.green)
                            }
                            else {
                                Image(systemName: "star")
                                .foregroundColor(.green)
                            }
                            Text(member.of)
                                .foregroundColor(.red)
                                .font(.system(size: 14.0))
                        }
                        .onTapGesture {
                            self.selectDeselectMember(member)
                        }
                        .navigationBarItems(
                            leading: HStack {
                                Button(action: {
                                    self.option = -Int(self.selectmr)!
                                    self.loadMembers()
                                }) {
                                    Image(systemName: "xmark.icloud")
                                    .font(.largeTitle)
                                }.foregroundColor(.purple)
                        })
                    }
                    .navigationBarTitle(Text(self.group.name))
                }
                
                List(self.request, id: \.id) { member in
                    HStack {
                        Text("\(member.id). \(member.name)")
                        Spacer()
                        if member.id==self.selected {
                            Image(systemName: "star.fill")
                                .foregroundColor(.red)
                        }
                        else {
                            Image(systemName: "star")
                                .foregroundColor(.purple)
                        }
                        Text(member.of)
                            .foregroundColor(.red)
                            .font(.system(size: 14.0))
                    }
                    .onTapGesture {
                        self.selectDeselect(member)
                    }
                    .navigationBarItems(trailing:
                        HStack {
                            Button(action: {
                                self.option = -Int(self.selected)!
                                self.loadMembers()
                            }) {
                                Image(systemName: "heart")
                                    .font(.largeTitle)
                            }.foregroundColor(.yellow)
                            Button(action: {
                                self.option = Int(self.selected)!
                                self.loadMembers()
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.largeTitle)
                            }.foregroundColor(.pink)
                        }
                    )
                }
                .navigationBarTitle(Text(self.group.name))
                .font(.custom("Times New Roman", size: 28.0))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 1.0))
                .onAppear(perform: self.loadMembers)
            }
        }
    }
    
    func selectDeselect(_ member: Member) {
        selected = member.id
    }

    func selectDeselectMember(_ member: Member) {
        selectmr = member.id
    }

    func loadMembers() {
        let url = URL(string: urlPath + "alogin.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"
        
        let postString = String("uid=") + String(self.uid) + String("&name="+self.group.name+"&option="+String(self.option))
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
                    if lox.result > 0 {
                        self.members = lox.group.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                        self.request = lox.members.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                        //let members = lox.member
                        //print("\(lox.result)\n\(self.groups)\n\(self.members)")
                        self.option = 0
                    }
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }
}
