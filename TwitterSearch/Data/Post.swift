//
//  Post.swift
//  TwitterSearch
//
//  Created by Timur Saidov on 20.08.2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import Foundation

struct Post: Decodable {
    let items: [Items]
    let profiles: [Profiles]
    let groups: [Groups]
}
