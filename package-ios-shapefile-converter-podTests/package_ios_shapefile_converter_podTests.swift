//
//  package_ios_shapefile_converter_podTests.swift
//  package-ios-shapefile-converter-podTests
//
//  Created by Ramirez, Luis Manuel on 11/03/21.
//

import XCTest
@testable import package_ios_shapefile_converter_pod

class package_ios_shapefile_converter_podTests: XCTestCase {

    func testPerformConversion() throws {
        GDALManager.shared.performConversion(of: "geojsonString", destinationFileName: "fileNameString")
    }

}
