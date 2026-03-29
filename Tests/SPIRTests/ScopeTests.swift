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
import NeedleFoundation
@testable import SPIR
import XCTest

final class ScopeTests: XCTestCase {
    @MainActor func testNeedleSharedScope() {
        __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->BootstrapComponent") { component in
            return EmptyDependencyProvider(component: component)
        }

        let component = BootstrapComponent()
        XCTAssertEqual(component.scopeLifecycle, component.scopeLifecycle)
        XCTAssertEqual(component.viewLifecycle, component.viewLifecycle)
    }
}

extension BootstrapComponent: LifecycleOwner, ViewLifecycleOwner {}
