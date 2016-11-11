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
import ForecastIO

class WeatherViewController: UIViewController , CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var currentWeatherView: WeatherView!
    @IBOutlet weak var locationView: LocationView!
    public var locationSearchView: LocationSearchView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoDetailView: PhotoDetailView!
    @IBOutlet weak var futureWeatherView: FutureWeatherView!
    
    let locationManager = CLLocationManager()
    var screenWidthAndHeight: CGSize = CGSize(width: 0, height: 0)
    
    
    var viewModel: WeatherViewModel? {
        didSet {            
            viewModel?.currentForecast.observe { [unowned self] in
                guard let forecast: Forecast = $0 else {
                    self.currentWeatherView.isHidden = true
                    return
                }
                guard let currently = forecast.currently else {return}
                
                var allSubViewsArray: [UIView] = [UIView]()
                
                if (!WeatherAPIService.forecastDayDataPointArray.isEmpty) {
                    for thisView in self.futureWeatherView.allSubViews {
                        if let futureDayView = thisView as? FutureWeatherDayView {
                            allSubViewsArray.append(futureDayView)
                        }
                    }
                    allSubViewsArray.sort(by: { $0.center.x < $1.center.x })
                }

                //Update the UI on the main thread
                DispatchQueue.main.async {
                    self.currentWeatherView.temperatureLabel.text = currently.temperature?.getFormattedTemperatureString() ?? ""
                    self.currentWeatherView.summaryLabel.text = currently.summary
                    self.currentWeatherView.weatherConditionView.setType =  currently.icon?.getSkycon() ?? Skycons.partlyCloudyDay
                    self.currentWeatherView.weatherConditionView.play()
                    self.currentWeatherView.isHidden = false
                    self.currentWeatherView.fadeIn()
                    
                    //Populate five day forecast from the sorted array
                    for x in 0..<allSubViewsArray.count {
                        if let futureDayView = allSubViewsArray[x] as? FutureWeatherDayView {
                            futureDayView.summaryLabel.text = WeatherAPIService.forecastDayDataPointArray[x].summary
                            futureDayView.weatherConditionView.setType = WeatherAPIService.forecastDayDataPointArray[x].icon?.getSkycon() ?? Skycons.partlyCloudyDay
                            futureDayView.weatherConditionView.play()
                            
                            futureDayView.dayLabel.text = WeatherAPIService.forecastDayDataPointArray[x].time.toAbbreviatedDayString()
                            
                            var temperatureLabelText: String = String()
                            
                            //MAKE A DICTIONARY WITH THE MIN AND MAX.  CREATE AN EXTENSION OF A DICTIONARY THAT WILL BE CALLED getFormattedTemperatureRANGEString and implement it here
                            let minText = WeatherAPIService.forecastDayDataPointArray[x].temperatureMin?.getFormattedTemperatureString() ?? ""
                            let maxText = WeatherAPIService.forecastDayDataPointArray[x].temperatureMax?.getFormattedTemperatureString() ?? ""
                            
                            temperatureLabelText = minText + "/" + maxText
                            
                            futureDayView.temperatureLabel.text = temperatureLabelText
                        }
                    }
                }
            }
            
            viewModel?.currentPlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationView.isHidden = false
                    //self.locationView.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")

                    self.locationView.fadeIn()
                    
                    self.photoDetailView.isHidden = false
                    self.photoDetailView.fadeIn()
                }
                else {
                    self.locationView.isHidden = true
                    self.photoDetailView.isHidden = true
                }
            }
            
            
            viewModel?.currentGeneralLocalePlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationView.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                }
                else {
                    self.locationView.locationLabel.text = ""
                }
            }
            
            
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let currentPlace: Place = LocationAPIService.currentPlace else {
                    //I DON'T KNOW WHY BUT MY TEST DOES NOT LIKE THIS, YET IN PRODUCTION IT WORKS FINE.
                    //Place is nil.  App must be just starting
                    self.locationImageView.image = nil
                
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.currentPage = 0
                    
                    self.photoDetailView.photoAttributionLabel.isHidden = true
                    
                    return
                }
                
                if (currentPlace.generalLocalePhotoArray.count > 0) {
                    self.locationImageView.image = currentPlace.generalLocalePhotoArray[($0)!]
                    
                    self.photoDetailView.photoPageControl.isHidden = false
                    self.photoDetailView.photoPageControl.currentPage = $0!
                    
                    guard let photoMetaData: GMSPlacePhotoMetadata = currentPlace.generalLocalePhotoMetaDataArray[$0!] else {
                        self.photoDetailView.photoAttributionLabel.isHidden = true
                        return
                    }
                    
                    let attributionPrefixAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 12)]
                    let attributionPrefixString: NSMutableAttributedString = NSMutableAttributedString(string: "Photo by ", attributes: attributionPrefixAttributes)
                    let completeAttributionString = NSMutableAttributedString()
                    
                    completeAttributionString.append(attributionPrefixString)
                    completeAttributionString.append(photoMetaData.attributions!)
                    
                    self.photoDetailView.photoAttributionLabel.attributedText = completeAttributionString
                    self.photoDetailView.photoAttributionLabel.isHidden = false
                }
                else {
                    //No images
                    self.locationImageView.image = nil
                    
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.currentPage = 0
                    self.photoDetailView.photoAttributionLabel.isHidden = true
                }
            }
        }
    }
    
    
    //Initialize values for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidthAndHeight = getScreenWidthAndHeight()
        setAllAPIKeys()
        configureLocationManager()
        createObservers()
        createLocationSearchControllers()
        
        WeatherAPIService.setWeatherClient()

        viewModel = WeatherViewModel()
    }
    
    
    // Hide the navigation bar on the this view controller
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Redraw the location search bar when coming back to this view controller from other view controllers.  User could have changed orientations since leaving this controller.
        resizeLocationSearchView()
    }
    
    
    // Show the navigation bar on other view controllers
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        destroyRotationObserver()
    }
    
    
    //Set all API keys for all APIs being used
    private func setAllAPIKeys() {
        LocationAPIService.setAPIKeys()
        WeatherAPIService.setAPIKeys()
    }
    
    
    //Set and configure the location manager
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    //Create and start all observers
    private func createObservers() {
        createRotationObserver()
        createGestureRecognizers()
        createBatteryStateObserver()
    }
    
    
    //Begin monitoring charging state.
    private func createBatteryStateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: Notification.Name.UIDeviceBatteryStateDidChange, object: nil)
    }
    
    
    //Begin monitoring device orientation.  If rotated, call deviceDidRotate()
    private func createRotationObserver() {
        //print("In func createRotationObserver...")
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    //Create gesture recognizers for swiping left and right through location photos
    private func createGestureRecognizers() {
        //print("In func createGestureRecognizers...")        
        self.view.addGestureRecognizer(setTapRecognizer())
        locationImageView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        locationView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        futureWeatherView.addGestureRecognizer(setTapRecognizer())
        photoDetailView.addGestureRecognizer(setTapRecognizer())
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    
    private func setTapRecognizer() -> UITapGestureRecognizer {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.currentWeatherTapped (_:)))
        return tapRecognizer
    }
    
    
    //If the battery state changes, turn on or off the screen lock accordingly
    dynamic func batteryStateDidChange(notification: NSNotification){
        // The stage did change: plugged, unplugged, full charge...
        if (UIDevice.current.batteryState == UIDeviceBatteryState.charging) {
            //Turn off the screen lock
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else if (UIDevice.current.batteryState == UIDeviceBatteryState.unplugged) {
            //Turn on the screen lock
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    //If the device is rotated, display the location search bar appropriately
    dynamic func deviceDidRotate(notification: NSNotification) {
        //print("In func deviceDidRotate()...")
        
        //print(UIApplication.shared.statusBarOrientation.isLandscape)
        //print(UIApplication.shared.statusBarOrientation.isPortrait)
        //print(UIApplication.shared.isStatusBarHidden)

        if (Rotation.allowed) {
            resizeLocationSearchView()
        }
    }
    
    
    internal func currentWeatherTapped(_ sender:UITapGestureRecognizer) {
        if (futureWeatherView.alpha == 0) {
            futureWeatherView.fadeIn(withDuration: 0.75, finalAlpha: 0.85)
        }
        else {
            futureWeatherView.fadeOut()
        }
    }
    
    
    //If the user is searching, disable rotation until finished
    internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing...")
        
        Rotation.allowed = false
    }
    
    
    //If the user is done searching, re-enable screen rotation
    internal func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing...")
        
        Rotation.allowed = true
    }
    
    
    //If the user swipes right or left, adjust viewmodel.updatePlaceImageIndex accordingly
    dynamic func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        //print("In func respondToSwipeGesture")
        
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {return}
        
        //If there are photos to swipe through, then allow swiping
        if ((LocationAPIService.currentPlace?.generalLocalePhotoArray.count)! > 0) {
            
            let currentPage = advancePage(direction: swipeGesture.direction, currentPageNumber: self.photoDetailView.photoPageControl.currentPage, totalNumberOfPages: self.photoDetailView.photoPageControl.numberOfPages)
            
            viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPage)
        }
    }
    
    
    //Get the width and height of the UI Screen
    private func getScreenWidthAndHeight() -> CGSize {
        var screenWidth: CGFloat = 0.0
        var screenHeight: CGFloat = 0.0
        
        if (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
            screenWidth = UIScreen.main.bounds.width
            screenHeight = UIScreen.main.bounds.height
        }
        else {
            screenWidth = UIScreen.main.bounds.height
            screenHeight = UIScreen.main.bounds.width
        }
        
        //print("screenWidth is \(screenWidth)")
        //print("screenHeight is \(screenHeight)")
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    
    //Initialize and configure the Google Places search controllers
    private func createLocationSearchControllers() {
        
        initializeLocationSearchView()
        
        locationSearchView.resultsViewController?.delegate = self
        locationSearchView.searchController?.searchBar.delegate = self

        self.view.addSubview(locationSearchView)
        
        locationSearchView.searchController?.searchBar.sizeToFit()
        locationSearchView.searchController?.hidesNavigationBarDuringPresentation = false
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    

    //Create the views necessary for searching locations
    private func initializeLocationSearchView() {
        /*if (UIApplication.shared.statusBarOrientation.isLandscape) {
         if (UIApplication.shared.isStatusBarHidden) {
         subView = UIView(frame: CGRect(x: 0, y: 0, width: screenHeight, height: 45))
         }
         else {
         subView = UIView(frame: CGRect(x: 0, y: 20, width: screenHeight, height: 45))
         }
         }
         else if (UIApplication.shared.statusBarOrientation.isPortrait) {
         subView = UIView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: 45))
         }*/
        
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            // do your portrait stuff
            locationSearchView = LocationSearchView(frame: CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45))

        } else {
            // do your landscape stuff
            if (UIApplication.shared.isStatusBarHidden) {
                locationSearchView = LocationSearchView(frame: CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: 45))
            }
            else {
                locationSearchView = LocationSearchView(frame: CGRect(x: 0, y: 20, width: screenWidthAndHeight.height, height: 45))
            }
        }
    }
    
    
    //Resize the views necessary for location.  Determine if the device is portrait or landscape and resize the search bar accordingly.
    internal func resizeLocationSearchView() {
        /*if (UIApplication.shared.statusBarOrientation.isLandscape) {
         if (UIApplication.shared.isStatusBarHidden) {
         subView.frame = CGRect(x: 0, y: 0, width: screenHeight, height: 45)
         }
         else {
         subView.frame = CGRect(x: 0, y: 20, width: screenHeight, height: 45)
         }
         }
         else if (UIApplication.shared.statusBarOrientation.isPortrait) {
         subView.frame = CGRect(x: 0, y: 20, width: screenWidth, height: 45)
         }*/
        
        print("screenWidthAndHeight.width is \(screenWidthAndHeight.width)")
        print("screenWidthAndHeight.height is \(screenWidthAndHeight.height)")
        
        
        //THIS < OR > IN THIS LINE NEEDS TO BE DIFFERENT DEPENDING ON THE DEVICE.  FOR SURE, IPHONE 6, IPHONE 6 PLUS NEEDS TO BE >.  IPAD AIR 2 NEEDS TO BE <
        //SO WHAT I REALLY NEED TO DO TOMORROW IS JUST TEST ON ALL SCREEN TYPES AND DO DIFFERENT < OR > DEPENDING ON THE DEVICE IDIOM.
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            // do your portrait stuff
            print("Switching to portrait...")
            locationSearchView.frame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45)
            //print(locationSearchView.frame.width)
            
            locationSearchView.searchController?.view.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.width, height: screenWidthAndHeight.height)
        } else {    // in landscape
            // do your landscape stuff
            print("Switching to landscape...")
            
            if (UIApplication.shared.isStatusBarHidden) {
                locationSearchView.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: 45)
            }
            else {
                locationSearchView.frame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.height, height: 45)
            }
        }
        
        /*print(locationSearchView.frame)
        print(searchController?.view.frame)
        print(searchController?.searchBar.frame)*/
        
        locationSearchView.searchController?.searchBar.sizeToFit()
        
        /*print(locationSearchView.frame)
        print(searchController?.view.frame)
        print(searchController?.searchBar.frame)*/
    }
    
    
    //Change the place that will be displayed in this view controller (including new place photos and weather forecast)
    internal func changePlaceShown() {
        //print("In func changePlaceShown...")
        
        print("PLACE IDS")
        print(LocationAPIService.currentPlace?.gmsPlace?.placeID)
        print(LocationAPIService.generalLocalePlace?.gmsPlace?.placeID)
        
        print(LocationAPIService.currentPlace?.gmsPlace?.formattedAddress)
        print(LocationAPIService.generalLocalePlace?.gmsPlace?.formattedAddress)

        
        var changePlaceCompletionFlags = (photosComplete: false, weatherComplete: false)
        
        //activityIndicator.startAnimating()
        
        //Reset some values
        self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil)
        LocationAPIService.currentPlace?.generalLocalePhotoArray.removeAll(keepingCapacity: false)
        LocationAPIService.currentPlace?.generalLocalePhotoMetaDataArray.removeAll(keepingCapacity: false)
        
        WeatherAPIService.forecastDayDataPointArray.removeAll(keepingCapacity: false)
        
        //Run both functions.  If both are complete, stop the activity indicator
        displayNewPlacePhotos() { (isComplete) -> () in
            if (isComplete == true) {
                changePlaceCompletionFlags.photosComplete = true
                if (changePlaceCompletionFlags.weatherComplete == true) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        displayNewPlaceWeather() { (isComplete) -> () in
            if (isComplete == true) {
                changePlaceCompletionFlags.weatherComplete = true
                if (changePlaceCompletionFlags.photosComplete == true) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    //Display new place photos when a new place has been chosen
    private func displayNewPlacePhotos(completion: @escaping (_ result: Bool) ->()) {
        //Get the photos of the general locale
        LocationAPIService.setPhotosOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (isImageSet) -> () in
            //print("IMAGE SET == \(imageSet)")
            if (isImageSet == true) {
                //Reset image page control
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0)
                
                //Adjust the page control according to the newly loaded place (if the place is not nil)
                guard let currentPlace = LocationAPIService.currentPlace else {return}
                
                if (currentPlace.generalLocalePhotoArray.count == 0) {
                    self.photoDetailView.photoPageControl.isHidden = true
                    self.photoDetailView.photoPageControl.numberOfPages = 0
                }
                else {
                    self.photoDetailView.photoPageControl.numberOfPages = currentPlace.generalLocalePhotoArray.count
                    self.photoDetailView.photoPageControl.isHidden = false
                }
                completion(true)
            }
        }
    }
    
    
    //Display weather info when a new place has been chosen
    private func displayNewPlaceWeather(completion: @escaping (_ result: Bool) ->()) {
        //Get the weather forecast
        guard let currentPlace = LocationAPIService.currentPlace else {return}
        guard let currentGMSPlace = currentPlace.gmsPlace else {return}
        
        WeatherAPIService.setCurrentWeatherForecast(latitude: currentGMSPlace.coordinate.latitude, longitude: currentGMSPlace.coordinate.longitude) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.viewModel?.updateForecast(newForecast: WeatherAPIService.currentWeatherForecast)
                
                completion(true)
            }
        }
    }
    

    //Advance forwards or backwards through page numbers, accounting for total number of pages
    private func advancePage(direction: UISwipeGestureRecognizerDirection, currentPageNumber: Int, totalNumberOfPages: Int) -> Int {
        var newPageNumber: Int = currentPageNumber
        
        if (direction == UISwipeGestureRecognizerDirection.left) {
            if (currentPageNumber < totalNumberOfPages - 1) {
                newPageNumber += 1
            }
        }
        else {
            if (currentPageNumber > 0) {
                newPageNumber -= 1
            }
        }
        return newPageNumber
    }
    
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        
        //GPS is allowed.  Turn on GPS locator and continue seeking the weather for current location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
        //GPS is off.  Alert the user and return out of this function.
        else {
            let gpsAlert = UIAlertController(title: "GPS Not Enabled", message: "GPS is not enabled for this app.  Go to Settings -> Privacy -> Location Services and allow the app to utilize GPS.", preferredStyle: .alert)
            gpsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(gpsAlert, animated: true, completion: nil)
            
            return
        }
        
        makeSubViewsInvisible()
        
        LocationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound) {
                print("Found the location...")
                self.viewModel?.updatePlace(newPlace: locationPlace)
                
                LocationAPIService.currentPlace = locationPlace
                
                print("LocationAPIService.currentPlace?.gmsPlace?.placeID is \(LocationAPIService.currentPlace?.gmsPlace?.placeID)")
                
                //THIS BEING HERE MIGHT HAVE CAUSED BACK TO BACK REFRESHES TO SHOW THE SAME LOCATION, EVEN THOUGH THE LOCATION CHANGED
                //Once the GPS locational data has been retrieved to set the exact place, turn off the GPS
                //self.locationManager.stopUpdatingLocation()
                
                //Set the general locale of the place (better for pictures and displaying user's location)
                LocationAPIService.setGeneralLocalePlace() { (isGeneralLocaleFound, generalLocalePlace) -> () in
                    if (isGeneralLocaleFound) {
                        
                        self.viewModel?.updateGeneralLocalePlace(newPlace: generalLocalePlace)
                        
                        LocationAPIService.generalLocalePlace = generalLocalePlace
                        
                        self.changePlaceShown()
                    }
                }
            }
        }
    }
    
    
    //Make all subviews' alpha 0
    internal func makeSubViewsInvisible() {
        currentWeatherView.alpha = 0
        locationView.alpha = 0
        photoDetailView.alpha = 0
        futureWeatherView.alpha = 0
    }
    
    
    //DO THIS FOR OTHER OBSERVERS IF NEEDED
    //End monitoring device orientation
    private func destroyRotationObserver() {
        NotificationCenter.default.removeObserver(self)
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
}
