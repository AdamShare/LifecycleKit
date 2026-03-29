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

import Foundation

/// Type for dependency frameworks such as Needle to conform to and provide a shared lifecycle instance.
nonisolated public protocol SharedComponent {
    /// Share the enclosed object as a singleton at this scope. This allows
    /// this scope as well as all child scopes to share a single instance of
    /// the object, for as long as this component lives.
    ///
    /// - note: Shared dependency's constructor should avoid switching threads
    /// as it may cause a deadlock.
    ///
    /// - parameter factory: The closure to construct the dependency object.
    /// - returns: The dependency object instance.
    func shared<T>(__function: String, _ factory: () -> T) -> T
}

public extension SharedComponent {
    /// Allows a shared parent instance to be passed by DI to a child scope and avoid a circular reference from parentScope->shared->childScope->parentScope.
    /// If the instance is released the factory will be used to build a new object.
    /// - parameter __function:
    /// - parameter singleBuild: Set false if object is expected to be released and created again. Defaults to `true`.
    /// - parameter factory:
    func weakShared<T: AnyObject>(__function: String = #function, singleBuild: Bool = true, _ factory: () -> T) -> T {
        let builder: WeakShared<T> = shared(__function: __function) { WeakShared() }
        if singleBuild {
            assert(builder.buildCount <= 1, "weakShared builder called \(builder.buildCount) times. Set `singleBuild` false if this is expected. " + __function)
        }
        return builder.getOrCreate(factory)
    }
}

/// Weakly holds reference to the lazily created value.
final class WeakShared<R: AnyObject> {
    private weak var weakInstance: R?
    var buildCount: Int = 0

    /// Builds a new instance of `R`.
    public func getOrCreate(_ builder: () -> R) -> R  {
        if let weakInstance = weakInstance {
            return weakInstance
        }
        buildCount += 1
        let instance = builder()
        weakInstance = instance
        return instance
    }
}
