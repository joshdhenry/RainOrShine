# Vista Weather
## aka Project RainOrShine

## Synopsis

Vista Weather is a Swift iPhone/iPad app, written in XCode entirely by myself.

Vista Weather is a beautiful and super-accurate weather app for iPhone and iPad. Check the local weather forecast or select any city in the world using the Forecast.io API. Get the five-day forecast to plan your week.

In addition to weather conditions, Vista Weather also beautifully displays photos crowd-sourced from your location using the Google Places API. Utilize the amazing Night Stand Mode and turn your device into a digital picture to turn Vista Weather into a gorgeous bed-side slide-show picture frame with up-to-date weather.  

Main languages and technologies used: Swift, Core Location, RESTful web services, Google Places API, Forecast.io API, MVVM design pattern, In-App Purchasing, UIKit, Cocoa Pods, Xcode, Photoshop


## Installation 

This project uses the following Cocoapods:
GooglePlaces - Used to load place names and place photos.  
SwiftyJSON - Used to parse JSONs returned from web API's.  
ForecastIO - Used to retrieve weather data.  
Firebase/Core - For analytics.  Integrated with Google AdMob.  
Firebase/AdMob - For analytics.  Integrated with Google AdMob.  

To run this on your own machine, download the project, then install the Cocoapods from the command line using pod install.  The files GoogleService-Info.plist (used for Ads) and APIKeys (keys for all APIs) are not included in this Git.  You will need to generate your own.  See below for more information about the API keys used by Vista Weather.


## Important things to know

When running tests in the simulator, it is crucial that you set the simulator location to Apple by going to Debug -> Location -> Apple.  Doing this will ensure some of the location-specific tests will pass.


UserDefaults

These are the names of the UserDefaults used in the app and what they are used for.
  useDefaultPhotos - Whether to use default photos when no location photos are available.  
  temperatureUnit - Whether to use celcius or fahrenheit.  
  updateWeatherInterval - How often to reload the weather.  
  changePhotoInterval - How often to change display to the next photo in the set.  
  nightStandModeOn - Whether Night Stand Mode is on or off.  
  removeAdsPurchased - Whether the user has purchased the removal of ads.  

API Keys

All APIKeys
  TestGoogleMobileAdsAdUnitID - used for testing Ads.  Not for use in the live app.  
  GoogleMobileAdsApplicationID - the application ID used by Google AdMob.  
  GoogleMobileAdsAdUnitID - the ad unit ID used by the banner in WeatherViewController.  
  DarkSkyAPIKey - used to retrieve forecasts from Dark Sky/Forecast.io.  
  GooglePlacesAPIKeyiOS - used for loading exact addresses and location images and attributions.  
  GooglePlacesAPIKeyWeb - used for extracting the general locale from an exact location.  
