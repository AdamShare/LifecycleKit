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

@MainActor public protocol LifecycleSubscriber: AnyObject {
    /// Called when the lifecycle did become active for the first time.
    ///
    /// This method is invoked only once. Subclasses should override this method to perform one time setup logic,
    /// such as attaching immutable children.
    func didLoad(_ lifecyclePublisher: LifecyclePublisher)

    /// The lifecycle did become active.
    ///
    /// - note: This method is driven by the attachment of this lifecycle's owner  Subclasses should override
    ///   this method to setup subscriptions and initial states.
    func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher)

    /// Callend when the `lifecycle` will resign the active state.
    ///
    /// This method is driven by the detachment of this lifecycle's owner  Subclasses should override this
    /// method to cleanup any resources and states of the `LifecycleSubscriber`.
    func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher)
}

public extension ScopeLifecycle {
    /// Binds to lifecycle states receiving on main thread.
    func subscribe(_ subscriber: LifecycleSubscriber) {
        #if DEBUG
        assert(Thread.isMainThread, "Subscribe from main thread only.")
        #endif
        
        if subscribers.contains(subscriber) {
            assertionFailure("Binding to \(subscriber) that has already been subscribes to. \(subscribers)")
        }

        subscribers.insert(subscriber)

        firstActive
            .receive(on: Schedulers.main)
            .autoCancel(self, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak self, weak subscriber] _ in
                guard let self = self, let subscriber = subscriber else { return }
                subscriber.didLoad(self)
            })

        isActivePublisher
            .drop(while: { !$0 })
            .receive(on: Schedulers.main)
            .autoCancel(self, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak self, weak subscriber] isActive in
                guard let self = self, let subscriber = subscriber else { return }
                if isActive {
                    subscriber.didBecomeActive(self)
                } else {
                    subscriber.didBecomeInactive(self)
                }
            })
    }
}
