//
//  InformationViewController.swift
//  SquareMe
//
//  Created by Etjen Ymeraj on 1/24/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    var venue: Venue?
    @IBOutlet weak var tipTextView: UITextView!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var similarVenuesTableView: UITableView!
    
    @IBOutlet weak var venueImage: UIImageView!
    let flickrClient = FlickrClient(apiKey: "c584f9911f13b519f14b9ca9f4e1e7da")
    var venueImages = [VenueImages]()
    var coordinate: Coordinate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupUI(){
            if let venue = venue{
                title = venue.name
                checkInLabel.text = "CheckIns - \(venue.checkins)"
                if !venue.tips.isEmpty {
                tipTextView.text = venue.tips[Int(arc4random_uniform(UInt32(venue.tips.count)))]
                }
                if !venue.similarVenues.isEmpty {
                }
            }
    }
    
    @IBAction func anotherTipButtonTapped(_ sender: Any) {
        if let venue = venue{
        if !venue.tips.isEmpty {
            tipTextView.text = venue.tips[Int(arc4random_uniform(UInt32(venue.tips.count)))]
            }
        }
    }
    
    @IBAction func grabByNameButtonTapped(_ sender: Any) {
        if let venue = venue{
            self.venueImages.removeAll()
            self.flickrClient.fetchPhotos(nil, text: venue.name, completion: { result in
                switch result {
                case .success(let images):
                    self.venueImages = images
                    self.fetchImage(imageURLString: images[Int(arc4random_uniform(UInt32(self.venueImages.count)))].imageURL)
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    @IBAction func grabByCoordinateButtonTapped(_ sender: Any) {
        self.venueImages.removeAll()
        self.flickrClient.fetchPhotos(bboxString(latitude: coordinate?.latitude, longitude: coordinate?.longitude), text: nil, completion: { result in
            switch result {
            case .success(let images):
                self.venueImages = images
                self.fetchImage(imageURLString: images[Int(arc4random_uniform(UInt32(self.venueImages.count)))].imageURL)
            case .failure(let error):
                print(error)
            }
        })

    }
    
    func fetchImage(imageURLString: String){
        let imageURL = URL(string: imageURLString)
        if let imageData = try? Data(contentsOf: imageURL!) {
            performUIUpdatesOnMain {
                self.venueImage.image = UIImage(data: imageData)
            }
        }
    }
    //A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched.
    private func bboxString(latitude: Double?, longitude: Double?) -> String{
        //ensure bbox is bounded by minimum and maximums
        if let latitude = latitude, let longitude = longitude{
            //minimums
            let minimumLon = max(longitude - Flickr.DefaultValues.SearchBBoxHalfWidth, Flickr.DefaultValues.SearchLonRange.0)
            let minimumLat = max(latitude - Flickr.DefaultValues.SearchBBoxHalfHeight, Flickr.DefaultValues.SearchLatRange.0)
            //maximums
            let maximumLon = min(longitude + Flickr.DefaultValues.SearchBBoxHalfWidth, Flickr.DefaultValues.SearchLonRange.1)
            let maximumLat = min(latitude + Flickr.DefaultValues.SearchBBoxHalfHeight, Flickr.DefaultValues.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        }else{
            return "0,0,0,0"
        }
    }
}
extension InformationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let venue = venue{
        return venue.similarVenues.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "similarCell", for: indexPath)
        if let venue = venue{
        let row = venue.similarVenues[indexPath.row]
        cell.textLabel?.text = row
        }
        
        return cell
    }
}
