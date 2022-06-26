//
//  CLLocationCoordinate2D+Extension.swift
//  MyPath
//
//  Created by Illia Kniaziev on 26.06.2022.
//

import MapKit

extension CLLocationCoordinate2D {
    func distance(to end: CLLocationCoordinate2D) -> Double {
        return sqrt(pow(latitude - end.latitude, 2) + pow(longitude - end.longitude, 2))
    }
}
