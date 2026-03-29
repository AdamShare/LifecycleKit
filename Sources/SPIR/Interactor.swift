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
import Lifecycle

/// The base protocol for all interactors.
public protocol Interactable: LifecycleOwner, InteractableConvertible {}

public protocol InteractableConvertible {
    var interactable: Interactable { get }
}

public extension Interactable {
    var interactable: Interactable { self }
}

/// An `Interactor` defines a unit of business logic that corresponds to a interactable unit.
///
/// An `Interactor` has a lifecycle driven by its owner  When the corresponding interactable is attached to its
/// parent, its interactor becomes active. And when the interactable is detached from its parent, its `Interactor` resigns
/// active.
///
/// An `Interactor` should only perform its business logic when it's currently active.
open class Interactor: BaseLifecycleOwner, Interactable {}

/// Interactor subclass that  `Router`
open class RoutingInteractor<RouterType>: Interactor {
    public let router: RouterType

    /// Creates an `Interactor` with a `Router` from a local or parent scope.
    public init(scopeLifecycle: ScopeLifecycle,
                router: RouterType)  {
        self.router = router
        super.init(scopeLifecycle: scopeLifecycle)
    }

    /// Convenience init for a `RouterType` that is provided at the local scope with a shared `ScopeLifecycle`.
    /// - warning: Initalizing with a `Router` that is not at the local scope risks error of trying to attach a parent scope as a child.
    public init(router: RouterType) {
        guard let routing = router as? Routing else {
            fatalError("\(router) does not conform to \(Routing.self)")
        }

        guard let scopeLifecycle = routing.scopeLifecycle else {
            fatalError("\(router).scopeLifecycle is nil")
        }

        self.router = router
        super.init(scopeLifecycle: scopeLifecycle)
    }
}

/// `Interactor` that provides a `View`
public protocol PresentableInteractable: Interactable, Presentable, PresentableInteractableConvertible {}

public protocol PresentableInteractableConvertible {
    var presentableInteractable: PresentableInteractable { get }
}

public extension PresentableInteractable {
    var presentableInteractable: PresentableInteractable { self }
}

/// Base class of an `Interactor` that has a separate associated `Presenter` and `View`.
open class PresentableInteractor<PresenterType>: Interactor, PresentableInteractable {
    public let presenter: PresenterType

    private let presentable: Presentable

    public var viewable: Viewable {
        return presentable.viewable
    }

    public var viewLifecycle: ViewLifecycle {
        return presentable.viewLifecycle
    }

    /// Initializer.
    ///
    /// - note: This holds a strong reference to the given `Presenter`.
    ///
    /// - parameter presenter: The presenter associated with this `Interactor`.
    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle(),
                presenter: PresenterType)
    {
        self.presenter = presenter
        guard let presentable = presenter as? Presentable else {
            fatalError("\(presenter) must conform to \(Presentable.self)")
        }

        self.presentable = presentable
        super.init(scopeLifecycle: scopeLifecycle)

        if let lifecycleSubscriber = presenter as? LifecycleSubscriber {
            scopeLifecycle.subscribe(lifecycleSubscriber)
        }

        if let viewLifecycleSubscriber = self as? ViewLifecycleSubscriber {
            viewLifecycle.subscribe(viewLifecycleSubscriber)
        }

        viewLifecycle.setScopeLifecycle(scopeLifecycle)
    }

    isolated deinit {
        expectDeallocateIfOwns(presenter as AnyObject, inTime: .viewDisappearExpectation)
    }
}

public extension PresentableInteractable {
    var presentable: Presentable {
        return self
    }
}

open class PresentableRoutingInteractor<PresenterType, RouterType>: PresentableInteractor<PresenterType> {
    public let router: RouterType

    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle(),
                presenter: PresenterType,
                router: RouterType)
    {
        guard let routing = router as? Routing else {
            fatalError("\(router) does not conform to \(Routing.self)")
        }

        routing.scopeLifecycle = scopeLifecycle
        self.router = router
        super.init(scopeLifecycle: scopeLifecycle,
                   presenter: presenter)
    }

    isolated deinit {
        expectDeallocateIfOwns(router as AnyObject)
    }
}
