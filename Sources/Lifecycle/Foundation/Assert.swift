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

#if DEBUG
    func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
        guard !assertClosures.isEmpty else {
            Swift.assert(condition(), message(), file: file, line: line)
            return
        }
        assertClosures.removeFirst()(condition(), message(), file, line)
    }

    nonisolated(unsafe) var assertClosures: [(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, _ file: StaticString, _ line: UInt) -> Void] = []

    func assertionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        guard !assertionFailureClosures.isEmpty else {
            Swift.assertionFailure(message(), file: file, line: line)
            return
        }
        assertionFailureClosures.removeFirst()(message(), file, line)
    }

    nonisolated(unsafe) var assertionFailureClosures: [(@autoclosure () -> String, StaticString, UInt) -> Void] = []
#endif
