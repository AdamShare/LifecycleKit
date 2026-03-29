//
//  Copyright (c) 2021. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@testable import Lifecycle
import SwiftUI
import XCTest

final class ViewLifecycleTests: XCTestCase {
    @MainActor func testBind() {
        let viewLifecycleOwner = TestViewLifecycleOwner()

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 0)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 0)

        _ = EmptyView().tracked(by: viewLifecycleOwner)

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 0)

        _ = EmptyView().tracked(by: viewLifecycleOwner)

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 0)

        viewLifecycleOwner.viewLifecycle.isDisplayed = true

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 0)

        viewLifecycleOwner.viewLifecycle.isDisplayed = true

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 0)

        viewLifecycleOwner.viewLifecycle.isDisplayed = false

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 1)

        viewLifecycleOwner.viewLifecycle.isDisplayed = false

        XCTAssertEqual(viewLifecycleOwner.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleOwner.viewDidDisappearCount, 1)
    }

    @MainActor func testBindAgain_asserts() {
        let viewLifecycleOwner = TestViewLifecycleOwner()
        expectAssertionFailure {
            viewLifecycleOwner.viewLifecycle.subscribe(viewLifecycleOwner)
        }
    }
}

final class TestViewLifecycleOwner: BaseViewLifecycleOwner {
    var viewDidLoadCount: Int = 0
    override func viewDidLoad() {
        viewDidLoadCount += 1
    }

    var viewDidAppearCount: Int = 0
    override func viewDidAppear() {
        viewDidAppearCount += 1
    }

    var viewDidDisappearCount: Int = 0
    override func viewDidDisappear() {
        viewDidDisappearCount += 1
    }
}
