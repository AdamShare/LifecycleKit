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

@propertyWrapper
public final class DidSetPublished<Element> {

    public var projectedValue: RelayPublisher<Element> {
        return relay.eraseToAnyPublisher()
    }

    public var wrappedValue: Element {
        set {
            relay.send(newValue)
        }
        get {
            relay.value
        }
    }

    private let relay: CurrentValueRelay<Element>

    public init(wrappedValue: Element) {
        relay = CurrentValueRelay(wrappedValue)
    }

    deinit {
//        relay.send(completion: .finished)
    }
}

@propertyWrapper
public final class DidSetFilterNilPublished<Element> {

    public var projectedValue: RelayPublisher<Element> {
        return relay.eraseToAnyPublisher()
    }

    public var wrappedValue: Element? {
        didSet {
            if let value = wrappedValue {
                relay.send(value)
            }
        }
    }

    private let relay: ReplayRelay<Element> = ReplayRelay(bufferSize: 1)

    public init(wrappedValue: Element?) {
        self.wrappedValue = wrappedValue

        if let value = wrappedValue {
            relay.send(value)
        }
    }

    deinit {
        relay.send(completion: .finished)
    }
}
