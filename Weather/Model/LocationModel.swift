//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Ritz on 2017-10-30.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc protocol LocationModelProtocol {
    
   @objc optional func citiesArray(cities: Array<String>)
}

class LocationModel {
    
    var locationDelegate: LocationModelProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityAndCountry")
    
    func getListOfCities(searchTxt: String) {
        let urlString = URL(string: "http://gd.geobytes.com/AutoCompleteCity?callback=?&q=\(searchTxt)")
      //  let urlString = URL(string: "http://gd.geobytes.com/AutoCompleteCity?callback=?&q=toron")
        DispatchQueue(label: "cities", qos: .background).async {
            if let url = urlString {
                do {
                    URLSession.shared.dataTask(with: url) {(data, respose, error) in
                        if (error != nil){
                            print(error?.localizedDescription ?? "Error Ocurred")
                        } else {
                            if data != nil {
                                let convertToString = String(data: data!, encoding: String.Encoding.utf8) as String!
                                let str1 = convertToString?.dropFirst(2)
                                let str2 = str1?.dropLast(2)
                                if let data = str2?.data(using: String.Encoding.utf8) {
                                    let allData = try! JSONSerialization.jsonObject(with: data, options: []) as! Array<String>
                                    DispatchQueue.main.async {
                                        self.locationDelegate?.citiesArray!(cities: allData)
                                    }
                                }
                            }
                        }
                    }.resume()
                }
            }
        }
    }
    
    func saveCityAndCountry(cityStr: String) {
        print(cityStr)
        var cityStrArr = cityStr.components(separatedBy: ",")
        let city = cityStrArr[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
        let entity = NSEntityDescription.insertNewObject(forEntityName: "CityAndCountry", into: appDelegate.persistentContainer.viewContext)
        entity.setValue(city, forKey: "cityWithCountry")
        appDelegate.saveContext()
    }
    
    func getSavedListOfCities() -> Array<String> {
        var finalArray = Array<String>()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as Array<Any>.ArrayLiteralElement
            let resultsDict = results as! [NSDictionary]
            for result in resultsDict {
                finalArray.append(result.value(forKey: "cityWithCountry") as! String)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return finalArray
    }
    
    func deleteCityFromDb(city: String) {
        print(city)
        let predicate = NSPredicate(format: "cityWithCountry == %@", city)
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.predicate = predicate
        do {
            let cityObjs = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as! [CityAndCountry]
            for cityObj in cityObjs {
                print(cityObj)
                appDelegate.persistentContainer.viewContext.delete(cityObj)
                appDelegate.saveContext()
            }
            fetchRequest.predicate = nil
        }
        catch {
            
        }
        
    }
}
