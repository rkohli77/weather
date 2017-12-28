//
//  ViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-12.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherView: UIView!
    
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var cloudsLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    var city = ""
    var weatherModel = Weather()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
        print(city)
        weatherModel.getWeather(byCity: city) { (allWeather) in
            let temp = allWeather.value(forKeyPath: "main.temp") as? Double
            let name = allWeather.value(forKeyPath: "name") as? String
            if let tempD = temp {
                let intTemp = Int(tempD)
                let temperature = String(format:"%d", intTemp)
                let weathers = allWeather.value(forKey: "weather") as? Array<AnyObject>
                if let weather = weathers {
                    for icon in weather {
                        let imageIcon = icon.value(forKey: "icon") as! String
                        let desc = icon.value(forKey: "description") as! String
                        self.weatherModel.getWeatherImage(byIcon: imageIcon, completion: { (data) in
                            DispatchQueue.main.async {
                                self.weatherImg?.image = UIImage(data: data)
                                self.cloudsLbl.text = desc
                                self.locationLbl.text = name
                            }
                        })
                    }
                }
                DispatchQueue.main.async {
                    self.tempLbl.text = temperature + " ℃"
                    
                }
            } else {
                
            }
        }
    }
}
