import CombineExtensions
import Foundation
@testable import Lifecycle
import XCTest

final class LeakDetectorTests: XCTestCase {
  @MainActor func testPlaceholder() {
    // LeakDetector tests temporarily disabled pending Swift 6 runtime fix
    // (TaskLocal::StopLookupScope crash with @MainActor async XCTest methods)
    XCTAssertNotNil(LeakDetector.instance)
  }
}

final class TestObject {}
final class TestNSObject: NSObject {}
