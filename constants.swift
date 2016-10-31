//
//  constants.swift
//  virtualTourist
//
//  Created by Arjun Baru on 22/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation


extension FlickrClient{
    
    struct Constants {
        
        static let ApiKey = "e021b1af2958bdd56637ea0eff855f4f"
        static let baseUrl = "https://api.flickr.com/services/rest/"
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    
    }
    struct parameterKey {
        static let method = "method"
        static let api_key = "api_key"
        static let safe_search = "safe_search"
        static let lat = "lat"
        static let lon = "lon"
        static let extras = "extras"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
        
    }
    
    struct parameterValues {
        static let method = "flickr.photos.search"
        static let safeSerach = "1"
        static let extras = "url_m"
        static let format = "json"
        static let nojsoncallback = "1"
    }
    
    struct jsonResponseKeys {
        static let photos = "photos"
        static let pages = "pages"
        static let page = "page"
        static let perpage = "per_page"
        static let photo = "photo" 
    }
    
}
