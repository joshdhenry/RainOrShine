//
//  ViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var currentWeatherView: WeatherView!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var locationSearchView: UIView!
    
    let locationManager = CLLocationManager()
    
    var searchController: UISearchController?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    
    var viewModel: WeatherViewModel? {
        didSet {            
            viewModel?.currentForecast.observe { [unowned self] in
             //print("HEYYYY \($0)")
                if ($0 != nil) {
                    //TURN THIS INTO A METHOD.  MAYBE MAKE A TEMPERATURE CLASS/ STRUCT?
                    let unformattedTemperature = $0?.currently?.temperature
                    var formattedTemperature: String = String()
                    
                    if (unformattedTemperature != nil) {
                        formattedTemperature = String(format: "%.0f", unformattedTemperature!)
                    }
                    
                    let summaryString = $0?.currently?.summary

                    DispatchQueue.main.async {
                        self.currentWeatherView.temperatureLabel.text = formattedTemperature
                        self.currentWeatherView.summaryLabel.text = summaryString
                        self.currentWeatherView.isHidden = false
                    }
                }
                else {
                    self.currentWeatherView.isHidden = true
                }
            }
            
            viewModel?.currentPlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationView.isHidden = false
                    self.locationView.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                }
                else {
                    self.locationView.isHidden = true
                }
            }
            
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                if (LocationAPIService.currentPlace != nil) {
                    if ((LocationAPIService.currentPlace?.generalLocalePhotoArray.count)! > 0) {
                        self.locationImageView.image = LocationAPIService.currentPlace?.generalLocalePhotoArray[($0)!]
                        
                        self.imagePageControl.isHidden = false
                        self.imagePageControl.currentPage = $0!
                    }
                    else {
                        //No images
                        print(self.imagePageControl.numberOfPages)
                        self.imagePageControl.isHidden = true
                        self.locationImageView.image = nil
                        self.imagePageControl.currentPage = 0
                    }
                }
                else {
                    //I DON'T KNOW WHY BUT MY TEST DOES NOT LIKE THIS, YET IN PRODUCTION IT WORKS FINE.
                    //Place is nil.  App must be just starting
                    print(self.imagePageControl.numberOfPages)
                    self.imagePageControl.isHidden = true
                    self.locationImageView.image = nil
                    self.imagePageControl.currentPage = 0
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createRotationObserver()
        createLocationSearchControllers()
        
        addLocationSearchSubViews()
        displayLocationSearchBar(isStatusBarHidden: UIApplication.shared.isStatusBarHidden)
        
        createGestureRecognizers()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        setAllAPIKeys()
        
        WeatherAPIService.setWeatherClient()

        viewModel = WeatherViewModel()
    }
    
    
    //Set all API keys for all APIs being used
    func setAllAPIKeys() {
        LocationAPIService.setAPIKeys()
        WeatherAPIService.setAPIKeys()
    }
    
    
    //Begin monitoring device orientation.  If rotated, call deviceDidRotate()
    func createRotationObserver() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    //If the device is rotated, display the location search bar appropriately
    func deviceDidRotate() {
        //print("In func deviceDidRotate()...")
        displayLocationSearchBar(isStatusBarHidden: UIApplication.shared.isStatusBarHidden)
    }
    
    
    //Initialize and configure the Google Places search controllers
    func createLocationSearchControllers() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let resultsFilter: GMSAutocompleteFilter = GMSAutocompleteFilter()
        resultsFilter.type = .city
        resultsViewController?.autocompleteFilter = resultsFilter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
    }
    
    
    func createGestureRecognizers() {
        //print("In func createGestureRecognizers...")
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }


    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        print("In func respondToSwipeGesture")
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            //If there are photos to swipe through, then allow swiping
            if ((LocationAPIService.currentPlace?.generalLocalePhotoArray.count)! > 0) {
                let currentPage = advancePageControl(direction: swipeGesture.direction, currentPage: imagePageControl.currentPage, totalNumOfPages: imagePageControl.numberOfPages)
                viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPage)
            }
        }
    }
    
    
    //Affect the imagePageControl when swiped
    func advancePageControl(direction: UISwipeGestureRecognizerDirection, currentPage: Int, totalNumOfPages: Int) -> Int {
        var newPage: Int = currentPage
        
        if (direction == UISwipeGestureRecognizerDirection.left) {
            if (currentPage < totalNumOfPages - 1) {
                newPage += 1
            }
        }
        else {
            if (currentPage > 0) {
                newPage -= 1
            }
        }
        return newPage
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization Status Changed to \(status.rawValue)")
        switch status {
        case .authorized, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    //Show the location search bar at the top of the screen
    func displayLocationSearchBar(isStatusBarHidden: Bool) {
        print("In func displayLocationSearchBar...")
        
        searchController?.searchBar.sizeToFit()
    }
    
    
    func addLocationSearchSubViews() {
        print("In func addLocationSearchSubViews...")
        
        let colorSchemeLightGray: Int = 0xf9f9f9
        
        locationSearchView.addSubview((searchController?.searchBar)!)
        
        searchController?.searchBar.barTintColor = UIColor(netHex: colorSchemeLightGray)
        searchController?.searchBar.sizeToFit()
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        LocationAPIService.setCurrentLocationPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound == true) {
                self.viewModel?.updatePlace(newPlace: locationPlace)
                print("locationPlace is \(locationPlace?.gmsPlace?.addressComponents)")
                LocationAPIService.currentPlace = locationPlace
                
                self.changePlace()
            }
        }
    }
    
    
    //Change the place that will be displayed in this view controller
    func changePlace() {
        print("In func changePlace...")
        
        //Reset some values
        self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil)
        LocationAPIService.currentPlace?.generalLocalePhotoArray.removeAll(keepingCapacity: false)
        LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray.removeAll(keepingCapacity: false)
        
        //Get the photos of the general locale
        LocationAPIService.setPhotoOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (imageSet) -> () in
            print("IMAGE SET == \(imageSet)")
            if (imageSet == true) {
                //Reset image page control
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0)
                
                //Adjust the page control according to the newly loaded place
                if ((LocationAPIService.currentPlace?.generalLocalePhotoArray.count)! == 0) {
                    self.imagePageControl.isHidden = true
                    self.imagePageControl.numberOfPages = 0
                }
                else {
                    self.imagePageControl.numberOfPages = (LocationAPIService.currentPlace?.generalLocalePhotoArray.count)!
                    self.imagePageControl.isHidden = false
                }
            }
        }
        
        //Get the weather forecast
        WeatherAPIService.setCurrentWeatherForecast(latitude: (LocationAPIService.currentPlace?.gmsPlace?.coordinate.latitude)!, longitude: (LocationAPIService.currentPlace?.gmsPlace?.coordinate.longitude)!) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.viewModel?.updateForecast(newForecast: WeatherAPIService.currentWeatherForecast)
            }
        }
    }
}
