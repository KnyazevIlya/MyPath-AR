//
//  UIImage+Extension.swift
//  MyPath
//
//  Created by Illia Kniaziev on 12.05.2022.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
