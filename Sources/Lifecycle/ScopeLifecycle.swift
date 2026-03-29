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

/// Internalizes lifecycle management.
public final class ScopeLifecycle: LifecyclePublisher, ObjectIdentifiable {
    public var lifecycleState: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return $state.removeDuplicates()
    }

    public var isActive: Bool {
        return state == .active
    }

    weak var parent: ScopeLifecycle?
    weak var owner: LifecycleOwner? {
        didSet {
            if let owner = owner, let oldValue = oldValue, owner !== oldValue {
                assertionFailure("Already an owner for this lifecycle: \(oldValue). \(ScopeLifecycle.self)s should only subscribe to a single \(LifecycleOwner.self). New value: \(owner)")
            }
        }
    }

    public init() {}

    isolated deinit {
            if isActive {
                deactivate()
            }

            for child in children {
                detachChild(child)
            }

            state = .deinitialized

            LeakDetector.instance.expectDeallocate(objects: subscribers, inTime: .viewDisappearExpectation).retained.sink()
    }

    @DidSetPublished private var state: LifecycleState = .initialized

    @DidSetPublished var children: [LifecycleOwner] = []

    var subscribers = WeakSet<LifecycleSubscriber>()

    /// Activate this lifecycle scope including all children.
    func activate(with owner: LifecycleOwner) {
        self.owner = owner
        state = .active

        for lifecycleOwner in children where !lifecycleOwner.isActive {
            lifecycleOwner.activate()
        }
    }

    /// Deactivate this lifecycle scope including all children.
    func deactivate() {
        state = .inactive

        for lifecycleOwner in children where lifecycleOwner.isActive {
            lifecycleOwner.scopeLifecycle.deactivate()
        }
    }

    /// Attaches the given `LifecycleOwner` as a child.
    ///
    /// The child will activate if the receiver is active.
    /// Child activation may run logic that synchornously results in a call to detach before `attachChild` returns.
    /// Best practice is to ensure the return value is`true` before performing additional routing logic such as presenting views.
    ///
    /// - parameter child: The child `LifecycleOwner` to attach.
    /// - returns: Is `true` if child was successfully attached.
    @discardableResult
    func attachChild(_ child: LifecycleOwner) -> Bool {
        guard child.scopeLifecycle.parent != self else {
            return false
        }

        assert(child.scopeLifecycle != self, "Attempt to attach child: \(child), that is already managed at the local scope by \(self).")
        assert(child.scopeLifecycle.parent == nil, "Attempt to attach child: \(child), which is already attached as a child to \(child.scopeLifecycle.parent!).")

        children.append(child)
        child.scopeLifecycle.parent = self

        if state == .active {
            child.activate()
        }

        // Activate could run logic that removes the child before return.
        return child.scopeLifecycle.parent == self
    }

    /// Detaches the given `LifecycleOwner` from the tree.
    ///
    /// - parameter child: The child `LifecycleOwner` to detach.
    func detachChild(_ child: LifecycleOwner) {
        guard child.scopeLifecycle.parent == self else { return }
        child.scopeLifecycle.parent = nil

        let removed = children.removeAllByReference(child)
        if removed, child.isActive {
            child.scopeLifecycle.deactivate()
        }
    }
}

extension ScopeLifecycle {
    /// Monitoring publisher to view `LifecycleOwner` hierarchy for tests and debugging tools.
    var childrenChangedPublisher: RelayPublisher<Void> {
        return $children
            .flatMap { (children: [LifecycleOwner]) -> Publishers.MergeMany<RelayPublisher<Void>> in
                Publishers.MergeMany(children.lazy.map { child -> RelayPublisher<Void> in
                    child.scopeLifecycle.childrenChangedPublisher
                })
            }
            .eraseToAnyPublisher()
    }
}
