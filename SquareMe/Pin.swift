//
//  Pin.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/24/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import MapKit

final class Pin{
    let title: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
    }
}
