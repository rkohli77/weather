//
//  ViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-11.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView1.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "sunrise"
        cell?.detailTextLabel?.text = "sub"
        return cell!
    }
    
    
    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var cloudsLbl: UILabel!
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var tempLbl: UILabel!
    
    let locationManager = CLLocationManager()
    var weatherModel = Weather()
    var city = ""
    
    override func viewWillAppear(_ animated: Bool) {
        //  let m = MoreTableViewController()
        //  m.moreViewDelegate = self
        print(city)
        if(city != "") {
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
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 100
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(locationManager.location!) {
                (placemarks, error) -> Void in
                if let placemark = placemarks?.last {
                    if let locality = placemark.locality {
                        self.city = locality
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        weatherModel.getWeatherByCoordinates(byLat: userLocation.coordinate.latitude, byLong: userLocation.coordinate.longitude) { (allWeather) in
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
            }
        }
    }
}


