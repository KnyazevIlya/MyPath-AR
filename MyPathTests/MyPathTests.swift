//
//  MyPathTests.swift
//  MyPathTests
//
//  Created by Illia Kniaziev on 26.06.2022.
//

import XCTest
import MapKit
@testable import MyPath

class MyPathTests: XCTestCase {

    func testCLLocationCoordinate2DDistance1() {
        let startPoint = CLLocationCoordinate2D(latitude: 3, longitude: 2)
        let endPoint = CLLocationCoordinate2D(latitude: 7, longitude: 8)
        XCTAssertEqual(startPoint.distance(to: endPoint), sqrt(52), "distance between two point must be correct")
    }
    
    func testCLLocationCoordinate2DDistance2() {
        let startPoint = CLLocationCoordinate2D(latitude: -7, longitude: -4)
        let endPoint = CLLocationCoordinate2D(latitude: 17, longitude: 6)
        XCTAssertEqual(startPoint.distance(to: endPoint), 26, "distance between two point must be correct")
    }
    
}
