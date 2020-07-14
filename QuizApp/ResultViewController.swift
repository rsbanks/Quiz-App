//
//  ResultViewController.swift
//  QuizApp
//
//  Created by Rebecca Banks on 06/06/2020.
//  Copyright © 2020 Rebecca Banks. All rights reserved.
//

import UIKit

protocol resultViewControllerProtocol {
    func dialogDismissed()
}

class ResultViewController: UIViewController {

    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var dialogView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    var titleText = ""
    var feedbackText = ""
    var buttonText = ""
    
    var delegate:resultViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the dialog box corners
        dialogView.layer.cornerRadius = 10
    }
    
    // Happens every time just before the dialogue appears
    override func viewWillAppear(_ animated: Bool) {
        
        // Now that the elements have loaded, set the text
        titleLabel.text = titleText
        feedbackLabel.text = feedbackText
        dismissButton.setTitle(buttonText, for: .normal)
        
        //Hide the UI elements
        dimView.alpha = 0
//        titleLabel.alpha = 0
//        feedbackLabel.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Fade in the elements
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {

            self.dimView.alpha = 1
//            self.titleLabel.alpha = 1
//            self.feedbackLabel.alpha = 1
            
        }, completion: nil)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        // Fade out the dim view then dismiss the popup
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.dimView.alpha = 0
            
        }) { (completed) in
            // Dismiss the popup
            self.dismiss(animated: true, completion: nil)
            
            // Notify delegate that the popup was dismissed
            self.delegate?.dialogDismissed()
        }
    }
}
