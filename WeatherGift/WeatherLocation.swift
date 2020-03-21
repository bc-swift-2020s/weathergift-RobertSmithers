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
    
    func getData() {
        let coordinates = "\(latitude),\(longitude)"
        
        let urlString = "\(APIurls.darkSkyURL)\(APIKeys.darkSkyKey)/\(coordinates)"
        
        print("We are accessing the url \(urlString)")
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("ERROR: Could not createa a URL from \(urlString)")
            return
        }
        let session = URLSession.shared
        
        // Get data with .dataTask method
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            // note: there are some additional things that could go wrong using URL session, but we souldn't experience them, so we'll ignore testing these for now...
            
            // deal with the dat
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print("\(json)")
            } catch {
                print("JESON ERROR: \(error.localizedDescription)")
            }
        }
        task.resume()
        
    }
}
