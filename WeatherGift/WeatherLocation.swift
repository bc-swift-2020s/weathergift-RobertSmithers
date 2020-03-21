//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by RJ Smithers on 3/9/20.
//  Copyright © 2020 RJ Smithers. All rights reserved.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

}
