//
//  LoginResponse.swift
//  PlatziTweets
//
//  Created by Inx on 14/04/23.
//

import Foundation

struct LoginResponse: Codable {
    let user : User
    let token : String
}
