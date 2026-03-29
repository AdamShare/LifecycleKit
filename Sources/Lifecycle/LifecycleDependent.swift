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

@MainActor public protocol LifecycleDependent: LifecyclePublisher {
    /// Internal manager of lifecycle events.
    var scopeLifecycle: ScopeLifecycle? { get set }
}

public extension LifecycleDependent {
    var lifecycleState: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return scopeLifecycle?.lifecycleState ?? Just<LifecycleState>(.deinitialized).eraseToAnyPublisher().removeDuplicates()
    }
}

/// Base class to conform to `LifecycleDependent` observing with a weak reference to a `ScopeLifecycle`.
@MainActor open class ScopeLifecycleDependent: ObjectIdentifiable, LifecycleDependent, LifecycleOwnerRouting, LifecycleSubscriber {
    public weak var scopeLifecycle: ScopeLifecycle? {
        didSet {
            guard scopeLifecycle !== oldValue else { return }

            scopeLifecycle?.subscribe(self)
        }
    }

    public init() {}

    public init(scopeLifecycle: ScopeLifecycle) {
        self.scopeLifecycle = scopeLifecycle
        scopeLifecycle.subscribe(self)
    }

    open func didLoad(_ lifecyclePublisher: LifecyclePublisher) {}

    open func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {}

    open func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {}
}
