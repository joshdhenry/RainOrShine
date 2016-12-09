//
//  WeatherViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMobileAds

//WeatherViewController is the main screen for the entire app.
class WeatherViewController: UIViewController {
    // MARK: - Properties

    // MARK: Type Aliases
    typealias ScreenSize = CGSize
    
    // MARK: UI Elements
    @IBOutlet weak var locationImageView: LocationImageView!
    @IBOutlet weak var currentWeatherView: CurrentWeatherView!    
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoDetailView: PhotoDetailView!
    @IBOutlet weak var futureWeatherView: FutureWeatherView!
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var photoDetailViewBottomConstraint: NSLayoutConstraint!
    public var locationSearchView: LocationSearchView!
    @IBOutlet weak var appLogoImageView: AppLogoImageView!
    @IBOutlet weak var currentLocationButton: UIBarButtonItem!
    
    // MARK: Constants
    internal let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    private let refreshWeatherForecastNotification = Notification.Name(rawValue:"RefreshWeatherForecast")
    private let refreshImageWithNewDefaultPhotosSettingsNotification = Notification.Name(rawValue: "RefreshImageWithNewDefaultPhotosSettings")

    // MARK: Variables
    internal var screenWidthAndHeight: ScreenSize {
        if (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
            return ScreenSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        else {
            return ScreenSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        }
    }
    override var prefersStatusBarHidden: Bool {
        return !isStatusBarVisible
    }
    private var isStatusBarVisible: Bool = true
    private var weatherAPIService: WeatherAPIService = WeatherAPIService()
    internal var locationAPIService: LocationAPIService = LocationAPIService()
    private var currentSettings = Settings()
    private var updateWeatherTimer: Timer = Timer()
    private var changePhotoTimer: Timer = Timer()
    internal var validGPSConsecutiveSignalsReceived: Int = 0
    private var wasPreviouslyShowingAds: Bool = true
    
    
    // MARK: - Methods
    
    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAllAPIKeys()
        configureLocationManager()
        weatherAPIService.setWeatherClient()
        initializeViewModels()
        createSettingsUpdatesObservers()
        createGestureRecognizers()
        createBatteryStateObserver()
        createLocationSearchElements()
        startFindingCurrentLocation(alertsEnabled: false)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Redraw the location search bar when coming back to this view controller from other view controllers since user could have changed orientations since leaving this controller.
        resizeLocationSearchView(orientationAfterRotation: UIDevice.current.orientation)
        
        createTimeObservers()
        setNightStandMode()
        showAds()
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
    
    
    // MARK: Various Methods
    
    //Set all API keys for all APIs being used in this controller
    private func setAllAPIKeys() {
        locationAPIService.setAPIKeys()
        weatherAPIService.setAPIKeys()
    }
    
    
    //Create all the view models that will be needed for this controller and its subviews
    func initializeViewModels() {
        currentWeatherView.viewModel = CurrentWeatherViewModel(forecast: weatherAPIService.currentWeatherForecast)
        futureWeatherView.viewModel = FutureWeatherViewModel(forecastDataPointArray: weatherAPIService.forecastDayDataPointArray, timeZoneIdentifier: "GMT")
        locationView.viewModel = LocationViewModel(place: locationAPIService.currentPlace)
        locationImageView.viewModel = LocationImageViewModel(placeImageIndex: locationAPIService.currentPlaceImageIndex, place: locationAPIService.currentPlace)
        photoDetailView.viewModel = PhotoDetailViewModel(place: locationAPIService.currentPlace, imageIndex: nil)
        appLogoImageView.viewModel = AppLogoImageViewModel(placeImageIndex: locationAPIService.currentPlaceImageIndex, place: locationAPIService.currentPlace)
    }
    
    
    //Turn on or off the screen lock depending on the charging status and whether night stand mode is on/off in Settings
    private func setNightStandMode() {
        if (currentSettings.nightStandModeOn == true &&
            UIDevice.current.batteryState == UIDeviceBatteryState.charging ||
            UIDevice.current.batteryState == UIDeviceBatteryState.full) {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else {
            UIApplication.shared.isIdleTimerDisabled = false
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
    
    
    //If the settings button was tapped, segue to SettingsTableViewController
    @IBAction func settingsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "SegueSettings", sender: self)
    }

    
    //Reset view model image indices with a resetValue of nil or 0
    private func resetViewModelImageIndices(resetValue: Int?) {
        self.photoDetailView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: resetValue, place: self.locationAPIService.generalLocalePlace)
        self.locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: resetValue, place: self.locationAPIService.generalLocalePlace)
        self.appLogoImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: resetValue, place: self.locationAPIService.generalLocalePlace)
    }
    
    
    // MARK: Observers and Recognizers
    
    //Create the observers to catch notifications sent from Settings Detail Table View Controller
    private func createSettingsUpdatesObservers() {
        NotificationCenter.default.addObserver(forName: refreshWeatherForecastNotification, object: nil, queue: nil, using: catchRefreshWeatherForecastNotification)
        NotificationCenter.default.addObserver(forName: refreshImageWithNewDefaultPhotosSettingsNotification, object: nil, queue: nil, using: catchRefreshImageWithNewDefaultPhotosSettingsNotification)
    }
    
    
    //Catch notification center notifications
    func catchRefreshWeatherForecastNotification(notification:Notification) -> Void {
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    //If the user has changed the setting that determines how default photos are used in the app, adjust the UI to represent these new settings
    func catchRefreshImageWithNewDefaultPhotosSettingsNotification(notification:Notification) -> Void {
        guard let generalLocalePlace = locationAPIService.generalLocalePlace else {return}
        
        if (generalLocalePlace.photoArray.isEmpty &&
            currentSettings.useDefaultPhotos == .never) {
            resetViewModelImageIndices(resetValue: nil)
        }
        else if (generalLocalePlace.photoArray.isEmpty &&
            currentSettings.useDefaultPhotos == .always ||
            currentSettings.useDefaultPhotos == .whenNoPictures) {
            resetViewModelImageIndices(resetValue: 0)
        }
        else if (!generalLocalePlace.photoArray.isEmpty) {
            resetViewModelImageIndices(resetValue: 0)
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
        self.view.addGestureRecognizer(setTapRecognizer())
        locationImageView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        locationView.addGestureRecognizer(setTapRecognizer())
        currentWeatherView.addGestureRecognizer(setTapRecognizer())
        futureWeatherView.addGestureRecognizer(setTapRecognizer())
        photoDetailView.addGestureRecognizer(setTapRecognizer())
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
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
        guard let userInfo = timer.userInfo as? String else {
            print("Error - Time interval user info tag was nil.")
            return
        }
        
        switch (userInfo) {
        case "UpdateWeather":
            guard (currentNetworkConnectionStatus != .notReachable) else {return}
            
            loadNewPlaceWeather() { (isComplete) -> () in
                if (isComplete) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        case "ChangePhoto":
            guard let currentGeneralLocalePlace = locationAPIService.generalLocalePlace else {return}
            
            if (!currentGeneralLocalePlace.photoArray.isEmpty) {
                let currentPageNumber: Int = self.photoDetailView.advancePage(direction: UISwipeGestureRecognizerDirection.left, place: currentGeneralLocalePlace, looping: true)
                locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
                appLogoImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
            }
        default:
            print("Error - Time interval user info tag was not recognized.")
            return
        }
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
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {return}
        guard let currentGeneralLocalePlace = locationAPIService.generalLocalePlace else {return}
        
        //If photos were returned or default photos setting is turned on, allow swiping
        if (!currentGeneralLocalePlace.photoArray.isEmpty ||
            currentSettings.useDefaultPhotos == .whenNoPictures ||
            currentSettings.useDefaultPhotos == .always) {
            let currentPageNumber: Int = photoDetailView.advancePage(direction: swipeGesture.direction, place: currentGeneralLocalePlace, looping: false)
            
            locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
            appLogoImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
        }
    }
    
    
    // MARK: Ad Methods

    //Display ads, or don't, depending on if the Remove Ads IAP has been purchased.
    private func showAds() {
        //If the "remove ads" IAP hasn't been purchased, show ads
        if (!defaults.bool(forKey: "RemoveAdsPurchased")) {
            createAdBannerView()
            wasPreviouslyShowingAds = true
        }
        //else don't show ads
        else {
            if (wasPreviouslyShowingAds) {
                //Move the photo detail view down to account for the ads being gone now
                photoDetailViewBottomConstraint.constant -= adBannerView.adSize.size.height
                
                adBannerView.removeFromSuperview()
                
                wasPreviouslyShowingAds = false
            }
        }
    }
    
    
    //Load the banner ad
    private func createAdBannerView() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        let keys = NSDictionary(contentsOfFile: path)!
        
        //CURRENTLY USING A TEST UNIT ID FOR DEVELOPMENT.
        //SWITCH TO THE REAL UNIT ID BEFORE PUBLISHING
        adBannerView.adUnitID = keys["TestGoogleMobileAdsAdUnitID"] as? String
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    
    
    
    // MARK: Methods to load a new location
    
    //The order of changing to a new location based on current GPS and displaying it goes like this
    //currentLocationButtonTapped -> startFindingCurrentLocation -> location manager didUpdateLocation -> updateLocationAPIServiceLocations -> locationAPIService.setCurrentExactPlace -> locationAPIService.setGeneralLocalePlace -> changePlaceShown -> loadNewPlacePhotos & loadNewPlaceWeather -> finishChangingPlaceShown
    
    //If the GPS button is tapped, check if the user has a net connection, then show weather for user's current location
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        startFindingCurrentLocation(alertsEnabled: true)
    }
    
    
    //Start the process of finding current GPS location.  Once it begins updating, the location manager's didUpdateLocation method will take control from there
    private func startFindingCurrentLocation(alertsEnabled: Bool) {
        guard (currentNetworkConnectionStatus != .notReachable) else {
            if (alertsEnabled) {
                alertNoNetworkConnection()
            }
            return
        }
        
        guard (CLLocationManager.locationServicesEnabled()) else {
            if (alertsEnabled) {
                displaySimpleAlert(title: "GPS Not Enabled", message: "Location services are not enabled on this device.  Go to Settings -> Privacy -> Location Services and enable location services.", buttonText: "OK")
            }
            return
        }
        
        guard (CLLocationManager.authorizationStatus() != .denied ||
               CLLocationManager.authorizationStatus() != .restricted ||
               CLLocationManager.authorizationStatus() != .notDetermined) else {
            if (alertsEnabled) {
                displaySimpleAlert(title: "GPS Not Enabled", message: "GPS is not enabled for this app.  Go to Settings -> Privacy -> Location Services and allow the app to utilize GPS.", buttonText: "OK")
            }
            return
        }
        
        guard (CLLocationManager.authorizationStatus() != .authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() != .authorizedAlways) else {
            return
        }
        
        startChangingGPSPlaceShown()
    }
    
    
    //This method updates the location by running setCurrentExactPlace and setGeneralLocalePlace.  It is only called when the user taps the GPS current location button.
    internal func updateLocationAPIServiceLocations() {
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
        print("Exact place address - \(locationAPIService.currentPlace?.gmsPlace?.formattedAddress)")
        print("General location address - \(locationAPIService.generalLocalePlace?.gmsPlace?.formattedAddress)")

        var changePlaceCompletionFlags = (photosComplete: false, weatherComplete: false)
        
        resetValuesForNewPlace()
        
        //Run 2 methods - loadNewPlacePhotos & loadNewPlaceWeather. Once both are complete, run finishChangingPlaceShown to complete the process
        loadNewPlacePhotos() { (isComplete) -> () in
            if (isComplete) {
                changePlaceCompletionFlags.photosComplete = true
                if (changePlaceCompletionFlags.weatherComplete) {
                    DispatchQueue.main.async {
                        self.finishChangingPlaceShown()
                    }
                }
            }
        }
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete) {
                changePlaceCompletionFlags.weatherComplete = true
                if (changePlaceCompletionFlags.photosComplete) {
                    DispatchQueue.main.async {
                        self.finishChangingPlaceShown()
                    }
                }
            }
        }
    }
    
    
    //Start changing the place shown when the GPS button is tapped
    private func startChangingGPSPlaceShown() {
        currentLocationButton.isEnabled = false
        activityIndicator.startAnimating()
        locationSearchView.isUserInteractionEnabled = false
        validGPSConsecutiveSignalsReceived = 0
        locationManager.startUpdatingLocation()
    }
    
    
    //Perform final actions to complete the transition to a new place. This applies to finishing GPS locations and Google Place Search locations.
    private func finishChangingPlaceShown() {
        self.locationManager.stopUpdatingLocation()
        self.currentLocationButton.isEnabled = true
        self.activityIndicator.stopAnimating()
        locationSearchView.isUserInteractionEnabled = true
    }
    
    
    //This function is called by changePlaceShown and is run right before acquiring new values for a new place.
    //It resets some values to create a clean slate for the next place to be shown.
    private func resetValuesForNewPlace() {
        photoDetailView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil, place: nil)
        locationAPIService.generalLocalePlace?.photoArray.removeAll(keepingCapacity: false)
        locationAPIService.generalLocalePlace?.photoMetaDataArray.removeAll(keepingCapacity: false)
    }
    
    
    //Update the view model to display new place photos after a new place has been chosen
    private func loadNewPlacePhotos(completion: @escaping (_ result: Bool) ->()) {
        locationAPIService.setPhotosOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (isImageSet) -> () in
            if (isImageSet) {
                guard let thisCurrentGeneralLocalePlace = self.locationAPIService.generalLocalePlace else {
                    print("Error - Current place is nil. Cannot set photos of the general locale.")
                    return
                }
                
                //If there are no photos and the user never wants to see default photos, hide location image and photo detail view
                if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos == .never) {
                    self.resetViewModelImageIndices(resetValue: nil)
                }
                //Else reset image page control to the beginning
                else {
                    self.resetViewModelImageIndices(resetValue: 0)
                }
                completion(true)
            }
        }
    }
    
    
    //Get the weather forecast. Update the view model to display weather info when a new place has been chosen.
    private func loadNewPlaceWeather(completion: @escaping (_ result: Bool) ->()) {
        guard let currentPlace = locationAPIService.currentPlace else {return}
        guard let currentGMSPlace = currentPlace.gmsPlace else {return}
        
        weatherAPIService.forecastDayDataPointArray.removeAll(keepingCapacity: false)
        
        weatherAPIService.setCurrentWeatherForecast(latitude: currentGMSPlace.coordinate.latitude, longitude: currentGMSPlace.coordinate.longitude) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.currentWeatherView.viewModel?.updateForecast(newForecast: self.weatherAPIService.currentWeatherForecast)
                self.futureWeatherView.viewModel?.updateForecastDayDataPointArray(newForecastDayDataPointArray: self.weatherAPIService.forecastDayDataPointArray, newTimeZoneIdentifier: self.weatherAPIService.currentWeatherForecast?.timezone)
                
                completion(true)
            }
        }
    }
}
