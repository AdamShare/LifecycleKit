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
import CombineExtensions
import Foundation
@testable import Lifecycle
import XCTest

final class ScopeLifecycleTests: XCTestCase {
    @MainActor func testLifecycleState() {
        var events: [Subscribers.Event<LifecycleState, Never>] = []

        let cancellable: Cancellable = autoreleasepool {
            let scopeLifecycle = ScopeLifecycle()

            XCTAssertEqual(events, [])

            let cancellable = scopeLifecycle.lifecycleState.sink { event in
                events.append(event)
            }

            XCTAssertEqual(events, [.value(.initialized)])

            scopeLifecycle.activate(with: TestLifecycleOwner())

            XCTAssertEqual(events, [.value(.initialized),
                                    .value(.active)])

            scopeLifecycle.deactivate()

            XCTAssertEqual(events, [.value(.initialized),
                                    .value(.active),
                                    .value(.inactive)])

            scopeLifecycle.activate(with: TestLifecycleOwner())

            XCTAssertEqual(events, [.value(.initialized),
                                    .value(.active),
                                    .value(.inactive),
                                    .value(.active)])

            return cancellable
        }

        XCTAssertEqual(events, [.value(.initialized),
                                .value(.active),
                                .value(.inactive),
                                .value(.active),
                                .value(.inactive),
                                .value(.deinitialized),
                                .finished])

        cancellable.cancel()
    }
}
