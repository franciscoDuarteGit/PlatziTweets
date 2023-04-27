//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Inx on 13/04/23.
//

import UIKit

class WelcomeViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI(){
        loginButton.layer.cornerRadius = 20
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
