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
    // MARK: - Properties
    typealias PlaceResult = (_ result: Bool, _ generalLocalePlace: Place?)->()
    typealias Result = (_ result: Bool) ->()

    private var keys: NSDictionary = NSDictionary()
    private var baseURL: String = "https://maps.googleapis.com/maps/api/place/"
    lazy private var placesClient: GMSPlacesClient? = GMSPlacesClient.shared()
    
    public var currentPlace: Place?
    public var generalLocalePlace: Place?
    public var currentPlaceImageIndex: Int = 0
    
    
    // MARK: - Public Methods
    //Load the Google Places API keys from APIKeys.plist
    public func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {
            NSLog("Error - Could not find APIKeys.plist.")
            return
        }
        keys = NSDictionary(contentsOfFile: path)!
    }
    
    
    //This method gets the current location of the user and sets currentPlace
    public func setCurrentExactPlace(completion: @escaping PlaceResult) {
        var placeFindComplete: Bool = false
        placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                NSLog("Current Place error: \(error!.localizedDescription)")
                
                placeFindComplete = true
                completion(true, nil)
                return
            }
            
            guard let thisPlaceLikelihoods = placeLikelihoods else {
                completion(true, nil)
                return
            }
            guard let firstPlaceLikelihoodFound = thisPlaceLikelihoods.likelihoods.first else {
                completion(true, nil)
                return
            }

            let placeToReturn: Place = Place(place: firstPlaceLikelihoodFound.place)
            
            placeFindComplete = true
            completion(true, placeToReturn)
        })

        if (!placeFindComplete) {
            completion(false, nil)
        }
    }
    
    
    //Set the general area of the location (better chances of finding pictures)
    public func setGeneralLocalePlace(completion: @escaping PlaceResult) {
        NSLog("IN FUNC SETGENERALLOCALEPLACE...")

        var placeFindComplete: Bool = false
        
        let generalLocaleString: String = currentPlace?.getGeneralLocaleString() ?? ""
        NSLog("GENERALLOCALESTRING IS ...", generalLocaleString)

        //Get the place ID of the general area so that we can grab an image of the city
        let placeIDOfGeneralLocale: String? = getPlaceIDOfGeneralLocale(generalLocaleQueryString: generalLocaleString)
        
        //Some places, like Lake Superior (47, -90) do not return a general locale string because it only has a formatted string of type natural_feature
        //In that case, set the general locale to the exact location
        guard let thisPlaceIDOfGeneralLocale: String = placeIDOfGeneralLocale else {
            NSLog("PLACEIDOFGENERALLOCALE WAS NIL. RETURNING THE CURRENTPLACE INSTEAD OF THE GENERAL LOCALE.")

            let placeToReturn: Place? = currentPlace
            completion(true, placeToReturn)
            return
        }

        NSLog("JUST GOT PLACEIDOFGENERALLOCALE.  IT IS \(placeIDOfGeneralLocale)")

        placesClient?.lookUpPlaceID(thisPlaceIDOfGeneralLocale, callback: { (place, error) -> Void in
            guard error == nil else {
                NSLog("Error - General Locale Place lookup error: \(error!.localizedDescription)")
                
                placeFindComplete = true
                completion(true, nil)
                return
            }
            guard let thisPlace = place else {
                NSLog("Error - the data received does not conform to Place class.")
                
                placeFindComplete = true
                completion(true, nil)
                return
            }
            
            placeFindComplete = true
            
            let placeToReturn: Place = Place(place: thisPlace)
            
            completion(true, placeToReturn)
        })
        if (!placeFindComplete) {
            completion(placeFindComplete, nil)
        }
    }
    
    
    //This method finds a photo of the general locale
    public func setPhotosOfGeneralLocale(size: CGSize, scale: CGFloat, completion: @escaping Result) {
        guard let _ = generalLocalePlace else {
            NSLog("Not loading a photo since place of general area was nil...")
            completion(true)
            return
        }
        guard let thisGMSPlace = generalLocalePlace?.gmsPlace else {
            NSLog("Not loading a photo since GMS place of general area was nil...")
            completion(true)
            return
        }
        setPhotoMetaData(placeIDOfGeneralLocale: thisGMSPlace.placeID) { (photoMetaDataFound) -> () in
            if (photoMetaDataFound) {
                self.setImagesArrayForMetadata(size: size, scale: scale) { (imageFound) -> () in
                    if (imageFound) {
                        completion(true)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Private Methods
    
    //This method takes a general area string (such as "Atlanta, Georgia, United States") and gets a place ID for that area
    private func getPlaceIDOfGeneralLocale(generalLocaleQueryString: String?) -> String? {
        NSLog("IN FUNC GETPLACEIDOFGENERALLOCALE...")

        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        let queryString = generalLocaleQueryString ?? ""
        let googlePlacesKeyString: String = keys["GooglePlacesAPIKeyWeb"] as? String ?? ""
        var placeTextSearchURL: String = baseURL + "textsearch/json?query=" + queryString + "&key=" + googlePlacesKeyString

        placeTextSearchURL = placeTextSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if (googlePlacesKeyString == "") {
            NSLog("ERROR - GOOGLEPLACESKEYSTRING IS EMPTY...")
        }
        
        NSLog("PLACETEXTSEARCHURL IS /(placeTextSearchURL)")
        
        let session = URLSession.shared
        let url = URL(string: placeTextSearchURL)!
        
        // Make call to URL. Handle it in a completion handler.
        session.dataTask(with: url as URL, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            //Ensure the  response isn't an error
            guard (error == nil && data != nil) else {
                NSLog("ERROR - FAILED TO DOWNLOAD PLACE DATA - ", error?.localizedDescription ?? "no error available")

                completionHandlerCodeComplete = true
                return
            }
            guard let thisURLResponse = response as? HTTPURLResponse else {
                NSLog("ERROR - NO RESPONSE RECEIVED FROM GOOGLE PLACES API...")
                
                completionHandlerCodeComplete = true
                return
            }
            guard thisURLResponse.statusCode == 200 else {
                NSLog("Error - Not a 200 (successful) response")
                NSLog("ERROR - NOT A SUCCESSFUL RESPONSE - ", thisURLResponse.statusCode)

                completionHandlerCodeComplete = true
                return
            }
            let json = JSON(data: data!)
            
            let error: String = json["error_message"].string ?? ""
            NSLog("JSON ERROR (IF ANY) IS - \(error)")
            
            placeID = json["results"][0]["place_id"].string
            NSLog("PLACE ID (IF ANY) IS - \(placeID)")
            
            completionHandlerCodeComplete = true
        }).resume()
        
        while (!completionHandlerCodeComplete) {
            //NSLog("Waiting on the photo reference to retrieve...")
        }
        NSLog("RETURNING PLACE ID...")
        return placeID
    }
    
    
    //Retrieve photo metadata for general locale place
    private func setPhotoMetaData(placeIDOfGeneralLocale: String?, completion: @escaping Result) {
        var photoMetaDataFindComplete: Bool = false
                
        guard let currentPlaceID: String = placeIDOfGeneralLocale else {
            NSLog("Error - Place ID of general locale is nil.")
            photoMetaDataFindComplete = true
            completion(true)
            return
        }
        
        placesClient?.lookUpPhotos(forPlaceID: currentPlaceID) { (photos, error) -> Void in
            guard (error == nil) else {
                NSLog("Error loading photo from Google API: \(error?.localizedDescription)")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            guard let photosList = photos else {
                NSLog("Error - Photos returned from lookup are nil.")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            guard let _ = self.generalLocalePlace else {
                NSLog("Error - the current general locale place was nil.")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            if (!photosList.results.isEmpty) {
                self.generalLocalePlace?.photoMetaDataArray = (photos?.results)!
            }
            photoMetaDataFindComplete = true
            completion(true)
        }
        if (!photoMetaDataFindComplete) {
            completion(false)
        }
    }
    
    
    //Retrieve image based on place metadata
    private func setImagesArrayForMetadata(size: CGSize, scale: CGFloat, completion: @escaping Result) {
        var imageArrayFindComplete: Bool = false
        
        guard let thisGeneralLocalePlace = generalLocalePlace else {
            NSLog("Error setting images array for metadata. Place was nil.")
            
            imageArrayFindComplete = true
            completion(true)
            return
        }
        
        let photoArrayCount: Int = generalLocalePlace?.photoMetaDataArray.count ?? 0
        
        if (!thisGeneralLocalePlace.photoMetaDataArray.isEmpty) {
            for photoMetaDataIndex in 0..<photoArrayCount {
                setImageForMetaData(index: photoMetaDataIndex, size: size, scale: scale) { imageSet -> () in
                    if (imageSet) {
                        //If on the last element, mark completion as true
                        if (photoMetaDataIndex == photoArrayCount - 1) {
                            imageArrayFindComplete = true
                            completion(true)
                        }
                        completion(imageArrayFindComplete)
                    }
                }
            }
        }
        else {
            //photoMetaDataArray was empty.  Exiting out of this function
            imageArrayFindComplete = true
            completion(imageArrayFindComplete)
        }
        if (!imageArrayFindComplete) {
            completion(imageArrayFindComplete)
        }
    }
    
    
    //Cycle through photoMetaDataArray and perform a request for each image and populate photoArray with UIImages
    private func setImageForMetaData(index: Int, size: CGSize, scale: CGFloat, completion: @escaping Result) {
        var imageFindComplete: Bool = false
        
        if (generalLocalePlace?.photoMetaDataArray[index] != nil) {
            placesClient?.loadPlacePhoto((generalLocalePlace?.photoMetaDataArray[index])!, constrainedTo: size, scale: scale) { (photo, error) -> Void in
                if let error = error {
                    NSLog("Error loading image for metadata: \(error.localizedDescription)")
                    
                    imageFindComplete = true
                    completion(true)
                    return
                } else {
                    self.generalLocalePlace?.photoArray.append(photo)
                    
                    imageFindComplete = true
                    completion(true)
                }
            }
        }
        else {
            //GeneralLocalePhotoMetaData for this index was nil.  Mark complete and exit out of this function.
            imageFindComplete = true
        }
        if (!imageFindComplete) {
            completion(imageFindComplete)
        }
    }
}
