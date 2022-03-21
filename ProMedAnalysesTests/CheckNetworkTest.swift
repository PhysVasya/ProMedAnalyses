//
//  CheckNetworkTest.swift
//  ProMedAnalysesTests
//
//  Created by Vasiliy Andreyev on 20.03.2022.
//

@testable import ProMedAnalyses
import XCTest

class CheckNetworkTest: XCTestCase {

    var checkNetwork: CheckNetwork!
    
    override func setUp() {
        super.setUp()
        checkNetwork = CheckNetwork.shared
    }
    
    override func tearDown() {
        super.tearDown()
        checkNetwork = nil
    }
    

}
