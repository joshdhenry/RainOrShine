//
//  LocationAPIService.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/28/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import GooglePlaces
import SwiftyJSON

class LocationAPIService {
    static private var keys: NSDictionary = NSDictionary()
    static private var baseURL: String = "https://maps.googleapis.com/maps/api/place/"
    static private var placesClient: GMSPlacesClient? = GMSPlacesClient.shared()
    
    static var currentPlace: Place?
    
    static var placeIDOfGeneralLocale: String?
    static var generalLocaleQueryString: String?

    
    //Load the Google Places API keys from APIKeys.plist
    class public func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        keys = NSDictionary(contentsOfFile: path)!
    }
    
    
    //This method gets the current location of the user and sets currentPlace
    class public func setCurrentLocationPlace(completion: @escaping (_ result: Bool)->()) {
        print("In function setCurrentLocationPlace...")

        var placeFindComplete: Bool = false
        
        LocationAPIService.placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                LocationAPIService.currentPlace = nil
                
                completion(true)

                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                let firstPlaceFound = placeLikelihoods.likelihoods.first?.place
                
                LocationAPIService.currentPlace = Place()
                LocationAPIService.currentPlace?.gmsPlace = firstPlaceFound

                print("Found the place. Continuing...")
                print("Set LocationAPIService.currentPlace to \(LocationAPIService.currentPlace?.gmsPlace?.placeID)")

                placeFindComplete = true
                
                completion(true)
            }
        })
        if (placeFindComplete == false) {
            completion(false)
        }
    }
    
    
    //This method finds a photo of the general locale
    class public func setPhotoOfGeneralLocale(size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) ->()) {
        print("In function setPhotoOfGeneralLocale...")
        
        LocationAPIService.setGeneralLocaleString()
        
        //Get the place ID of the general area so that we can grab an image of the city
        LocationAPIService.setPlaceIDOfGeneralLocale()

        print("Just ran setPlaceIDOfGeneralLocale.  Continuing to setPhotoMetaDataForLocation...")
        if (LocationAPIService.placeIDOfGeneralLocale != nil) {
            LocationAPIService.setPhotoMetaData() { (photoMetaDataFound) -> () in
                if (photoMetaDataFound == true) {
                    LocationAPIService.setImageForMetadata(size: size, scale: scale) { (imageFound) -> () in
                        if (imageFound == true) {
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    }
                }
            }
        }
        else {
            print("Not loading a photo since place ID of general area was nil...")
            completion(true)
        }
    }
    
    
    //This method builds a string of the general locality of the place, which will be used to query a photo of the general locale
    class private func setGeneralLocaleString() {
        print("In function setGeneralLocaleString... (#1)")

        var queryString: String = String()
        
        for addressComponent in (LocationAPIService.currentPlace?.gmsPlace?.addressComponents)! {
            
            //print(addressComponent.type)
            //print(addressComponent.name)
            
            switch (addressComponent.type) {
                //case "sublocality_level_1":
            //    queryString += thisType.name
            case "locality":
                queryString += addressComponent.name
            case "administrative_area_level_1":
                queryString += "+" + addressComponent.name
            case "country":
                queryString += "+" + addressComponent.name
            default:
                break
            }
        }
        
        //Replace any spaces in the URL with "+"
        queryString = queryString.replacingOccurrences(of: " ", with: "+")
        
        LocationAPIService.generalLocaleQueryString = queryString
    }
    
    
    //This method takes a general area string (such as "Atlanta, Georgia, United States") and gets a place ID for that area
    class private func setPlaceIDOfGeneralLocale() {
        print("In function getPlaceIDOfGeneralLocale...(#2)")

        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        var placeTextSearchURL: String = LocationAPIService.baseURL + "textsearch/json?query=" + LocationAPIService.generalLocaleQueryString! + "&key=" + (LocationAPIService.keys["GooglePlacesAPIKeyWeb"] as! String)

        placeTextSearchURL = placeTextSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("placeTextSearchURL is \(placeTextSearchURL)")
        
        let session = URLSession.shared
        let url = URL(string: placeTextSearchURL)!
        
        // Make call. Handle it in a completion handler.
        session.dataTask(with: url as URL, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            //Ensure the  response isn't an error
            guard let thisURLResponse = response as? HTTPURLResponse,
                thisURLResponse.statusCode == 200 else {
                    print("Not a 200 (successful) response")
                    return
            }
            let json = JSON(data: data!)
            placeID = json["results"][0]["place_id"].string
            print("Made placeID OF GENERAL LOCALE equal to \(placeID)")
            
            completionHandlerCodeComplete = true
        }).resume()
        
        //DO I NEED TO IMPLEMENT PROPER COMPLETION HANDLER INTO THIS FUNCTION?????
        while (completionHandlerCodeComplete == false) {
            //print("Waiting on the photo reference to retrieve...")
        }
        print("Returning placeID OF GENERAL LOCALE of \(placeID)")
        LocationAPIService.placeIDOfGeneralLocale = placeID
    }
    
    
    //Retrieve photo metadata for place
    class private func setPhotoMetaData(completion: @escaping (_ result: Bool)->()) {
        print("In function setPhotoMetaDataForLocation...(#3)")
        print("Using place ID of \(LocationAPIService.placeIDOfGeneralLocale)")
        
        var photoMetaDataFindComplete: Bool = false
        
        LocationAPIService.placesClient?.lookUpPhotos(forPlaceID: LocationAPIService.placeIDOfGeneralLocale!) { (photos, error) -> Void in
            if let error = error {
                print("Error loading photo from Google API: \(error.localizedDescription)")
                completion(true)
                return
            } else {
                print("Photos count is \(photos?.results.count)")
                if let firstPhotoMetadata = photos?.results.first {
                    LocationAPIService.currentPlace?.firstGeneralLocalePhotoMetaData = firstPhotoMetadata
                    
                    photoMetaDataFindComplete = true
                    completion(true)
                }
                else {
                    print("No photos found. Resetting image view to blank...")

                    LocationAPIService.currentPlace?.firstGeneralLocalePhotoMetaData = nil
                    LocationAPIService.currentPlace?.firstGeneralLocalePhoto = nil
                    
                    completion(true)
                }
            }
        }
        if (photoMetaDataFindComplete == false) {
            completion(false)
        }
    }
    
    
    //Retrieve image based on place metadata
    class private func setImageForMetadata(size: CGSize, scale: CGFloat, completion: @escaping (_ result: Bool) ->()) {
        print("In function setImageForMetadata...(#4)")

        var imageFindComplete: Bool = false
        if (LocationAPIService.currentPlace?.firstGeneralLocalePhotoMetaData != nil) {

            LocationAPIService.placesClient?.loadPlacePhoto((LocationAPIService.currentPlace?.firstGeneralLocalePhotoMetaData!)!, constrainedTo: size, scale: scale) { (photo, error) -> Void in
                if let error = error {
                    print("Error loading image for metadata: \(error.localizedDescription)")
                    completion(true)
                    return
                } else {
                    LocationAPIService.currentPlace?.firstGeneralLocalePhoto = photo

                    print("self.firstGeneralLocalePhoto is \(LocationAPIService.currentPlace?.firstGeneralLocalePhoto)")

                    imageFindComplete = true
                    completion(true)
                }
            }
        }
        else {
            print("firstGeneralLocalePhotoMetaData was nil.  Exiting out of this function...")
            imageFindComplete = true
        }
        if (imageFindComplete == false) {
            completion(false)
        }
    }
}
