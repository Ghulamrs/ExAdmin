//
//  ContentView.swift
//  Exadmin
//
//  Created by Home on 1/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import SwiftUI
import Network

struct ContentView: View {
    @State var status = Color(.red)
    @State var members = [Member]()
    @State var title: String = "Morning Walk"
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.75, green: 0, blue: 0.75, alpha: 0.1)
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.darkGray,
            .font : UIFont(name:"Papyrus", size: 40)!]
        UINavigationBar.appearance().titleTextAttributes = [
            .font : UIFont(name: "HelveticaNeue-Thin", size: 20)!]
    }
    
    var body: some View {
        NavigationView {
            List(members, id: \.id) { member in
                NavigationLink(destination: GroupView(userName: member.name)) {
                    HStack {
                        Text("\(member.id). \(member.name)")
                        Spacer()
                        Text("\(member.of)")
                        Image(systemName: "star.fill")
                                .foregroundColor(.purple)
                    }
                }
            }
            .navigationBarTitle(Text(self.title))
            .font(.custom("Times New Roman", size: 24.0))
            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.25))
            .onAppear(perform: lookupUsers)
            .onDisappear(perform: lookupUsers)
            .navigationBarItems(trailing:
                Image(systemName: "house.fill")
                    .foregroundColor(self.status)
                    .font(.custom("Times New Roman", size: 40.0))
            )
        }.accentColor(.purple)
    }

    func lookupUsers() {
        if !NetStatus.shared.isMonitoring { // onAppear
            NetStatus.shared.startMonitoring()
            NetStatus.shared.didStartMonitoringHandler = {}
            NetStatus.shared.didStopMonitoringHandler = {}
            NetStatus.shared.netStatusChangeHandler = {}
            NetStatus.shared.monitor!.pathUpdateHandler = { path in
                if path.usesInterfaceType(.wifi) {
                    let ext = "@WiFi"
                    if(!self.title.contains(ext)) { self.title += ext }
                } else if path.usesInterfaceType(.cellular) {
                    let ext = "@3G/4G"
                    if(!self.title.contains(ext)) { self.title += ext }
                }
                if path.status == .satisfied {
                    self.loadFilesList()
                    self.loadUsersList()
                }
            }
        } else { // onDisappear
            NetStatus.shared.stopMonitoring()
        }
    }
    
    func loadUsersList() {
        let url = URL(string: urlPath + "gloginx.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"

        let postString = String("name=name") + String("&pswd=pswd")
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
//                    self.groups = lox.group.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                    self.members = lox.members.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }

    func loadFilesList() {
        let url = URL(string: urlPath + "crcdir.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"

        let postString = String("dir=.")
        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                let lox = try decoder.decode(Info.self, from: data!)

                DispatchQueue.main.sync {
//                    self.members = lox.member.sorted(by: {UInt($0.id)! < UInt($1.id)!} )
                    if lox.result > 11 { self.status = .green }
                    else { self.status = .red }
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }
}
