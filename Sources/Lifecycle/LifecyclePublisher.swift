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

public enum LifecycleState: Int, CaseIterable, Hashable {
    /// Scope has been initialized but not yet active.
    case initialized

    /// Scope is currently active.
    case active

    /// Scope is currently inactive.
    case inactive

    /// Scope deinit called.
    case deinitialized
}

public struct LifecycleStateOptions: OptionSet, Sendable {
    public static let initialized: LifecycleStateOptions = .init(.initialized)
    public static let active: LifecycleStateOptions = .init(.active)
    public static let inactive: LifecycleStateOptions = .init(.inactive)
    public static let deinitialized: LifecycleStateOptions = .init(.deinitialized)

    public static let notActive: LifecycleStateOptions = [.inactive, .initialized, .deinitialized]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(_ state: LifecycleState) {
        self.init(rawValue: 1 << state.rawValue)
    }

    public func contains(state: LifecycleState) -> Bool {
        return contains(LifecycleStateOptions(state))
    }
}

@MainActor public protocol LifecyclePublisher: AnyObject {
    /// Publisher of `LifecycleState` updates.
    var lifecycleState: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> { get }
}

public extension LifecyclePublisher {
    var isActivePublisher: Publishers.RemoveDuplicates<RelayPublisher<Bool>> {
        return lifecycleState
            .map { state in state == .active }
            .eraseToAnyPublisher()
            .removeDuplicates()
    }

    var firstActive: Publishers.First<RelayPublisher<Void>> {
        return isActivePublisher
            .filter { $0 }
            .map { _ in () }
            .eraseToAnyPublisher()
            .first()
    }
}
