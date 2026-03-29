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

public final class ViewLifecycle: LifecyclePublisher, ObjectIdentifiable {
    public var isActive: Bool {
        return state == .active
    }

    public var lifecycleState: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return $state.removeDuplicates()
    }

    public func dismissView() {
        dismissPublisher.send()
    }

    let dismissPublisher: PassthroughRelay<Void> = PassthroughRelay()

    /// Set to `true` `onAppear`, and `false` `onDisappear`.
    var isDisplayed: Bool = false {
        didSet {
            guard isDisplayed != oldValue else { return }

            state = isDisplayed ? .active : .inactive
        }
    }

    weak var owner: ViewLifecycleOwner? {
        didSet {
            if let owner = owner, let oldValue = oldValue, owner !== oldValue {
                assertionFailure("Already an owner for this view lifecycle: \(oldValue). \(ViewLifecycle.self)s should only subscribe to a single \(ViewLifecycleOwner.self). New value: \(owner)")
            }
        }
    }

    private var cancellables: [AnyCancellable] = []

    weak var scopeLifecycle: ScopeLifecycle? {
        didSet {
            cancellables = []

            guard let scopeLifecycle = scopeLifecycle else { return }

            if let oldValue = oldValue, scopeLifecycle !== oldValue {
                assertionFailure("Already a scope lifecycle for this view lifecycle: \(oldValue). New value: \(scopeLifecycle)")
            }

            let lifecyclePublisher = scopeLifecycle
                .lifecycleState
                .drop(while: { state in state != .inactive })
                .map { state in state == .active }
                .removeDuplicates()
                .share(replay: 1)

            lifecyclePublisher
                .map { [weak self] isActive -> RelayPublisher<Void> in
                    guard let self = self, !isActive else {
                        return Empty<Void, Never>().eraseToAnyPublisher()
                    }
                    return LeakDetector.instance.expectViewDisappear(tracker: self)
                }
                .switchToLatest()
                .sink()
                .store(in: &cancellables)

            lifecyclePublisher
                .sink(receiveValue: { [weak self] isActive in
                    if !isActive {
                        self?.dismissView()
                    }
                })
                .store(in: &cancellables)
        }
    }

    var subscribers = WeakSet<ViewLifecycleSubscriber>()

    @DidSetFilterNilPublished private var state: LifecycleState?

    public init() {}

    deinit {
        MainActor.assumeIsolated {
            state = .deinitialized
        }
    }

    public func setScopeLifecycle(_ scopeLifecycle: ScopeLifecycle) {
        self.scopeLifecycle = scopeLifecycle
    }

    func viewDidLoad(with owner: ViewLifecycleOwner) {
        self.owner = owner
        state = .initialized
    }
}
