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

@MainActor public protocol LifecycleOwner: LifecyclePublisher {
    /// Internal manager of lifecycle events.
    var scopeLifecycle: ScopeLifecycle { get }
}

public extension LifecycleOwner {

    var lifecycleState: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return scopeLifecycle.lifecycleState
    }

    var isActive: Bool {
        return scopeLifecycle.isActive
    }

    func expectDeallocateIfOwns(_ ownedObject: AnyObject, inTime time: TimeInterval = .deallocationExpectation) {
        var objectScopeLifecycle: ScopeLifecycle?

        if let lifecycleOwner = ownedObject as? LifecycleOwner {
            objectScopeLifecycle = lifecycleOwner.scopeLifecycle
        } else if let lifecycleOwner = ownedObject as? LifecycleDependent {
            objectScopeLifecycle = lifecycleOwner.scopeLifecycle
        } else if let lifecycleOwner = ownedObject as? ViewLifecycleOwner {
            objectScopeLifecycle = lifecycleOwner.viewLifecycle.scopeLifecycle
        }

        if objectScopeLifecycle === scopeLifecycle {
            LeakDetector.instance.expectDeallocate(object: ownedObject, inTime: time).retained.sink()
        }
    }

    internal func activate() {
        scopeLifecycle.activate(with: self)
    }

    internal func deactivate() {
        scopeLifecycle.deactivate()
    }
}

/// Base class to conform to `LifecycleOwner` observing as the owner of a `ScopeLifecycle`.
open class BaseLifecycleOwner: ObjectIdentifiable, LifecycleOwner, LifecycleOwnerRouting, LifecycleSubscriber {
    public let scopeLifecycle: ScopeLifecycle

    /// Initializer.
    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle()) {
        self.scopeLifecycle = scopeLifecycle
        scopeLifecycle.subscribe(self)
    }

    open func didLoad(_ lifecyclePublisher: LifecyclePublisher) {}

    open func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {}

    open func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {}
}
