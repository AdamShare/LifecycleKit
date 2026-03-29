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
import SwiftUI
import XCTest

final class PresenterTests: XCTestCase {

    @MainActor func testPresenter() {
        let viewLifecycle = ViewLifecycle()
        let presenter = TestPresenter(viewLifecycle: viewLifecycle)
        testPresenterBinding(presenter: presenter, viewLifecycle: viewLifecycle)
        XCTAssertTrue(presenter.viewable is ViewProvider<ModifiedContent<TestPresenter.ContentView, TrackingViewModifier>>)
    }

    @MainActor func testInteractablePresenter() {
        let viewLifecycle = ViewLifecycle()
        let interactablePresenter = TestInteractablePresenter(viewLifecycle: viewLifecycle)
        testPresenterBinding(presenter: interactablePresenter, viewLifecycle: viewLifecycle)
        XCTAssertTrue(viewLifecycle.scopeLifecycle === interactablePresenter.scopeLifecycle)
        XCTAssertTrue(interactablePresenter.viewable is ViewProvider<ModifiedContent<TestView<TestInteractablePresenter>, TrackingViewModifier>>)
    }

    @MainActor private func testPresenterBinding<PresenterType: Presenting & ViewPresentable>(presenter: PresenterType, viewLifecycle: ViewLifecycle) {
        XCTAssertEqual(presenter.viewLifecycle, viewLifecycle)
        XCTAssertTrue(viewLifecycle.subscribers.contains(presenter))
    }
}

final class TestPresenter: Presenter, ViewPresentable, LifecycleSubscriber {
    func didLoad(_ lifecyclePublisher: LifecyclePublisher) {}

    func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {}

    func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {}

    struct ContentView: View, PresenterView {

        @ObservedObject var presenter: TestPresenter

        var body: some View {
            EmptyView()
        }
    }
}

final class TestInteractablePresenter: InteractablePresenter, ViewPresentable, PresentableInteractable {
    typealias ContentView = TestView<TestInteractablePresenter>
}
