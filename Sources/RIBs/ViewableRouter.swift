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

/// The base protocol for all routers that own their own view controllers.
public protocol ViewableRouting: Routing {

    // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
    // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
    // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
    // base class logic without error.
    /// The base view controllable associated with this `Router`.
    var viewControllable: ViewControllable { get }
}

/// Base class of an `Interactor` that has a separate associated `Presenter` and `View`.
open class ViewableRouter<InteractorType, ViewControllerType>: Router<InteractorType>, ViewableRouting {

    /// The corresponding `ViewController` owned by this `Router`.
    public let viewController: ViewControllerType

    /// The base `ViewControllable` associated with this `Router`.
    public let viewControllable: ViewControllable

    /// Initializer.
    ///
    /// - parameter interactor: The corresponding `Interactor` of this `Router`.
    /// - parameter viewController: The corresponding `ViewController` of this `Router`.
    public init(interactor: InteractorType, viewController: ViewControllerType) {
        self.viewController = viewController
        guard let viewControllable = viewController as? ViewControllable else {
            fatalError("\(viewController) should conform to \(ViewControllable.self)")
        }

        self.viewControllable = viewControllable

        super.init(interactor: interactor)

        if let viewLifecycleOwner = viewController as? ViewLifecycleOwner {
            viewLifecycleOwner.viewLifecycle.setScopeLifecycle(scopeLifecycle)
            if let viewLifecycleSubscriber = self as? ViewLifecycleSubscriber {
                viewLifecycleOwner.viewLifecycle.subscribe(viewLifecycleSubscriber)
            }
        }
    }

    isolated deinit {
        if let viewLifecycleOwner = viewController as? ViewLifecycleOwner {
            expectDeallocateIfOwns(viewLifecycleOwner, inTime: .viewDisappearExpectation)
        }
    }
}
