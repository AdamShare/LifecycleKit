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
@testable import CombineExtensions
import XCTest

final class SchedulersTests: XCTestCase {
    @MainActor func testSchedulersSync() {
        syncMain {
            let e = self.expectation(description: "Expect sink call immediately")
            _ = Just(())
                .receive(on: Schedulers.main)
                .sink(receiveValue:  {
                    e.fulfill()
                })
            self.waitForExpectations(timeout: 0.0)
        }

        func expectSync(scheduler: CombineExtensions.DispatchQueue.Scheduler) {
            scheduler.dispatchQueue.sync {
                var called = false
                let cancellable = Just(())
                    .receive(on: scheduler)
                    .sink(receiveValue: {
                        called = true
                    })
                XCTAssertTrue(called)
                cancellable.cancel()
            }
        }

        var schedulers: [CombineExtensions.DispatchQueue.Scheduler] = [
            .userInteractive(),
            .userInitiated(),
            .default(),
            .utility(),
            .background(),
        ]
        schedulers.forEach(expectSync)

        func expectAsync(scheduler: CombineExtensions.DispatchQueue.Scheduler) {
                var called = false
                let cancellable = Just(())
                    .receive(on: scheduler)
                    .sink(receiveValue: {
                        Thread.sleep(forTimeInterval: 1)
                        called = true
                    })
                XCTAssertFalse(called)
                cancellable.cancel()
        }

        schedulers.append(.asyncMain)
        schedulers.forEach(expectAsync)
    }

    @MainActor func testSchedulerConcurrency() {
        let e = self.expectation(description: "Expect ordered calls to concurrent queue backed scheduler")
        var values: [Int] = []
        let startingValues: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let cancellable = startingValues
            .publisher
            .receive(on: Schedulers.default())
            .sink(receiveValue: { value in
                values.append(value)
                if values.count == 10 {
                    XCTAssertEqual(startingValues, values)
                    e.fulfill()
                }
            })

        wait(for: [e], timeout: 10.0)
        cancellable.cancel()
    }
}
