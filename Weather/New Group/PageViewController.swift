//
//  PageViewController.swift
//  Weather
//
//  Created by Ritz on 2017-11-11.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit
import CoreLocation

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CLLocationManagerDelegate {
    
    lazy var locationModel = LocationModel()
    let locationManager = CLLocationManager()
    let vc = UIViewController()
    var savedCities = Array<String>()
    var currentInd = 0
    var selectedCity = ""
    let defaults = UserDefaults.standard
    
    lazy var VCArr:[UIViewController] = {
        return [self.VCInstance(name: "MoreTableViewController"),
                self.VCInstance(name: "ViewController")]
    }()
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        let city = savedCities[index]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.city = city
        return vc
    }
    
    
    private func VCInstance(name: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var selCity = ""
        if currentInd <= savedCities.count - 1  {
            if let currentPageViewController = viewController as? ViewController {
                selCity = currentPageViewController.city.replacingOccurrences(of: " ", with: "")
            }
        }
        if let currentIndex = savedCities.index(of: selCity) {
            if currentIndex == 0 {return nil }
            return viewControllerAtIndex(index: currentIndex - 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var selCity = ""
        if let currentPageViewController = viewController as? ViewController {
            selCity = currentPageViewController.city.replacingOccurrences(of: " ", with: "")
        }
        if let currentIndex = savedCities.index(of: selCity) {
            if currentIndex == savedCities.count - 1 {return nil }
            return viewControllerAtIndex(index: currentIndex + 1)
        }
        return nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
                view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return savedCities.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if selectedCity.count != 0 {
            return savedCities.index(of: selectedCity) ?? 0
        }
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArr.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // If the page did not turn
        if (!completed)
        {
            // You do nothing because whatever page you thought
            // the book was on before the gesture started is still the correct page
            print("The page number did not change.")
            return;
        }
        if currentInd >= 0 && currentInd < savedCities.count - 1 {
            currentInd = currentInd + 1
        }
        else if currentInd <= savedCities.count - 1 {
            currentInd = currentInd - 1
        }
        // This is where you would know the page number changed and handle it appropriately
        //print("The page number has changed.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        savedCities = locationModel.getSavedListOfCities()
        let loc = defaults.string(forKey: "location")
        if let currentLoc = loc {
            savedCities.insert(currentLoc, at: 0)
        }
        if (selectedCity.count != 0 || savedCities.count != 0) {
            if let index = savedCities.index(of: selectedCity) {
                currentInd = index
            }
            let vc = viewControllerAtIndex(index: currentInd)
            if let vc = vc {
                setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if selectedCity.count == 0 {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                if savedCities.count != 0 {
                    if defaults.string(forKey: "location") == savedCities[0] {
                        savedCities.remove(at: 0)
                        defaults.removeObject(forKey: "location")
                    }
                    let vc = viewControllerAtIndex(index: currentInd)
                    if let vc = vc {
                        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                    }
                }else {
                    setViewControllers([VCArr[0]], direction: .forward, animated: true, completion: nil)
                }
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.distanceFilter = 100
                locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var city = ""
        lookUpCurrentLocation { (placemark) in
            if let placemark = placemark {
                if let locality = placemark.locality {
                    city = locality.replacingOccurrences(of: " ", with: "")
                    if city.count != 0 {
                        let loc = self.defaults.string(forKey: "location")
                        if let locExists = loc {
                            if locExists == self.savedCities[0] {
                                self.savedCities.remove(at: 0)
                            }
                        }
                        self.defaults.set(city, forKey: "location")
                        self.updateArray(city: city)
                    }
                }
            }
        }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    private func updateArray(city: String) {
        savedCities.insert(city, at: 0)
        if savedCities.count > 0 {
            let vc = viewControllerAtIndex(index: self.currentInd)
            if let vc = vc {
                setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
}
