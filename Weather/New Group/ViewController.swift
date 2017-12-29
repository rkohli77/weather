//
//  ViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-12.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var weatherView: UIView!
    
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var cloudsLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    var city = ""
    var weatherModel = Weather()
    let locationManager = CLLocationManager()
    
    var leftCols = ["Sunrise", "Sunset", "Max Temp", "Min Temp"]
    var rightCols = ["Wind", "Clouds", "Pressure", "Humidity"]
    var leftVals = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        tableView1.delegate = self
        tableView1.dataSource = self
        tableView2.delegate = self
        tableView2.dataSource = self
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
                    var maxTemp = "N/A"
                    var minTemp = "N/A"
                    if let temp_max = allWeather.value(forKeyPath: "main.temp_max") as? Int {
                       maxTemp = String(format:"%d", temp_max)
                    }
                    if let temp_min = allWeather.value(forKeyPath: "main.temp_min") as? Int {
                        minTemp = String(format:"%d", temp_min)
                    }
                    let sunrise = NSDate(timeIntervalSince1970: allWeather.value(forKeyPath: "sys.sunrise") as! TimeInterval)
                    let sunset = NSDate(timeIntervalSince1970: allWeather.value(forKeyPath: "sys.sunset") as! TimeInterval)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.dateFormat = "h:mm a"

                    self.leftVals.append(dateFormatter.string(from: sunrise as Date))
                    self.leftVals.append(dateFormatter.string(from: sunset as Date))
                    self.leftVals.append(maxTemp)
                    self.leftVals.append(minTemp)

                    self.tableView1.reloadData()
                    self.tableView2.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1 {
            return 4
        }
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView1.alwaysBounceVertical = false
        tableView2.alwaysBounceVertical = false
        if(tableView == tableView1) {
            let cell = tableView1.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = leftCols[indexPath.row]
            if(leftVals.count > 0){
                cell?.detailTextLabel?.text = leftVals[indexPath.row]
            } else {
                cell?.detailTextLabel?.text = "n/a"
            }
            return cell!
        }
        let cell = tableView2.dequeueReusableCell(withIdentifier: "cell1")
        cell?.textLabel?.text = rightCols[indexPath.row]
        cell?.detailTextLabel?.text = "sub"
        return cell!
    }
}
