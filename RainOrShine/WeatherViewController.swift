//
//  ViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMobileAds

class WeatherViewController: UIViewController {
    // MARK: - Properties

    // MARK: Type Aliases
    typealias ScreenSize = CGSize
    
    // MARK: Views
    @IBOutlet weak var locationImageView: LocationImageView!
    @IBOutlet weak var currentWeatherView: CurrentWeatherView!    
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoDetailView: PhotoDetailView!
    @IBOutlet weak var futureWeatherView: FutureWeatherView!
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var photoDetailViewBottomConstraint: NSLayoutConstraint!
    public var locationSearchView: LocationSearchView!
    
    // MARK: Constants
    let locationManager = CLLocationManager()
    
    let refreshWeatherForecastNotification = Notification.Name(rawValue:"RefreshWeatherForecast")

    // MARK: Computed vars
    internal var screenWidthAndHeight: ScreenSize {
        if (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
            return ScreenSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        else {
            return ScreenSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        }
    }
    
    // MARK: Variables
    
    
    
    
    //THIS NEEDS TO GO.  WORK ON IT
    private var appSettings: Settings = Settings()
    
    
    
    
    
    
    private var isStatusBarVisible: Bool = true
    override var prefersStatusBarHidden: Bool {
        return !isStatusBarVisible
    }
    internal var gpsConsecutiveSignalsReceived: Int = 0
    
    internal var weatherAPIService: WeatherAPIService = WeatherAPIService()
    internal var locationAPIService: LocationAPIService = LocationAPIService()
    
    var currentSettings = Settings()
    
    var updateWeatherTimer: Timer = Timer()
    var changePhotoTimer: Timer = Timer()

    
    // MARK: - Methods
    //Initialize values for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAllAPIKeys()
        configureLocationManager()
        weatherAPIService.setWeatherClient()
        initializeViewModels()
        createObservers()
        createLocationSearchElements()
        createAdBannerView()
        setNightStandMode()
    }

    
    // Hide the navigation bar on the this view controller
    override func viewWillAppear(_ animated: Bool) {
        //print("In func viewWillAppear...")
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Redraw the location search bar when coming back to this view controller from other view controllers.  User could have changed orientations since leaving this controller.
        resizeLocationSearchView(orientationAfterRotation: UIDevice.current.orientation)
        
        createTimeObservers()
    }
    
    
    // Show the navigation bar on other view controllers
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        destroyTimeObservers()
    }
    
    
    //If the view's orientation changed, make sure that the location search bar is correctly aligned
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if (Rotation.allowed) {
            if (UIDevice.current.orientation.isLandscape ||
                UIDevice.current.orientation.isPortrait) {
                resizeLocationSearchView(orientationAfterRotation: UIDevice.current.orientation)
            }
        }
    }
    
    
    //Set all API keys for all APIs being used
    private func setAllAPIKeys() {
        locationAPIService.setAPIKeys()
        weatherAPIService.setAPIKeys()
    }
    
    
    //Create all the view models that will be needed for this controller and its subviews
    func initializeViewModels() {
        currentWeatherView.viewModel = CurrentWeatherViewModel(forecast: weatherAPIService.currentWeatherForecast)
        futureWeatherView.viewModel = FutureWeatherViewModel(forecastDataPointArray: weatherAPIService.forecastDayDataPointArray)
        locationView.viewModel = LocationViewModel(place: locationAPIService.currentPlace)
        locationImageView.viewModel = LocationImageViewModel(placeImageIndex: locationAPIService.currentPlaceImageIndex, place: locationAPIService.currentPlace)
        photoDetailView.viewModel = PhotoDetailViewModel(place: locationAPIService.currentPlace, imageIndex: nil)
    }
    
    
    // MARK: Observers and Recognizers
    //Create and start all observers
    private func createObservers() {
        createNotificationCenterObserver()
        createGestureRecognizers()
        createBatteryStateObserver()
    }
    
    
    //Create the notification center observer
    private func createNotificationCenterObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName:refreshWeatherForecastNotification, object:nil, queue:nil, using:catchNotification)
    }
    
    
    //Catch notification center notifications
    func catchNotification(notification:Notification) -> Void {
        print("Catch notification")
        
        if(notification.name.rawValue == "RefreshWeatherForecast") {
            loadNewPlaceWeather() { (isComplete) -> () in
                if (isComplete) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    //Create a time observer to run every 10 minutes to refresh the weather forecast
    private func createTimeObservers() {
        //Create the update weather forecast timer
        let weatherUpdateMinutes: Int = currentSettings.updateWeatherInterval.rawValue.intFromPlainEnglish
        let updateWeatherTimeInterval: TimeInterval = Double(weatherUpdateMinutes * 60)
        
        //If it is not 0 ("Never"), start a timer to update the weather
        if (updateWeatherTimeInterval != 0) {
            updateWeatherTimer = Timer.scheduledTimer(timeInterval: updateWeatherTimeInterval, target: self, selector: #selector(self.timeIntervalReached), userInfo: "UpdateWeather", repeats: true)
        }

        //Create the change photo timer
        let photoIntervalMinutes: Int = currentSettings.changePhotoInterval.rawValue.intFromPlainEnglish
        let changePhotoTimeInterval: TimeInterval = Double(photoIntervalMinutes * 60)
        
        //If it is not 0 ("Never"), start a timer to change the photo
        if (changePhotoTimeInterval != 0) {
            changePhotoTimer = Timer.scheduledTimer(timeInterval: changePhotoTimeInterval, target: self, selector: #selector(self.timeIntervalReached), userInfo: "ChangePhoto", repeats: true)
        }
    }
    
    
    //Invalidate all of the time observers.  When the user returns from settings, all timers will be reset to whatever is in stored settings
    private func destroyTimeObservers() {
        updateWeatherTimer.invalidate()
        changePhotoTimer.invalidate()
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
    
    
    //Create the tap recognizer to detect if the screen was tapped once, which will show/hide futureWeatherView
    private func setTapRecognizer() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector (self.viewTapped (_:)))
    }
    
    
    //Begin monitoring charging state.
    private func createBatteryStateObserver() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: Notification.Name.UIDeviceBatteryStateDidChange, object: nil)
    }
    
    
    //If the battery state changes, turn on or off the screen lock accordingly
    dynamic func batteryStateDidChange(notification: NSNotification){
        setNightStandMode()
    }
    
    
    //This is called when a time observer's time has been reached.
    dynamic func timeIntervalReached(timer: Timer) {
        //print("In func timeIntervalReached...")
        
        guard let userInfo = timer.userInfo as? String else {
            print("Error - Time interval user info tag was nil.")
            return
        }
        
        switch (userInfo) {
            case "UpdateWeather":
                print("UPDATEWEATHER")
                self.activityIndicator.startAnimating()
                
                loadNewPlaceWeather() { (isComplete) -> () in
                    if (isComplete) {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            case "ChangePhoto":
                print("CHANGEPHOTO")
        default:
            print("Error - Time interval user info tag was not recognized.")
            return
        }
    }
    
    
    //Load the banner ad
    private func createAdBannerView() {
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        let keys = NSDictionary(contentsOfFile: path)!
        
        //CURRENTLY USING A TEST UNIT ID FOR DEVELOPMENT.
        //SWITCH TO THE REAL UNIT ID BEFORE PUBLISHING
        adBannerView.adUnitID = keys["TestGoogleMobileAdsAdUnitID"] as? String
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    
    
    
    //Turn on or off the screen lock depending on the charging status
    private func setNightStandMode() {
        //print("In setNightStand Mode...")

        if (UIDevice.current.batteryState == UIDeviceBatteryState.charging) {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else if (UIDevice.current.batteryState == UIDeviceBatteryState.unplugged) {
            UIApplication.shared.isIdleTimerDisabled = false
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
    
    
    //If the view was tapped, fade in or out the 5 day forecast
    internal func viewTapped(_ sender:UITapGestureRecognizer) {
        if (futureWeatherView.alpha == 0) {
            futureWeatherView.fadeIn(withDuration: 0.75, finalAlpha: 0.8)
        }
        else {
            futureWeatherView.fadeOut()
        }
    }
    
    
    //If the user swipes right or left, adjust viewmodel.updatePlaceImageIndex accordingly
    dynamic func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        print("In func respondToSwipeGesture")
        
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {return}
        guard let currentGeneralLocalePlace = locationAPIService.generalLocalePlace else {return}
        
        //THIS LINE IS TEMPORARY.  EVENTUALLY MAKE THIS SETTABLE IN SETTINGS SCREEN AND REMOVE FROM HERE
        appSettings.useDefaultPhotos = Settings.UseDefaultPhotosSetting.whenNoPictures
        print(appSettings.useDefaultPhotos)
        
        //If there are photos to swipe through, or, 
        //if the settings are set to allow use of the default photos when none are received,
        //then allow swiping
        if (!currentGeneralLocalePlace.photoArray.isEmpty ||
            appSettings.useDefaultPhotos == Settings.UseDefaultPhotosSetting.whenNoPictures) {
            let currentPageNumber = self.photoDetailView.advancePage(direction: swipeGesture.direction, place: currentGeneralLocalePlace)
            locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
        }
    }
    

    //Show or hide the status bar
    internal func showStatusBar(enabled: Bool) {
        isStatusBarVisible = enabled
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    //Make all subviews' alpha 0
    internal func makeSubViewsInvisible() {
        currentWeatherView.alpha = 0
        locationView.alpha = 0
        photoDetailView.alpha = 0
        futureWeatherView.alpha = 0
    }
   
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "SegueSettings", sender: self)
    }
    
    
    //If the GPS button is tapped, show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        ////////////////////////////////
        //REMOVE ADS EXPERIMENTAL CODE
        adBannerView.removeFromSuperview()

        //Move the photo detail view down to account for the ads being gone now
        photoDetailViewBottomConstraint.constant -= adBannerView.adSize.size.height
        ////////////////////////////////
        
        //If GPS is turned off, show an error message
        if (!CLLocationManager.locationServicesEnabled()) {
            let gpsAlert = UIAlertController(title: "GPS Not Enabled", message: "Location services are not enabled on this device.  Go to Settings -> Privacy -> Location Services and enable location services.", preferredStyle: .alert)
            gpsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(gpsAlert, animated: true, completion: nil)
            
            return
        }
        else if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            let gpsAlert = UIAlertController(title: "GPS Not Enabled", message: "GPS is not enabled for this app.  Go to Settings -> Privacy -> Location Services and allow the app to utilize GPS.", preferredStyle: .alert)
            gpsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(gpsAlert, animated: true, completion: nil)
            
            return
        }
        
        activityIndicator.startAnimating()
        
        //Reset the gps signals received counter
        gpsConsecutiveSignalsReceived = 0
        
        //Start updating the location and location manager's didUpdateLocation will take over from there
        locationManager.startUpdatingLocation()
    }
    
    
    //This method updates the location by running setCurrentExactPlace and setGeneralLocalePlace.  It is only called when the user taps the GPS current location button.
    func updateLocation() {
        makeSubViewsInvisible()
        
        locationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound) {
                self.photoDetailView.viewModel?.updatePlace(newPlace: locationPlace)
                
                self.locationAPIService.currentPlace = locationPlace
                
                //Set the general locale of the place (better for pictures and displaying user's location than exact addresses)
                self.locationAPIService.setGeneralLocalePlace() { (isGeneralLocaleFound, generalLocalePlace) -> () in
                    if (isGeneralLocaleFound) {
                        self.locationView.viewModel?.updateGeneralLocalePlace(newPlace: generalLocalePlace)
                        
                        self.locationAPIService.generalLocalePlace = generalLocalePlace
                        
                        self.changePlaceShown()
                    }
                }
            }
        }
    }
    
    
    //Change the place that will be displayed in this view controller (including new place photos and weather forecast)
    internal func changePlaceShown() {
        //print("In func changePlaceShown...")
        
        print(locationAPIService.currentPlace?.gmsPlace?.formattedAddress)
        print(locationAPIService.generalLocalePlace?.gmsPlace?.formattedAddress)

        var changePlaceCompletionFlags = (photosComplete: false, weatherComplete: false)
        
        resetValuesForNewPlace()
        
        //Run both functions.  If both are complete, stop the activity indicator
        loadNewPlacePhotos() { (isComplete) -> () in
            if (isComplete) {
                changePlaceCompletionFlags.photosComplete = true
                if (changePlaceCompletionFlags.weatherComplete) {
                    DispatchQueue.main.async {
                        self.locationManager.stopUpdatingLocation()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete) {
                changePlaceCompletionFlags.weatherComplete = true
                if (changePlaceCompletionFlags.photosComplete) {
                    DispatchQueue.main.async {
                        self.locationManager.stopUpdatingLocation()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    //This function is called by changePlaceShown and is run right before acquiring new values for a new place.
    //It resets some values to create a clean slate.
    private func resetValuesForNewPlace() {
        photoDetailView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil, place: nil)
        
        locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0, place: nil)
        
        locationAPIService.generalLocalePlace?.photoArray.removeAll(keepingCapacity: false)
        locationAPIService.generalLocalePlace?.photoMetaDataArray.removeAll(keepingCapacity: false)
    }
    
    
    //Display new place photos when a new place has been chosen
    private func loadNewPlacePhotos(completion: @escaping (_ result: Bool) ->()) {
        locationAPIService.setPhotosOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (isImageSet) -> () in
            if (isImageSet) {
                guard let thisCurrentGeneralLocalePlace = self.locationAPIService.generalLocalePlace else {
                    print("Error - Current place is nil. Cannot set photos of the general locale.")
                    return
                }
                
                //Reset image page control to the beginning
                self.photoDetailView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0, place: self.locationAPIService.generalLocalePlace)
                self.locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0, place: self.locationAPIService.generalLocalePlace)
                
                completion(true)
            }
        }
    }
    
    
    //Display weather info when a new place has been chosen. Get the weather forecast.
    private func loadNewPlaceWeather(completion: @escaping (_ result: Bool) ->()) {
        guard let currentPlace = locationAPIService.currentPlace else {return}
        guard let currentGMSPlace = currentPlace.gmsPlace else {return}
        
        weatherAPIService.forecastDayDataPointArray.removeAll(keepingCapacity: false)
        
        weatherAPIService.setCurrentWeatherForecast(latitude: currentGMSPlace.coordinate.latitude, longitude: currentGMSPlace.coordinate.longitude) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.currentWeatherView.viewModel?.updateForecast(newForecast: self.weatherAPIService.currentWeatherForecast)
                self.futureWeatherView.viewModel?.updateForecastDayDataPointArray(newForecastDayDataPointArray: self.weatherAPIService.forecastDayDataPointArray)
                
                completion(true)
            }
        }
    }
}
