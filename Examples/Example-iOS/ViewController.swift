//
//  ViewController.swift
//  Example-iOS
//
//  Created by Jared Sinclair on 8/26/17.
//  Copyright © 2017 Black Pixel Luminance. All rights reserved.
//

import UIKit
import IAP

let store = Store<MyAppProduct>()

class ViewController: UIViewController {
    
    @IBOutlet weak var freePlanInfoLabel: UILabel!
    @IBOutlet weak var standardPlanInfoLabel: UILabel!
    @IBOutlet weak var proPlanInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.when(.IAPStoreDidRefresh) { _ in
            print("Store<MyAppProduct> did finish attempting to restore purchases:")
            self.updatePlanInfo()
        }
        
        NotificationCenter.when(.IAPUserEvent) { notification in
            print("User Event: \n \(String(describing: notification.userInfo))")
        }
        
        print("Is app purchased: \(store.isAppPurchased)")
        updatePlanInfo()
    }
    
    
    func updatePlanInfo() {
    
        let trialAvailability = store.availability(for: .freeTrial)
        freePlanInfoLabel.text = "Free Plan is : \(trialAvailability)"
        
        let standardAvailability = store.availability(for: .standard)
        standardPlanInfoLabel.text = "Standard Plan is : \(standardAvailability)"

        let proAvailability = store.availability(for: .standard)
        proPlanInfoLabel.text = "Pro Plan is : \(proAvailability)"
    
        switch store.availability(for: .freeTrial) {
        case .expired:
            showExpiredFreeTrialAlert()
        default:
            break
            // no-op
        }
    }
    
    @IBAction func restorePurchases(_ sender: AnyObject) {
        store.restorePurchases()
    }
    
    @IBAction func upgrade(_ sender: AnyObject) {
        store.presentAvailablePurchases(from: self, completion: { wasCancelled in
            if wasCancelled {
                print("User Cancelled")
            } else {
                print("Completed")
            }
        })
    }
    
    private func showExpiredFreeTrialAlert() {
        let alert = UIAlertController(title: "Free Trial Expired", message: "Your trial has ended", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
        alert.addAction(UIAlertAction(title: "Upgrade Now", style: .default) { action in
            self.upgrade(self)
        })
        
        present(alert, animated: true, completion: nil)
    }
}
