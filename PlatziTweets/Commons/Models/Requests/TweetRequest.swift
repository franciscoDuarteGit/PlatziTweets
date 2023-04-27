//
//  TweetRequest.swift
//  PlatziTweets
//
//  Created by Inx on 17/04/23.
//

import Foundation

struct TweetRequest : Codable{
    let text: String
    let imageUrl: String?
    let videoUrl: String? //optionals de ahuevo
    let location: TweetRequestLocation?// antes era un tweetLocation, sin el request
    //let location : (latitude: Double, longitude: Double) // esto no funca para  algo de tipo codable
}
