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

final class InteractorTests: XCTestCase {

    @MainActor func testInteractor() {
        let interactor = TestInteractor()
        let router =  Router(interactor: interactor)
        XCTAssertEqual(interactor.scopeLifecycle, router.scopeLifecycle)

        var isActiveValue: Bool = true
        interactor
            .isActiveStream
            .prefix(1)
            .retained
            .sink(receiveValue:  { value in
                isActiveValue = value
            })

        XCTAssertFalse(isActiveValue)
        XCTAssertFalse(interactor.isActive)
        XCTAssertEqual(interactor.didBecomeActiveCount, 0)
        XCTAssertEqual(interactor.willResignActiveCount, 0)

        router.activate()

        interactor
            .isActiveStream
            .prefix(1)
            .retained
            .sink(receiveValue:  { value in
                isActiveValue = value
            })

        XCTAssertTrue(isActiveValue)
        XCTAssertTrue(interactor.isActive)
        XCTAssertEqual(interactor.didBecomeActiveCount, 1)
        XCTAssertEqual(interactor.willResignActiveCount, 0)

        router.deactivate()

        interactor
            .isActiveStream
            .prefix(1)
            .retained
            .sink(receiveValue:  { value in
                isActiveValue = value
            })

        XCTAssertFalse(isActiveValue)
        XCTAssertFalse(interactor.isActive)
        XCTAssertEqual(interactor.didBecomeActiveCount, 1)
        XCTAssertEqual(interactor.willResignActiveCount, 1)
    }

    #if !os(macOS)
        private lazy var presenter = LifecycleViewController()

        @MainActor func testPresentableInteractor() {
            let interactor = TestPresentableInteractor(presenter: presenter)
            XCTAssertNil(interactor.scopeLifecycle)
            XCTAssertNil(presenter.viewLifecycle.scopeLifecycle)
            XCTAssertEqual(interactor.presenter, presenter)
            XCTAssertTrue(presenter.viewLifecycle.subscribers.contains(interactor))

            XCTAssertEqual(interactor.viewDidLoadCount, 0)
            XCTAssertEqual(interactor.viewDidAppearCount, 0)
            XCTAssertEqual(interactor.viewDidDisappearCount, 0)

            presenter.viewLifecycle.viewDidLoad(with: presenter)

            XCTAssertEqual(interactor.viewDidLoadCount, 1)
            XCTAssertEqual(interactor.viewDidAppearCount, 0)
            XCTAssertEqual(interactor.viewDidDisappearCount, 0)

            presenter.viewLifecycle.isDisplayed = true

            XCTAssertEqual(interactor.viewDidLoadCount, 1)
            XCTAssertEqual(interactor.viewDidAppearCount, 1)
            XCTAssertEqual(interactor.viewDidDisappearCount, 0)

            presenter.viewLifecycle.isDisplayed = false

            XCTAssertEqual(interactor.viewDidLoadCount, 1)
            XCTAssertEqual(interactor.viewDidAppearCount, 1)
            XCTAssertEqual(interactor.viewDidDisappearCount, 1)
        }
    #endif
}

final class TestInteractor: Interactor {
    var didBecomeActiveCount: Int = 0
    override func didBecomeActive() {
        super.didBecomeActive()
        didBecomeActiveCount += 1
    }

    var willResignActiveCount: Int = 0
    override func willResignActive() {
        super.willResignActive()
        willResignActiveCount += 1
    }
}

#if !os(macOS)
    final class TestPresentableInteractor: PresentableInteractor<LifecycleViewController>, ViewLifecycleSubscriber {
        var viewDidLoadCount: Int = 0
        func viewDidLoad() {
            viewDidLoadCount += 1
        }

        var viewDidAppearCount: Int = 0
        func viewDidAppear() {
            viewDidAppearCount += 1
        }

        var viewDidDisappearCount: Int = 0
        func viewDidDisappear() {
            viewDidDisappearCount += 1
        }
    }
#endif
