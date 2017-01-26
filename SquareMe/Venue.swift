//
//  Venue.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/25/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation

struct Coordinate {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "\(latitude),\(longitude)"
    }
}

struct Venue {
    let id: String
    let name: String
    let checkins: Int
    var tips = [String]()
    var similarVenues = [String]()
}

extension Venue: JSONDecodable {
    init?(JSON: [String : AnyObject]) {
        guard let id = JSON["id"] as? String, let name = JSON["name"] as? String else {
            return nil
        }

        
        guard let stats = JSON["stats"] as? [String: AnyObject], let checkinsCount = stats["checkinsCount"] as? Int else {
            return nil
        }
        self.id = id
        self.name = name
        self.checkins = checkinsCount
    }
}
