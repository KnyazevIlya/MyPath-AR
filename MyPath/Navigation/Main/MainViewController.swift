//
//  ViewController.swift
//  MyPath
//
//  Created by Illia Kniaziev on 12.05.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    private var arButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.tinted()
        
        config.background.strokeColor = .systemBlue
        config.background.strokeWidth = 1
        config.title = "AR Session"
        config.imagePadding = 10
        config.image = UIImage(systemName: "arkit")
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(arButton)
        NSLayoutConstraint.activate([
            arButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        arButton.addAction(UIAction(handler: openARScreen(_:)), for: .touchUpInside)
    }
    
    func openARScreen(_ action: UIAction) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let arVC = storyboard.instantiateViewController(withIdentifier: "ARVC")
        navigationController?.pushViewController(arVC, animated: true)
    }
    
}

