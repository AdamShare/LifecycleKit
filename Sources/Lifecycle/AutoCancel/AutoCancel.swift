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

public extension Publisher {
    /// Completes when any provided lifecycle states are output, or lifecycle publisher completes.
    func autoCancel(_ lifecyclePublisher: LifecyclePublisher, when states: LifecycleStateOptions = .notActive) -> AutoCancel<Self> {
        return autoCancel(lifecyclePublisher.lifecycleState, when: states)
    }

    /// Completes when any provided lifecycle states are output, or lifecycle publisher completes.
    func autoCancel<P: Publisher>(_ lifecycleState: P, when states: LifecycleStateOptions = .notActive) -> AutoCancel<Self> where P.Output == LifecycleState {
        return AutoCancel(source: self, cancelPublisher: lifecycleState.filter(states.contains(state:)).map { _ in () }.replaceError(with: ()).mapError().eraseToAnyPublisher())
    }

    func published<T: LifecyclePublisher>(to keyPath: ReferenceWritableKeyPath<T, Output>, on: T) {
        receive(on: Schedulers.main)
            .autoCancel(on)
            .assign(to: keyPath, on: on)
    }
}

public extension Publisher {
    /// Cancellable will be retained be the sink and must me explicitly cancelled or completed.
    var retained: AutoCancel<Self> {
        return AutoCancel(source: self, cancelPublisher: nil)
    }
}

public struct AutoCancel<P: Publisher> {
    let source: P
    let cancelPublisher: RelayPublisher<Void>?

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveCancel: The closure to execute on receipt of a cancel. Defaults to `nil`.
    ///   - receiveCompletion: The closure to execute on completion. Defaults to `nil`.
    ///   - receiveFailure: The closure to execute on receipt of a failure. Defaults to `nil`.
    ///   - receiveFinished: The closure to execute on receipt of a finished. Defaults to `nil`.
    ///   - receiveValue: The closure to execute on receipt of a value. Defaults to `nil`.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    @discardableResult
    public func sink(receiveCancel: (() -> Void)? = nil,
                     receiveCompletion: ((Subscribers.Completion<P.Failure>) -> Void)? = nil,
                     receiveFailure: ((P.Failure) -> Void)? = nil,
                     receiveFinished: (() -> Void)? = nil,
                     receiveValue: ((P.Output) -> Void)? = nil) -> Cancellable
    {
        let retainedSink = Subscribers.RetainedSink(cancelPublisher: cancelPublisher,
                                                    receiveValue: receiveValue,
                                                    receiveCompletion: receiveCompletion,
                                                    receiveFailure: receiveFailure,
                                                    receiveFinished: receiveFinished,
                                                    receiveCancel: receiveCancel)
        source.subscribe(retainedSink)
        return retainedSink
    }

    @discardableResult
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, P.Output>, on object: Root) -> Cancellable {
        return sink(receiveValue: { value in
            object[keyPath: keyPath] = value
        })
    }

    func sink(receiveEvent: @escaping (Subscribers.Event<P.Output, P.Failure>) -> Void) -> Cancellable {
        return sink(receiveCompletion: { completion in
            receiveEvent(Subscribers.Event(completion))
        }, receiveValue: { value in
            receiveEvent(Subscribers.Event(value))
        })
    }

    func record() -> RecordSink<P.Output, P.Failure> {
        return RecordSink(publisher: self)
    }

    final class RecordSink<Input, Failure: Error> {
        public var cancellable: AnyCancellable?
        public var events: [Subscribers.Event<Input, Failure>] = []

        public init<P: Publisher>(publisher: AutoCancel<P>) where P.Output == Input, P.Failure == Failure {
            let cancellable = publisher.sink(receiveEvent: { [weak self] event in
                self?.events.append(event)
            })
            self.cancellable = AnyCancellable {
                cancellable.cancel()
            }
        }
    }
}

extension Subscribers {
    final class RetainedSink<Input, Failure: Error>: Subscriber, Cancellable {
        public let combineIdentifier: CombineIdentifier = CombineIdentifier()

        private let lock: NSRecursiveLock = .init()

        /// Cleanup can cause side effects such as triggering a deallocation lifecycle state that cancels.
        private var isActive: Bool = true

        private var cancelPublisherCancellable: Cancellable?
        private var subscription: Subscription?
        private var receivers: Receivers?

        init(cancelPublisher: RelayPublisher<Void>?,
             receiveValue: ((Input) -> Void)?,
             receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?,
             receiveFailure: ((Failure) -> Void)?,
             receiveFinished: (() -> Void)?,
             receiveCancel: (() -> Void)?) {
            receivers = Receivers(cancelPublisher: cancelPublisher,
                                  receiveValue: receiveValue,
                                  receiveCompletion: receiveCompletion,
                                  receiveFailure: receiveFailure,
                                  receiveFinished: receiveFinished,
                                  receiveCancel: receiveCancel)
        }

        public func receive(subscription: Subscription) {
            lock.lock(); defer { lock.unlock() }
            guard isActive else { return }

            self.subscription = subscription

            cancelPublisherCancellable = receivers?.cancelPublisher?.sink(receiveFinished: cancel,
                                                                          receiveValue: cancel)

            self.subscription?.request(.unlimited)
        }

        public func receive(_ input: Input) -> Subscribers.Demand {
            lock.lock(); defer { lock.unlock() }
            guard isActive else { return }

            receivers?.receiveValue?(input)
            return .unlimited
        }

        public func receive(completion: Subscribers.Completion<Failure>) {
            lock.lock(); defer { lock.unlock() }
            guard isActive else { return }

            receivers?.receiveCompletion?(completion)

            switch completion {
            case let .failure(error):
                receivers?.receiveFailure?(error)
            case .finished:
                receivers?.receiveFinished?()
            }

            clear()
        }

        public func cancel() {
            lock.lock(); defer { lock.unlock() }
            guard isActive else { return }

            guard subscription != nil else {
                clear()
                return
            }
            receivers?.receiveCancel?()
            clear()
        }

        /// Make sure everything is cleared to avoid retain cycles.
        private func clear() {
            isActive = false

            subscription?.cancel()
            subscription = nil
            cancelPublisherCancellable?.cancel()
            cancelPublisherCancellable = nil
            receivers = nil
        }

        struct Receivers {
            let cancelPublisher: RelayPublisher<Void>?
            let receiveValue: ((Input) -> Void)?
            let receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
            let receiveFailure: ((Failure) -> Void)?
            let receiveFinished: (() -> Void)?
            let receiveCancel: (() -> Void)?
        }
    }
}
