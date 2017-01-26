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
