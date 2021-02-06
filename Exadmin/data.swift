//
//  data.swift
//  Exadmin
//
//  Created by Home on 2/23/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
let urlPath = "http://idzeropoint.com"

struct Member: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var of: String
}

// Info group/members data
struct Info: Codable, Hashable {
    var result: Int
    var group: [Member]
    var members: [Member]
    
    init() {
        result = 0
        group = []
        members = []
    }
}
