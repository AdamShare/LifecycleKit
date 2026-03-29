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

@testable import Lifecycle
import SwiftUI
import XCTest

final class RootLifecycleTests: XCTestCase {

    let delegate = Delegate()

    @MainActor func testDelegates() {
        XCTAssertFalse(delegate.rootLifecycleOwner.isActive)

        delegate.activateRoot()

        XCTAssertTrue(delegate.rootLifecycleOwner.isActive)

        delegate.deactivateRoot()

        XCTAssertFalse(delegate.rootLifecycleOwner.isActive)
    }
}

#if os(macOS)

    final class Delegate: NSObject, NSApplicationDelegate, RootLifecycle {
        var rootLifecycleOwner: LifecycleOwner = TestLifecycleOwner()
    }

#else

    final class Delegate: NSObject, UISceneDelegate, RootLifecycle {
        var rootLifecycleOwner: LifecycleOwner = TestLifecycleOwner()
    }

#endif
