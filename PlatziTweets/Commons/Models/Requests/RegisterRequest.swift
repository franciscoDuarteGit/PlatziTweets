//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Inx on 14/04/23.
//

import Foundation

struct RegisterRequest : Codable{
    let email : String
    let password: String
    let names : String
}
