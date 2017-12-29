//
//  MoreTableViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-11.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit
import CoreLocation

protocol MoreTableViewControllerProtocol {
    func moreViewDidFinish(city: String)
}

class MoreTableViewController: UITableViewController, LocationViewProtocol {
    
    lazy var locationModel = LocationModel()
    var weatherModel = Weather()
    var savedCities = Array<String>()
    var moreViewDelegate: MoreTableViewControllerProtocol?
    let loc = UserDefaults.standard.string(forKey: "location")
    
    func locationViewDidFinish(cityStr: String) {
        locationModel.saveCityAndCountry(cityStr: cityStr)
        savedCities = locationModel.getSavedListOfCities()
        self.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedCities = locationModel.getSavedListOfCities()
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if ((loc) != nil) {
            return 3
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return savedCities.count
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CitiesTableViewCell!
        if (indexPath.section == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CitiesTableViewCell
            let city = savedCities[indexPath.row]
            let cityOnly = city.components(separatedBy: ",")
            cell.cityLbl.text = cityOnly[0]
            weatherModel.getWeather(byCity: cityOnly[0]){ (allWeather) in
                let temp = allWeather.value(forKeyPath: "main.temp") as? Double
                if let tempD = temp {
                    let intTemp = Int(tempD)
                    let temperature = String(format:"%d", intTemp)
                    let weathers = allWeather.value(forKey: "weather") as? Array<AnyObject>
                    if let weather = weathers {
                        for icon in weather {
                            let imageIcon = icon.value(forKey: "icon")! as! String
                            self.weatherModel.getWeatherImage(byIcon: imageIcon, completion: { (data) in
                                DispatchQueue.main.async {
                                    cell.weatherImage?.image = UIImage(data: data)
                                }
                            })
                        }
                    }
                    DispatchQueue.main.async {
                        cell.tempLbl.text = temperature + " ℃"
                        
                    }
                }
            }
        }
        if((loc) != nil && indexPath.section == 2) {
            //Access itemsB[indexPath.row]
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! LocCellTableViewCell
            if let currentLoc = loc {
                cell2.cityLbl.text = currentLoc
                weatherModel.getWeather(byCity: currentLoc){ (allWeather) in
                    let temp = allWeather.value(forKeyPath: "main.temp") as? Double
                    if let tempD = temp {
                        let intTemp = Int(tempD)
                        let temperature = String(format:"%d", intTemp)
                        let weathers = allWeather.value(forKey: "weather") as? Array<AnyObject>
                        if let weather = weathers {
                            for icon in weather {
                                let imageIcon = icon.value(forKey: "icon")! as! String
                                self.weatherModel.getWeatherImage(byIcon: imageIcon, completion: { (data) in
                                    DispatchQueue.main.async {
                                        cell2.weatherImg?.image = UIImage(data: data)
                                    }
                                })
                            }
                        }
                        DispatchQueue.main.async {
                            cell2.tempLbl.text = temperature + " ℃"
                            
                        }
                    }
                }
                return cell2
            }
        }
        if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! AddTableViewCell
            return cell1
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "showPage", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "location" {
            let lvc = segue.destination as! LocationViewController
            lvc.locationViewDelegate = self
        }
        if segue.identifier == "showPage" {
            let pvc = segue.destination as! PageViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                pvc.selectedCity = savedCities[row]
            }
            pvc.delegate = self as? UIPageViewControllerDelegate
        }
        if segue.identifier == "showLoc" {
            let pvc = segue.destination as! PageViewController
            if let currLoc = loc {
                pvc.selectedCity = currLoc
            }
            pvc.delegate = self as? UIPageViewControllerDelegate
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if(indexPath.section == 1 || (indexPath.section == 2)) {
            return false
        }
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            locationModel.deleteCityFromDb(city: savedCities[indexPath.row])
            savedCities.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

