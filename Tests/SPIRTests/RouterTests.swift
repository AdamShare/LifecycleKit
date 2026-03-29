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
@testable import SPIR
import XCTest

final class RouterTests: XCTestCase {

    @MainActor func testRouterBinding() {
        let scopeLifecycle = ScopeLifecycle()
        let router = Router(scopeLifecycle: scopeLifecycle)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(router))
    }

    @MainActor func testPresentableRouterBinding() {
        let scopeLifecycle = ScopeLifecycle()
        let presenter = TestPresenter()
        let router = TestPresentableRouter(scopeLifecycle: scopeLifecycle,
                                           presenter: presenter)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(router))
        XCTAssertTrue(presenter.viewLifecycle.subscribers.contains(router))
    }
}

final class TestPresentableRouter: PresentableRouter<TestPresenter>, ViewLifecycleSubscriber {
    func viewDidLoad() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
}
