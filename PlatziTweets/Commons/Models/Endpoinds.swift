//
//  Endpoinds.swift
//  PlatziTweets
//
//  Created by Inx on 14/04/23.
//

import Foundation

struct EndPoints {
    
    static let domain = "https://platzi-tweets-backend.herokuapp.com/api/v1/"
    static let login = EndPoints.domain + "/auth"// post
    static let register  = EndPoints.domain + "/register"// post
    static let tweets = EndPoints.domain + "/posts"// get - post - delete
}
