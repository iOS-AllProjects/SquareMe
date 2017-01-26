//
//  Tips.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/25/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
struct Tips {
    let id: String
    let text: String
}

extension Tips: JSONDecodable {
    init?(JSON: [String : AnyObject]) {
        guard let id = JSON["id"] as? String, let text = JSON["text"] as? String else {
            return nil
        }
        self.id = id
        self.text = text
    }
}
