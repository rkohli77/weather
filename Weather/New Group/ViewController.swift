//
//  ViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-12.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var tableView0: UITableView!
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
    var rightVals = [String]()
    var timeStrArray = [String]()
    var tempStrArray = [String]()
    var imgStrArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView0.delegate = self
        tableView0.dataSource = self
        locationManager.delegate = self
        tableView1.delegate = self
        tableView1.dataSource = self
        tableView2.delegate = self
        tableView2.dataSource = self
        tableView0.alwaysBounceVertical = false
        tableView0.backgroundColor = UIColor.clear
        tableView1.alwaysBounceVertical = false
        tableView1.backgroundColor = UIColor.clear
        tableView2.alwaysBounceVertical = false
        tableView2.backgroundColor = UIColor.clear
        weatherModel.getWeatherThreeHour(byCity: city) { (allWeather) in
            let aList = allWeather.object(forKey: "list") as! Array<NSDictionary>
            for object in aList {
                let timeObj = NSDate(timeIntervalSince1970: object.object(forKey: "dt") as! TimeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "h a"
                self.timeStrArray.append(dateFormatter.string(from: timeObj as Date))
                let weatherStr = object.object(forKey: "main") as! NSDictionary
                let weatherTemp = weatherStr.object(forKey: "temp")!
                self.tempStrArray.append(String(Int(weatherTemp as! Double)) + " ℃")
                
                let weatherImgStr = object.object(forKey: "weather") as? [[String:Any]]
                if !(weatherImgStr?.isEmpty)! {
                    self.imgStrArray.append(weatherImgStr![0]["icon"]! as! String)
                }
            }
        }
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
                                self.cloudsLbl.text = desc.capitalized
                                self.locationLbl.text = name
                            }
                        })
                    }
                }
                DispatchQueue.main.async {
                    self.tempLbl.text = temperature + " ℃"
                    self.generateValues(allWeather: allWeather)
                    self.tableView1.reloadData()
                    self.tableView2.reloadData()
                    self.tableView0.reloadData()
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1 {
            return 4
        } else if(tableView == tableView0){
            return 1
        }
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView0.dequeueReusableCell(withIdentifier: "hourCell") as? HourTableViewCell
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        cell?.layer.backgroundColor = UIColor.clear.cgColor
        cell?.contentView.backgroundColor = UIColor.clear
        if(tableView == tableView1) {
            let cell = tableView1.dequeueReusableCell(withIdentifier: "cell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.layer.backgroundColor = UIColor.clear.cgColor
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.textLabel?.backgroundColor = UIColor.clear
            cell?.detailTextLabel?.backgroundColor = UIColor.clear
            cell?.textLabel?.text = leftCols[indexPath.row]
            if(leftVals.count > 0){
                cell?.detailTextLabel?.text = leftVals[indexPath.row]
            } else {
                cell?.detailTextLabel?.text = "N/A"
            }
            return cell!
        }
        if(tableView == tableView2) {
            let cell = tableView2.dequeueReusableCell(withIdentifier: "cell1")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.layer.backgroundColor = UIColor.clear.cgColor
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.textLabel?.text = rightCols[indexPath.row]
            cell?.textLabel?.backgroundColor = UIColor.clear
            cell?.detailTextLabel?.backgroundColor = UIColor.clear
            if(rightVals.count > 0){
                cell?.detailTextLabel?.text = rightVals[indexPath.row]
            } else {
                cell?.detailTextLabel?.text = "N/A"
            }
            return cell!
        }
        return cell!
    }
    
    func generateValues(allWeather: NSDictionary) {
        var maxTemp = "N/A"
        var minTemp = "N/A"
        var wind = "N/A"
        var cloud = "N/A"
        var pressure = "N/A"
        var humidity = "N/A"
        if let temp_max = allWeather.value(forKeyPath: "main.temp_max") as? Int {
            maxTemp = String(temp_max) + " ℃"
        }
        if let temp_min = allWeather.value(forKeyPath: "main.temp_min") as? Int {
            minTemp = String(temp_min) + " ℃"
        }
        let sunrise = NSDate(timeIntervalSince1970: allWeather.value(forKeyPath: "sys.sunrise") as! TimeInterval)
        let sunset = NSDate(timeIntervalSince1970: allWeather.value(forKeyPath: "sys.sunset") as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"
        
        if let windSpeed = allWeather.value(forKeyPath: "wind.speed") as? Double {
            wind = String(windSpeed) + " mph"
        }
        
        if let cloudPerc = allWeather.value(forKeyPath: "clouds.all") as? Int {
            cloud = String(cloudPerc) + "%"
        }
        
        if let pressurePerc = allWeather.value(forKeyPath: "main.pressure") as? Int {
            pressure = String(pressurePerc) + " hPA"
        }
        
        if let humidityPerc = allWeather.value(forKeyPath: "main.humidity") as? Int {
            humidity = String(humidityPerc) + "%"
        }
        
        self.leftVals.append(dateFormatter.string(from: sunrise as Date))
        self.leftVals.append(dateFormatter.string(from: sunset as Date))
        self.leftVals.append(maxTemp)
        self.leftVals.append(minTemp)
        
        self.rightVals.append(wind)
        self.rightVals.append(cloud)
        self.rightVals.append(pressure)
        self.rightVals.append(humidity)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timeStrArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourCollection", for: indexPath) as! HourCollectionViewCell
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.contentView.backgroundColor = UIColor.clear
        cell.timeLbl.backgroundColor = UIColor.clear
        cell.lblTemp.backgroundColor = UIColor.clear
        cell.timeLbl.text = timeStrArray[indexPath.row]
        cell.lblTemp.text = tempStrArray[indexPath.row]
        weatherModel.getWeatherImage(byIcon: imgStrArray[indexPath.row], completion: { (data) in
            DispatchQueue.main.async {
               cell.imgWeather.image = UIImage(data: data)
            }
        })
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
