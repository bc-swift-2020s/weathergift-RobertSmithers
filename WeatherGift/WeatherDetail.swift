//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by RJ Smithers on 3/20/20.
//  Copyright © 2020 RJ Smithers. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()

struct DailyWeather: Codable {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
    }
    private struct Currently: Codable {
        var temperature: Double
        var time: TimeInterval
    }
    private struct Daily: Codable {
        var summary: String
        var icon: String
        var data: [DailyData]
    }
    private struct DailyData: Codable {
        var icon: String
        var time: TimeInterval
        var summary: String
        var temperatureHigh: Double
        var temperatureLow: Double
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    
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
                for index in 0..<response.daily.data.count {
                    let weekdayDate = Date(timeIntervalSince1970: response.daily.data[index].time)
                    dateFormatter.timeZone = TimeZone(identifier: response.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    print(dailyWeekday)
                    let dailyIcon = response.daily.data[index].icon
                    let dailySummary = response.daily.data[index].summary
                    let dailyHigh = Int(response.daily.data[index].temperatureHigh.rounded())
                    let dailyLow = Int(response.daily.data[index].temperatureLow.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                }
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
        
    }
}
