//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by RJ Smithers on 3/20/20.
//  Copyright © 2020 RJ Smithers. All rights reserved.
//

import UIKit

private let dayFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()

private let hourlyFormatter: DateFormatter = {
    let hourlyFormatter = DateFormatter()
    hourlyFormatter.dateFormat = "ha"
    return hourlyFormatter
}()

struct DailyWeather: Codable {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather: Codable {
    var hour: String
    var hourlyIcon: String
    var hourlyTemperature: Int
    var hourlyPrecipProbability: Int
}

class WeatherDetail: WeatherLocation {
    
    private struct Response: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
        var hourly: Hourly
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
    private struct Hourly: Codable {
        var data: [HourlyData]
    }
    private struct HourlyData:Codable {
        var time: TimeInterval
        var icon: String
        var precipProbability: Double
        var temperature: Double
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
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
                let response = try JSONDecoder().decode(Response.self, from: data!)
                self.timezone = response.timezone
                self.currentTime = response.currently.time
                self.temperature = Int(response.currently.temperature.rounded())
                self.summary = response.daily.summary
                self.dailyIcon = response.daily.icon
                
                for index in 0..<response.daily.data.count {
                    let weekdayDate = Date(timeIntervalSince1970: response.daily.data[index].time)
                    dayFormatter.timeZone = TimeZone(identifier: response.timezone)
                    let dailyWeekday = dayFormatter.string(from: weekdayDate)
                    let dailyIcon = response.daily.data[index].icon
                    let dailySummary = response.daily.data[index].summary
                    let dailyHigh = Int(response.daily.data[index].temperatureHigh.rounded())
                    let dailyLow = Int(response.daily.data[index].temperatureLow.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                }
                
                for index in 0..<response.hourly.data.count {
                    let hourlyDate = Date(timeIntervalSince1970: response.hourly.data[index].time)
                    hourlyFormatter.timeZone = TimeZone(identifier: response.timezone)
                    let hour = dayFormatter.string(from: hourlyDate)
                    let hourlyIcon = response.hourly.data[index].icon
                    let precipProbability = Int((response.hourly.data[index].precipProbability * 100).rounded())
                    let temperature = Int(response.hourly.data[index].temperature.rounded())
                    let hourlyWeather = HourlyWeather(hour: hour, hourlyIcon: hourlyIcon, hourlyTemperature: temperature, hourlyPrecipProbability: precipProbability)
                    self.hourlyWeatherData.append(hourlyWeather)
                }
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
        
    }
}
