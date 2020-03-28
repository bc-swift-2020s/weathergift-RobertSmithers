//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by RJ Smithers on 3/20/20.
//  Copyright © 2020 RJ Smithers. All rights reserved.
//

import UIKit

class WeatherDetail: WeatherLocation {
    
    struct Result: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
    }
    struct Currently: Codable {
        var temperature: Double
        var time: TimeInterval
    }
    struct Daily: Codable {
        var summary: String
        var icon: String
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    
    func getData(completed: @escaping () -> () ) {
        let coordinates = "\(latitude),\(longitude)"
        
        let urlString = "\(APIurls.darkSkyURL)\(APIKeys.darkSkyKey)/\(coordinates)"
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("ERROR: Could not createa a URL from \(urlString)")
            completed()
            return
        }
        let session = URLSession.shared
        
        // Get data with .dataTask method
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            // note: there are some additional things that could go wrong using URL session, but we souldn't experience them, so we'll ignore testing these for now...
            
            // deal with the data
            do {
                let response = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = response.timezone
                self.currentTime = response.currently.time
                self.temperature = Int(response.currently.temperature.rounded())
                self.summary = response.daily.summary
                self.dailyIcon = response.daily.icon
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
        
    }
}
