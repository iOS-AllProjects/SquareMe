//
//  ViewController.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/22/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import MapKit

//Key:
//c584f9911f13b519f14b9ca9f4e1e7da
//Secret:
//4713769335b62184

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController {
    //Mark: Properties
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController!
    var selectedPin: MKPlacemark?
    var coordinate = [Coordinate]()
    let foursquareClient = FoursquareClient(clientID: "IWZCIHF04SIEMQITSJLK0NNALQS5CJAN03BKUCS455UT5PZ4", clientSecret: "NACAQQUHN4DQXEJO2ZFD5YRUZNOBEYBCOSYKC5FLORZQILYH")
      var venues = [Venue]()
      var tips = [Tips]()
    //Mark: Outlets
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureLocationManager()
        configureSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func configureSearchController(){
        // Display search results in a separate view controller
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
        // Configure search controller
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = UIColor.white
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func getInformation(){
            performSegue(withIdentifier: "informationSegue", sender: nil)
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "informationSegue"{
            let infoVC = segue.destination as! InformationViewController
            infoVC.venue = venues[0]
            }
    }
}
//MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error.localizedDescription)")
    }
}

//Mark: - HandleMapSearch
extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        //add to Pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        self.coordinate.removeAll()
        self.coordinate = [Coordinate(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)]
        ////////
        self.foursquareClient.fetchVenue(coordinate[0], query: placemark.name!, completion: { result in
            switch result {
            case .success(let venues):
                self.venues = venues
                self.getTips(id: venues[0].id)
                self.getSimilarVenues(id: venues[0].id)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getTips(id: String){
        let url = URL(string: "https://api.foursquare.com/v2/venues/\(id)/tips?client_id=IWZCIHF04SIEMQITSJLK0NNALQS5CJAN03BKUCS455UT5PZ4&client_secret=NACAQQUHN4DQXEJO2ZFD5YRUZNOBEYBCOSYKC5FLORZQILYH&v=20170118&m=foursquare")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            let items = json["response"] as! [String:AnyObject]
            let tips = items["tips"] as! [String:AnyObject]
            let item = tips["items"] as! [[String:AnyObject]]
            for aItem in item {
                let tip = aItem
                self.venues[0].tips.append((tip["text"] as! String))
            }
        }
        
        task.resume()
    }
    
    func getSimilarVenues(id: String){
        let url = URL(string: "https://api.foursquare.com/v2/venues/\(id)/similar?client_id=5O53IDZJAWB12DFHH1WFEYL2I1I3L0BTYQPHZUGJZYFL5IO4&client_secret=DXVEG1PDN0NMSOOZRRLJTWXTAON4RUL3GJSXAZVVEKHP40A3&v=20170118&m=foursquare")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            let items = json["response"] as! [String:AnyObject]
            let similar = items["similarVenues"] as! [String:AnyObject]
            let places = similar["items"] as! [[String: AnyObject]]
            
            for place in places {
                let venue = place
                self.venues[0].similarVenues.append((venue["name"] as! String))
            }
        }
        
        task.resume()
    }
    }
//Mark:- MKMapViewDelegate
extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
            //information button
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            btn.addTarget(self, action: #selector(getInformation), for: .touchUpInside)
            //direction button
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "Direction_Icon"), for: .normal)
            button.addTarget(self, action: #selector(self.getDirections), for: .touchUpInside)
            annotationView?.leftCalloutAccessoryView = button
            }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "Info_Icon")
        annotationView!.image = pinImage
        return annotationView
            }
}
