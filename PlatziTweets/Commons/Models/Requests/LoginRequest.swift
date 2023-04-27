//
//  LoginRequest.swift
//  PlatziTweets
//
//  Created by Inx on 14/04/23.
//

import Foundation
//TIPO POST
struct LoginRequest: Codable {
    let email : String
    let password : String
}
