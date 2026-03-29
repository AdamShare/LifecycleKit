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

/// The lifecycle stages of a router scope.
public enum RouterLifecycle {

    /// Router did load.
    case didLoad
}

/// The scope of a `Router`, defining various lifecycles of a `Router`.
public protocol RouterScope: AnyObject {

    /// An publisher that emits values when the router scope reaches its corresponding life-cycle stages. This
    /// publisher completes when the router scope is deallocated.
    var lifecycle: AnyPublisher<RouterLifecycle, Never> { get }
}

/// The base protocol for all routers.
public protocol Routing: LifecycleOwner, RouterScope, LifecycleOwnerRouting {
    /// The base interactable associated with this `Router`.
    var interactable: Interactable { get }
}

/// The base class of all routers that does not own view controllers, representing application states.
///
/// A router acts on inputs from its corresponding interactor, to manipulate application state, forming a tree of
/// routers. A router may obtain a view controller through constructor injection to manipulate view controller tree.
/// The DI structure guarantees that the injected view controller must be from one of this router's ancestors.
/// Router drives the lifecycle of its owned `Interactor`.
///
/// Routers should always use helper builders to instantiate children routers.
open class Router<InteractorType>: BaseLifecycleOwner, Routing {
    /// The corresponding `Interactor` owned by this `Router`.
    public let interactor: InteractorType

    /// The base `Interactable` associated with this `Router`.
    public let interactable: Interactable

    /// Initializer.
    ///
    /// - parameter interactor: The corresponding `Interactor` of this `Router`.
    public init(interactor: InteractorType) {
        self.interactor = interactor
        guard let interactable = interactor as? Interactable else {
            fatalError("\(interactor) should conform to \(Interactable.self)")
        }
        self.interactable = interactable

        super.init()

        interactable.scopeLifecycle = scopeLifecycle
    }

    isolated deinit {
        expectDeallocateIfOwns(interactable as AnyObject)
    }

    override open func didLoad(_ lifecyclePublisher: LifecyclePublisher) {
        super.didLoad(lifecyclePublisher)
        self.didLoad()
    }

    /// The publisher that emits values when the router scope reaches its corresponding life-cycle stages.
    ///
    /// This publisher completes when the router scope is deallocated.
    public final var lifecycle: AnyPublisher<RouterLifecycle, Never> {
        return lifecycleState
            .filter { $0 == Lifecycle.LifecycleState.active }
            .map { _ in RouterLifecycle.didLoad }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    /// Called when the router has finished loading.
    ///
    /// This method is invoked only once. Subclasses should override this method to perform one time setup logic,
    /// such as attaching immutable children. The default implementation does nothing.
    open func didLoad() {
        // No-op
    }
}
