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
@testable import MVVM
import NeedleFoundation
import SwiftUI
import XCTest

final class ScopeTests: XCTestCase {
    @MainActor func testViewType() {
        __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->TestComponent") { component in
            return EmptyDependencyProvider(component: component)
        }
        XCTAssertTrue(TestComponent().build() is LifecycleOwnerViewProvider<ModifiedContent<ModifiedContent<TestComponent.ContentView, TrackingViewModifier>, _EnvironmentKeyWritingModifier<TestComponent?>>>)
    }
}

final class TestComponent: BootstrapComponent, MVVMComponent {
    struct ContentView: View, ViewModelView {
        @ObservedObject var model: Model

        var body: some View {
            EmptyView()
        }

        final class Model: ObservableObject, ViewLifecycleOwner {
            var viewLifecycle: ViewLifecycle = ViewLifecycle()
        }
    }

    var viewModel: ContentView.Model {
        return weakShared {
            return ContentView.Model()
        }
    }

    var controller: Controller {
        return weakShared {
            Controller(viewModel: viewModel)
        }
    }

    final class Controller: ViewModelController<ContentView.Model> {}
}
