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

public protocol ViewLifecycleSubscriber: AnyObject {
    /// Called when the view is first initialized.
    func viewDidLoad()

    /// Called when view receives `onAppear` callback.
    func viewDidAppear()

    /// Called when view receives `onDisappear` callback.
    func viewDidDisappear()
}

public extension ViewLifecycle {
    /// Binds to lifecycle states receiving on main thread.
    func subscribe(_ subscriber: ViewLifecycleSubscriber) {
        #if DEBUG
        assert(Thread.isMainThread, "Subscribe from main thread only.")
        #endif
        
        if subscribers.contains(subscriber) {
            assertionFailure("Binding to \(self) that has already been subscribes to. \(subscribers)")
        }
        subscribers.insert(subscriber)

        lifecycleState
            .first(where: { $0 == .initialized })
            .receive(on: Schedulers.main)
            .autoCancel(self, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak subscriber] _ in
                guard let subscriber = subscriber else { return }
                subscriber.viewDidLoad()
            })

        isActivePublisher
            .drop(while: { !$0 })
            .receive(on: Schedulers.main)
            .autoCancel(self, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak subscriber] isActive in
                guard let subscriber = subscriber else { return }
                if isActive {
                    subscriber.viewDidAppear()
                } else {
                    subscriber.viewDidDisappear()
                }
            })
    }
}
