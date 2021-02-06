//
//  MemberView.swift
//  Exadmin
//
//  Created by Home on 2/27/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import SwiftUI

struct MemberView: View {
    var uid: String
    var user: String
    var group: Member

    @State var service = 0
    @State var groups = [Member]()
    @State var members = [Member]()
    @State var memcolor = 0
    let color:[Color] = [.black, .green, .red, .blue, .purple, .orange, .yellow, .pink]

    var body: some View {
        NavigationView {
            List(members, id: \.id) { member in
                HStack {
                    Text("\(member.id). \(member.name)")
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundColor(self.color[self.memcolor])
                    Text(member.of)
                        .foregroundColor(.green)
                        .font(.system(size: 14.0))
                }
                .navigationBarTitle(self.group.name)
                .navigationBarItems( leading: HStack {
                    Button(action: {
                        self.service = 3
                        self.loadMembers()
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.largeTitle)
                    }.foregroundColor(.red)
                },
                trailing: HStack {
                    Button(action: {
                        self.service = 2
                        self.loadMembers()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
                    }.foregroundColor(.green)
                })
            }
            .font(.custom("Times New Roman", size: 28.0))
            .foregroundColor(self.color[self.memcolor])
            .onAppear(perform: loadMembers)
        }
    }

    func loadMembers() {
        let url = URL(string: urlPath + "glogin.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"

        let postString = String("uid=") + String(self.uid) + String("&name="+self.group.name+"&option="+String(self.service))
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
                    if lox.result > 0 {
                        self.groups = lox.group.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                        self.members = lox.members.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                        self.memcolor = lox.result
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
