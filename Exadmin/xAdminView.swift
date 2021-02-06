//
//  AdminView.swift
//  Exadmin
//
//  Created by Home on 2/27/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import SwiftUI

struct AdminView: View {
    var uid: String
    var user: String
    var group: Group
//    var requesting: Group
//    var to: Group
    @State var service = 0
    @State var from = [Group]()
//    @State var isPresented = false

    var body: some View {
        NavigationView {
            List(from, id: \.id) { member in
                HStack {
                    if member.id==self.requesting.id {
                        Text("\(member.id). \(member.name)") 
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(.green)
                        Text(member.of)
                            .foregroundColor(.red)
                            .font(.system(size: 14.0))
                    }
                }
            }
        }
        .onAppear(perform: adminAction)
        .navigationBarTitle(Text(to.name))
        .navigationBarItems(
            leading: HStack {
                Button(action: {
                    self.service = 0
                    self.adminAction()
                }) {
                    Image(systemName: "xmark.icloud.fill")
                    .font(.largeTitle)
                }.foregroundColor(.purple)
            },
            trailing: HStack {
                Button(action: {
                    self.service = 1 // Int(self.requesting.id)!
                    self.adminAction()
                }) {
                    Image(systemName: "heart.fill")
                    .font(.largeTitle)
                }.foregroundColor(.pink)
        })
//        .alert(isPresented: $isPresented) {
//            Alert(title: Text("Important"), message: Text("Are you sure?"), dismissButton: .default(Text("Accept!")))
//        }
    }
    
    func adminAction() {
        let urlPath = "http://3.92.12.25/service/"
        let url = URL(string: urlPath + "alogin.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"

        let postString = String("uid=") + String(self.requesting.id)
            + String("&name=" + self.to.name + "&option=" + String(self.service))
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
                    if lox.result > 0 {
                        //self.list = lox.group.sorted(by: {$0.id < $1.id} )
                        self.from = lox.member.sorted(by: {$0.id < $1.id} )
                        //print("\(lox.result)\n") // \(self.groups)\n\(members)")
                    }
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }
}
