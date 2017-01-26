//
//  VenueImages.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/26/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
struct VenueImages {
    let imageURL: String
}

extension VenueImages : JSONDecodable {
    init?(JSON: [String : AnyObject]) {
        guard let imageUrlString = JSON[Flickr.ResponseKeys.MediumURL] as? String else {
            print("No image url")
            return nil
        }
        self.imageURL = imageUrlString
    }
}
