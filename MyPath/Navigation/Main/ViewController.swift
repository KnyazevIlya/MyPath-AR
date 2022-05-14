//
//  ViewController.swift
//  MyPath
//
//  Created by Illia Kniaziev on 12.05.2022.
//

import ARKit
import CoreLocation
import MapboxSceneKit
import SceneKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var arButton: UIButton! {
        didSet {
            var config = UIButton.Configuration.tinted()
            
            config.background.strokeColor = .systemBlue
            config.background.strokeWidth = 0.5
            config.title = "AR Session"
            config.imagePadding = 10
            config.image = UIImage(named: "arGlyph")?
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.systemBlue)
                .resized(to: CGSize(width: 40, height: 40))
            
            arButton.configuration = config
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func openARScreen() {
        
    }

}

