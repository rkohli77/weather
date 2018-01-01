//
//  Weather.swift
//  MyWeatherApp
//
//  Created by Ritz on 2017-11-06.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import Foundation

class Weather {
    let urlObj = URLSession.init(configuration: .default)
    let appId = "e1a23722c122fba80e0bdf13c29dc227"
    let units = "metric"
    
    func getWeather(byCity city: String, completion: @escaping (NSDictionary) -> ()) {
        let city = city.replacingOccurrences(of: " ", with: "")
        let urlStr = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=\(appId)&units=\(units)")
        if let url = urlStr {
            urlObj.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        do {
                            let allWeather = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                            if let allWeather = allWeather {
                                if (allWeather.object(forKey: "main") != nil) {
                                    completion(allWeather)
                                }
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else {
                    print(error?.localizedDescription ?? "error")
                }
            }.resume()
        }
    }
    
    func getWeatherByCoordinates(byLat: Double, byLong: Double, completion: @escaping (NSDictionary) -> ()) {
        let urlStr = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(byLat)&lon=\(byLong)&APPID=\(appId)&units=\(units)")
        
        if let url = urlStr {
            urlObj.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        do {
                            let allWeather = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                            if let allWeather = allWeather {
                                completion(allWeather)
                            }
                            
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else {
                    print(error?.localizedDescription ?? "error")
                }
            }.resume()
        }
    }
    
    func getWeatherImage(byIcon: String, completion: @escaping (Data) -> ()) {
        let urlStr = URL(string: "http://openweathermap.org/img/w/\(byIcon).png")
        if let url = urlStr {
            urlObj.dataTask(with: url, completionHandler: { (data, response, error) in
                if error == nil {
                    if let data = data {
                        completion(data)
                    }
                }
            }).resume()
        }
    }
    
    func getWeatherThreeHour(byCity city:String, completion: @escaping (NSDictionary) -> ()){
        let city = city.replacingOccurrences(of: " ", with: "")
        let urlString = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&APPID=\(appId)&units=\(units)")
        if let urlStr = urlString {
            urlObj.dataTask(with: urlStr, completionHandler: { (data, response, error) in
                if(error == nil){
                    if(data != nil){
                        do {
                            let allWeather = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                            if let allWeather = allWeather {
                                if (allWeather.object(forKey: "list") != nil) {
                                    completion(allWeather)
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else {
                    print(error?.localizedDescription ?? "error")
                }
            }).resume()
        }
    }
}
