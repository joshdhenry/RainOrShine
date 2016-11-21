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
        //print("In func setAPIKeys...")
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        self.keys = NSDictionary(contentsOfFile: path)!
    }
    
    
    //This method gets the current location of the user and sets currentPlace
    public func setCurrentExactPlace(completion: @escaping PlaceResult) {
        //print("In function setCurrentExactPlace...")

        var placeFindComplete: Bool = false
        placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                
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
    
    
    public func setGeneralLocalePlace(completion: @escaping PlaceResult) {
        var placeFindComplete: Bool = false
        
        let generalLocaleString: String = currentPlace?.getGeneralLocaleString() ?? ""
        
        //Get the place ID of the general area so that we can grab an image of the city
        let placeIDOfGeneralLocale: String? = getPlaceIDOfGeneralLocale(generalLocaleQueryString: generalLocaleString)
        
        //Some places, like Lake Superior (47, -90) do not return a general locale string because it only has a formatted string of type natural_feature
        //In that case, set the general locale to the exact location
        if (placeIDOfGeneralLocale == nil) {
            placeFindComplete = true
            let placeToReturn: Place? = currentPlace
            
            completion(true, placeToReturn)
        }
        //Else, return the general locale place
        else {
            placesClient?.lookUpPlaceID(placeIDOfGeneralLocale!, callback: { (place, error) -> Void in
                guard error == nil else {
                    print("General Locale Place error: \(error!.localizedDescription)")
                    
                    placeFindComplete = true
                    completion(true, nil)
                    return
                }
                guard let thisPlace = place else {
                    print("Error - the data received does not conform to Place class.")
                    
                    placeFindComplete = true
                    completion(true, nil)
                    return
                }
                
                placeFindComplete = true
                
                let placeToReturn: Place = Place(place: thisPlace)
                
                completion(true, placeToReturn)
            })
        }
        if (!placeFindComplete) {
            completion(placeFindComplete, nil)
        }
    }
    
    
    //This method finds a photo of the general locale
    public func setPhotosOfGeneralLocale(size: CGSize, scale: CGFloat, completion: @escaping Result) {
        //print("In function setPhotosOfGeneralLocale...")
        guard let _ = generalLocalePlace else {
            print("Not loading a photo since place of general area was nil...")
            completion(true)
            return
        }
        guard let thisGMSPlace = generalLocalePlace?.gmsPlace else {
            print("Not loading a photo since GMS place of general area was nil...")
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
        //print("In function getPlaceIDOfGeneralLocale...(#2)")

        var placeID: String?
        var completionHandlerCodeComplete: Bool = false
        
        var placeTextSearchURL: String = baseURL + "textsearch/json?query=" + generalLocaleQueryString! + "&key=" + (keys["GooglePlacesAPIKeyWeb"] as! String)

        placeTextSearchURL = placeTextSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let session = URLSession.shared
        let url = URL(string: placeTextSearchURL)!
        
        // Make call. Handle it in a completion handler.
        session.dataTask(with: url as URL, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            //Ensure the  response isn't an error
            guard (error == nil && data != nil) else {
                print("Error - failed to download place data...")
                return
            }
            guard let thisURLResponse = response as? HTTPURLResponse,
                thisURLResponse.statusCode == 200 else {
                    print("Not a 200 (successful) response")
                    completionHandlerCodeComplete = true
                    return
            }
            let json = JSON(data: data!)
            
            placeID = json["results"][0]["place_id"].string
            
            completionHandlerCodeComplete = true
        }).resume()
                
        while (!completionHandlerCodeComplete) {
            //print("Waiting on the photo reference to retrieve...")
        }
        return placeID
    }
    
    
    //Retrieve photo metadata for place
    private func setPhotoMetaData(placeIDOfGeneralLocale: String?, completion: @escaping Result) {
        //print("In function setPhotoMetaDataForLocation...(#3)")
        
        var photoMetaDataFindComplete: Bool = false
        
        placesClient?.lookUpPhotos(forPlaceID: placeIDOfGeneralLocale!) { (photos, error) -> Void in
            guard (error == nil) else {
                print("Error loading photo from Google API: \(error?.localizedDescription)")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            guard let photosList = photos else {
                print("Error - Photos returned from lookup are nil.")
                photoMetaDataFindComplete = true
                completion(true)
                return
            }
            
            //print("Photos count is \(photosList.results.count)")
            
            guard let _ = self.currentPlace else {
                print("Error - the current place was nil.")
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
        //print("In function setImagesArrayForMetadata...(#4)")

        var imageArrayFindComplete: Bool = false
        
        guard let _ = generalLocalePlace else {
            print("Error setting images array for metadata. Place was nil.")
            
            imageArrayFindComplete = true
            completion(true)
            return
        }
        
        let photoArrayCount: Int = generalLocalePlace?.photoMetaDataArray.count ?? 0
        
        if (!(generalLocalePlace?.photoMetaDataArray.isEmpty)!) {
            for photoMetaDataIndex in 0..<photoArrayCount {
                setImageForMetaData(index: photoMetaDataIndex, size: size, scale: scale) { imageSet -> () in
                    if (imageSet) {
                        //If we are on the last element, mark completion as true
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
            print("photoMetaDataArray was empty.  Exiting out of this function...")
        
            imageArrayFindComplete = true
            completion(imageArrayFindComplete)
        }
        if (!imageArrayFindComplete) {
            completion(imageArrayFindComplete)
        }
    }
    
    
    //Cycle through photoMetaDataArray and perform a request for each image and populate photoArray with UIImages
    private func setImageForMetaData(index: Int, size: CGSize, scale: CGFloat, completion: @escaping Result) {
        print("In function setImageForMetadata...(#4)")

        var imageFindComplete: Bool = false
        
        if (generalLocalePlace?.photoMetaDataArray[index] != nil) {
            placesClient?.loadPlacePhoto((generalLocalePlace?.photoMetaDataArray[index])!, constrainedTo: size, scale: scale) { (photo, error) -> Void in
                if let error = error {
                    print("Error loading image for metadata: \(error.localizedDescription)")
                    
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
            //GeneralLocalePhotoMetaData for this index was nil.  Exiting out of this function.
            imageFindComplete = true
        }
        if (!imageFindComplete) {
            completion(imageFindComplete)
        }
    }
}
