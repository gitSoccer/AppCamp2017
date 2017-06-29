//
//  ViewController.swift
//  Cache Me If You Can
//
//  Created by “Camp on 6/21/17.
//  Copyright © 2017 Ethan Rosenfeld. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import GoogleSignIn

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{
    
    @IBOutlet weak var addMarkerButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var search: UISearchBar!
    
    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    var markerName = ""
    var currentLocation: CLLocation?
    var isUp: Bool = false
    var address: String = ""
    var arrayOfInts: [CLLocation] = []
    var encodedString = ""
    var swag = Dictionary<String, String>()
    //var imageCode = ""
    //var data: Data!
    //var decodedImage:UIImage!
    
    @IBAction func logOut(_ sender: UIBarButtonItem)
    {
        let firebaseAuth = Auth.auth()
        
        //        let user = firebaseAuth.currentUser
        //        user?.delete(completion: nil)
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            
            print("Signed Out")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        _ = self.navigationController!.popViewController(animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mapMarker") {
            let dest = segue.destination as! MapMarkerDetailViewController
            dest.location = currentLocation
        }
    }
    @IBAction func addMarker(_ sender: UIButton)
    {}
    @IBAction func searchPress(_ sender: UIBarButtonItem)
    {
        if(self.search.isHidden == true)
        {
            self.search.isHidden = false
        }
        else
        {
            self.search.isHidden = true
            search.endEditing(true)
        }
    }
    func buttonAni(button: UIButton, direction: Bool)
    {
        
        var position = button.frame
        if(direction == true)
        {
            position.origin.y = position.origin.y - 100
        }
        else
        {
            position.origin.y = position.origin.y + 100
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            button.frame = position
        })
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        address = self.search.text!
        self.processAddress(address: self.address)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        address = self.search.text!
        self.search.isHidden = true
        search.endEditing(true)
        self.processAddress(address: self.address)
    }
    func processAddress(address: String)
    {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler:
            {(placemarks, error) -> Void in
                if (!(placemarks == nil))
                {
                    if (placemarks?.count)! > 0
                    {
                        let placemark = placemarks![0] as CLPlacemark
                        let lat = placemark.location?.coordinate.latitude
                        let lon = placemark.location?.coordinate.longitude
                        //                        let placeMarkLocation = CLLocation(latitude: lat!, longitude: lon!)
                        self.centerMapAt(lat: lat!, lon: lon!)
                    }
                }
        })
    }
    func centerMapAt(lat: CLLocationDegrees, lon: CLLocationDegrees)
    {
        let center = CLLocationCoordinate2DMake(lat, lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let visibleRegion = MKCoordinateRegionMake(center, span)
        
        self.mapView.setRegion(visibleRegion, animated: true)
    }
    
    func setAnnotationAt(location: CLLocation, title: String, subtitle: String)
    {
        let center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = center.coordinate
        
        annotation.title = title
        annotation.subtitle = subtitle
        
        self.mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) { return nil }
        let reuseID = "marker"
        //annotation.
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if v != nil {
            v?.annotation = annotation
            v?.image = ImageManipulation.prepareImageAsAnnotation(image: decode(data: swag[annotation.title!!]!), newWidth: (50))
        } else {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            if swag[annotation.title!!] != nil
            {
                v?.image = ImageManipulation.prepareImageAsAnnotation(image: decode(data: swag[annotation.title!!]!), newWidth: (50))
            }
        }
        return v
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.search.delegate = self
        ref.child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            self.mapView.removeAnnotations(self.mapView.annotations)
            let locDict = snapshot.value as? NSDictionary
            for x in (locDict?.allKeys)!
            {
                if String(describing: x) == "Default"{
                    continue
                }
                var title = ""
                let loc = locDict?[x] as! NSDictionary
                if loc.value(forKey: "lat") != nil && loc.value(forKey: "lon") != nil
                {
                    let lat = loc.value(forKey: "lat") as! CLLocationDegrees
                    let lon = loc.value(forKey: "lon") as! CLLocationDegrees
                    let location = CLLocation(latitude: lat, longitude: lon)
                    
                    let date = loc.value(forKey: "timeAccessed") as! String
                    title = loc.value(forKey: "title") as! String
                    if title != ""
                    {
                        self.setAnnotationAt(location: location, title: title, subtitle: date)
                    }
                }
                else
                {
                    print("no location found")
                }
                if let image = loc.value(forKey: "image")
                {
                    self.encodedString = (image as? String)!
                    self.swag[title] = self.encodedString
                }
                let user = loc.value(forKey: "user") as! String
                if  user == MyVariables.username
                {
                    if !MyVariables.titles.contains(loc.value(forKey: "title") as! String)
                    {
                        MyVariables.titles.append(loc.value(forKey: "title") as! String)
                        MyVariables.descriptions.append(loc.value(forKey: "description") as! String)
                        MyVariables.instructions.append(loc.value(forKey: "instructions") as! String)
                        MyVariables.images.append(self.decode(data: self.encodedString))
                    }
                }
            }
            
            
            print(self.mapView.annotations.count)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func encode(image: UIImage) -> String
    {
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let string = imageData.base64EncodedString(options: .lineLength64Characters)
        return string
    }
    func decode(data: String) -> UIImage
    {
        let dataDecoded : Data = Data(base64Encoded: data, options: .ignoreUnknownCharacters)!
        if let decodedImage:UIImage = UIImage(data: dataDecoded as Data)
        {
            return decodedImage
        }
        else {return UIImage(named:"Cristophe 8.5x11.png")!}
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tap(_:)))
        tap.delegate = self
        mapView.addGestureRecognizer(tap)
        mapView.delegate = self
        
        
        ref = Database.database().reference()
        
        let manipulatedImage = ImageManipulation.prepareImageAsAnnotation(image: UIImage(named: "Cristophe 8.5x11.png")!, newWidth: CGFloat(50))
        
        ref.child("locations").child("Default").setValue([
            "image" : encode(image: manipulatedImage),
            "user": "default",
            "timeAccessed": " ",
            "description": " ", //description
            "instructions": " ", //instructions
            "lat": 0,
            "lon": 0,
            "title": "default",
            ])
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        
        addMarkerButton.layer.shadowColor = UIColor.black.cgColor
        addMarkerButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        addMarkerButton.layer.shadowRadius = 5
        addMarkerButton.layer.shadowOpacity = 0.5
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        menuButton.layer.shadowRadius = 5
        menuButton.layer.shadowOpacity = 0.5
        
        addMarkerButton.layer.cornerRadius = addMarkerButton.bounds.size.width/2
        menuButton.layer.cornerRadius = addMarkerButton.bounds.size.width/2
        self.search.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        //self.window.
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "DamascusBold", size: 30)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        if(self.search.isHidden == true)
        {
            if(isUp == false)
            {
                buttonAni(button: addMarkerButton, direction: true)
                buttonAni(button: menuButton, direction: true)
                isUp = true
            }
            else
            {
                isUp = false
                buttonAni(button: addMarkerButton, direction: false)
                buttonAni(button: menuButton, direction: false)
            }
        }
        else
        {
            self.hideKeyboardWhenTappedAround()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue:CLLocationCoordinate2D = manager.location?.coordinate {
            
            currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        self.search.endEditing(true)
        self.search.isHidden = true
    }
}

