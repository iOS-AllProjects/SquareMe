//
//  FlickrClient.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/26/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit

// MARK: - Flickr
enum Flickr: Endpoint {
        case venues(VenueEndpoint)
        
        enum VenueEndpoint: Endpoint {
            case search(apiKey: String, coordinate: String?, text: String?)
            
            // MARK: Venue Endpoint - Endpoint
            
            var baseURL: String {
                return "https://api.flickr.com"
            }
            
            var path: String {
                switch self {
                case .search: return "/services/rest"
                }
            }

            var parameters: [String : AnyObject] {
                switch self {
                case .search(let apiKey, let coordinate, let text):
                    
                    var parameters: [String: AnyObject] = [
                        Flickr.ParameterKeys.Method: Flickr.ParameterValues.SearchMethod as AnyObject,
                        Flickr.ParameterKeys.APIKey: apiKey as AnyObject,
                        Flickr.ParameterKeys.SafeSearch: Flickr.ParameterValues.UseSafeSearch as AnyObject,
                        Flickr.ParameterKeys.Extras: Flickr.ParameterValues.MediumURL as AnyObject,
                        Flickr.ParameterKeys.Format: Flickr.ParameterValues.ResponseFormat as AnyObject,
                        Flickr.ParameterKeys.NoJSONCallback: Flickr.ParameterValues.DisableJSONCallback as AnyObject
                    ]
                    
                    if let text = text {
                        parameters[ParameterKeys.Text] = text as AnyObject?
                    }
                    if let coordinate = coordinate{
                    parameters[ParameterKeys.BoundingBox] = coordinate as AnyObject? //this is what bboxString() returns
                    }
                    return parameters
                }
            }
    }

    
    // MARK: Flickr Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    // MARK: Flickr Parameter Values
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "api_key" //c584f9911f13b519f14b9ca9f4e1e7da
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
            
    struct DefaultValues {
        static let version = "20170301"
        static let limit = "1"
        static let searchRadius = "10000000"
        static let mode = "foursquare"
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Foursquare - Endpoint
    
    var baseURL: String {
        switch self {
        case .venues(let endpoint):
            return endpoint.baseURL
        }
    }
    
    var path: String {
        switch self {
        case .venues(let endpoint):
            return endpoint.path
        }
    }
    
    var parameters: [String : AnyObject] {
        switch self {
        case .venues(let endpoint):
            return endpoint.parameters
        }
    }
}

final class FlickrClient: APIClient {
    
    let configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    let apiKey: String
    
    init(configuration: URLSessionConfiguration, apiKey: String) {
        self.configuration = configuration
        self.apiKey = apiKey
    }
    
    convenience init(apiKey: String) {
        self.init(configuration: .default, apiKey: apiKey)
    }
    
func fetchPhotos(_ coordinate: String?, text: String?, completion: @escaping (APIResult<[VenueImages]>) -> Void) {
    
    let searchEndpoint = Flickr.VenueEndpoint.search(apiKey: self.apiKey, coordinate: coordinate, text: text)
    
    let endpoint = Flickr.venues(searchEndpoint)
    
    fetch(endpoint, parse: { json -> [VenueImages]? in

        guard let photosDictionary = json[Flickr.ResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Flickr.ResponseKeys.Photo] as? [[String:AnyObject]] else {
        return nil
        }
        
        return photoArray.flatMap { venueDict in
            return VenueImages(JSON: venueDict)
        }
        
        
    }, completion: completion)
}
}

