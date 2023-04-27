//
//  Tweet.swift
//  PlatziTweets
//
//  Created by Inx on 17/04/23.
//

import Foundation

struct Tweet: Codable {
    let id : String
    let author : User
    let imageUrl : String
    let text : String
    let videoUrl : String
    let location : TweetLocation
    let hasVideo : Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String
    
}
