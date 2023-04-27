//
//  RegisterResponse.swift
//  PlatziTweets
//
//  Created by Inx on 17/04/23.
//

import Foundation
//Nota,  se pude usar el mismo del login, pero sería mejor cambiarle el nombre a la structura del login para que abarque los 2 response 
struct RegisterResponse : Codable{
    let user : User
    let token : String
}
