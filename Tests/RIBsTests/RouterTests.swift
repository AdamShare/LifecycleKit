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

import Combine
import Foundation
@testable import Lifecycle
@testable import RIBs
import XCTest

final class RouterTests: XCTestCase {

    @MainActor func testRouterBinding() {
        let interactor = TestInteractor()
        let router = Router(interactor: interactor)
        XCTAssertTrue(router.scopeLifecycle.subscribers.contains(router))
    }

    #if !os(macOS)
        @MainActor func testPresentableRouterBinding() {
            let interactor = TestInteractor()
            let presenter = LifecycleViewController()
            let router = TestPresentableRouter(interactor: interactor,
                                               viewController: presenter)
            XCTAssertTrue(router.scopeLifecycle.subscribers.contains(router))
            XCTAssertTrue(presenter.viewLifecycle.subscribers.contains(router))
        }
    #endif

}

#if !os(macOS)
    final class TestPresentableRouter: ViewableRouter<TestInteractor, LifecycleViewController>, ViewLifecycleSubscriber {
        func viewDidLoad() {}
        func viewDidAppear() {}
        func viewDidDisappear() {}
    }
#endif
