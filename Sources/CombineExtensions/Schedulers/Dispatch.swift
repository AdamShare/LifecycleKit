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

/// Is running on main queue. (Not main thread.)
public var isMainQueue: Bool {
    return DispatchQueue.main.isCurrentExecutionContext
}

/// Syncs to main queue or executes closure if `isMainQueue`.
public func syncMain<T>(closure: () -> T) -> T {
    return DispatchQueue.main.sync(closure)
}

/// Submits a work item to the main dispatch queue for asynchronous execution after
/// a specified time.
public func asyncMain(delay: TimeInterval = 0, execute work: @escaping () -> Void) {
    DispatchQueue.main.async(delay: delay, execute: work)
}
