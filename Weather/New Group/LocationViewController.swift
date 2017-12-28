//
//  LocationViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-11.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit

protocol LocationViewProtocol {
    func locationViewDidFinish(cityStr: String)
    func cancelButtonPressed()
}

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, LocationModelProtocol {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    lazy var locationModel = LocationModel()
    var searchBarDelegate: UISearchBarDelegate?
    var locationViewDelegate: LocationViewProtocol?
    var cityArray = Array<String>()
    var cityStr = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let city = cityArray[indexPath.row]
        cell?.textLabel?.text = city
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cityStr = cityArray[indexPath.row]
        locationViewDelegate?.locationViewDidFinish(cityStr: cityStr)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count > 2) {
            locationModel.getListOfCities(searchTxt: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        locationViewDelegate?.cancelButtonPressed()
    }
    
    func citiesArray(cities: Array<String>) {
        cityArray = cities
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationModel.locationDelegate = self
        searchBar.showsCancelButton = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

