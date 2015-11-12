//
//  ViewController.swift
//  FlickFinder2
//
//  Created by Rachel Schifano on 11/5/15.
//  Copyright © 2015 schifano. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

// Define global constants
let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "9da6823efae700d900b5d6c1a6d7703c"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"

class ViewController: UIViewController {
    // MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("Initialize the tapRecognizer in viewDidLoad")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("Add the tapRecognizer and subscribe to keyboard notifications in viewWillAppear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("Remove the tapRecognizer and unsubscribe from keyboard notifications in viewWillDisappear")
    }
    
    // MARK: Show/Hide Keyboard
    func addKeyboardDismissRecognizer() {
        print("Add the recognizer to dismiss the keyboard")
    }
    
    func removeKeyboardDismissRecognizer() {
        print("Remove the recognizer to dismiss the keyboard")
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        print("End editing here")
    }
    
    func subscribeToKeyboardNotifications() {
        print("Subscribe to the KeyboardWillShow and KeyboardWillHide notifications")
    }
    
    func unsubscribeToKeyboardNotifications() {
        print("Unsubscribe to the KeyboardWillShow and KeyboardWillHide notifications")
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Shift the view's frame up so that controls are shown")
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Shift the view's frame down so that the view is back to its original placement")
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        print("Get and return the keyboard's height from the notification")
        return 0.0
    }
    
    @IBAction func searchPhotosByPhraseButtonTouchUp(sender: AnyObject) {
        /* 1. Hardcode the Arguments */
        let methodArguments: [String: String!] = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "text": "baby asian elephant",
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        /* 2. Call Flickr API with the given arguments */
        getImageFromFlickrBySearch(methodArguments)
    }
    
    // MARK: Flickr API
    // FIXME: Why is it AnyObject?
    func getImageFromFlickrBySearch(methodArguments: [String: AnyObject]) {
        /* 3. Get the shared NSURLSession to facilitate network activity */
        let session = NSURLSession.sharedSession()
        
        /* 4. Create the NSURLRequest using properly escaped URL */
        let urlString: String = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        /* 5. Create NSURLSessionDataTask and completion handler */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a sucessful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Status code: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* If there is data, parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* 1. Get the photos dictionary */
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(parsedResult)")
                return
            }
            
            /* 2. Determine total number of photos */
            /* GUARD: Is the "total" key in the dictionary */
            guard let totalPhotos = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key total in \(photosDictionary)")
                return
            }
            
            /* 3. If photos are returned, let's grab one! */
            if totalPhotos > 0 {
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
            
                /* 4. Get a random index, and pick a random photo's dictionary */
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photosDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                
                /* 5. Prepare the UI updates */
                let photoTitle = photosDictionary["title"] as? String /* non-fatal */
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photosDictionary["url_m"] as? String else {
                    print("Cannot find key 'url_m' in \(photosDictionary)")
                    return
                }
                
                let imageURL = NSURL(string: imageUrlString)
                
                /* 6. Update the UI on the main thread */
                if let imageData = NSData(contentsOfURL: imageURL!) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.defaultLabel.alpha = 0.0
                        self.photoImageView.image = UIImage(data: imageData)
                        self.photoTitleLabel.text = "\(photoTitle!)"
                        print("Success, update the UI here...")
                        print(photoTitle)
                        print(imageData)
                    })
                } else {
                    print("Image does not exist at \(imageURL)")
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.photoTitleLabel.text = "No Photos Found. Search Again"
                    self.defaultLabel.alpha = 1.0
                    self.photoImageView.image = nil
                    print("No Photos Found. Search Again")
                })
            }
        }
        task.resume(); // resume? where was it suspended?
    }
    
    // MARK: Escape HTML Parameters
    func escapedParameters(parameters: [String: AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    @IBAction func searchPhotosByLatLonButtonTouchUp(sender: AnyObject) {
        print("Will implement this function in a later step...")
    }
}