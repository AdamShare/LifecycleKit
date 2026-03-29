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
import SwiftUI

@MainActor public protocol ViewableBuildable: AnyObject {
    func build() -> Viewable
}

@MainActor public protocol LifecycleOwnerViewProviding: ViewableBuildable {
    associatedtype ContentView: View
    var lifecycleOwner: LifecycleOwner { get }
    var view: ContentView { get }
}

public extension LifecycleOwnerViewProviding {
    func build() -> Viewable {
        return LifecycleOwnerViewProvider(view: self.view, childLifecycle: self.lifecycleOwner)
    }
}

@MainActor public protocol ViewLifecycleOwnerViewProviding: ViewableBuildable {
    associatedtype ContentView: View
    var lifecycleOwner: LifecycleOwner { get }
    var view: ContentView { get }
    var viewLifecycleOwner: ViewLifecycleOwner { get }
}

public protocol Initializable {
    init()
}

public extension ViewLifecycleOwnerViewProviding where ContentView: Initializable {
    var view: ContentView {
        return ContentView()
    }
}

public extension ViewLifecycleOwnerViewProviding {
    func build() -> Viewable {
        return LifecycleOwnerViewProvider(view: self.view.tracked(by: self.viewLifecycleOwner),
                                          childLifecycle: self.lifecycleOwner)
    }
}

public extension ViewLifecycleOwnerViewProviding where Self: ObservableObject {
    func build() -> Viewable {
        return LifecycleOwnerViewProvider(view: self.view.tracked(by: self.viewLifecycleOwner).environmentObject(self),
                                          childLifecycle: self.lifecycleOwner)
    }
}

extension AnyBuilder: ViewableBuildable where R == Viewable {}

public protocol LazyViewable {
    var value: Viewable { get }
}

extension Lazy: ViewableBuildable where R == Viewable {
    public func build() -> Viewable {
        return getOrCreate()
    }
}

extension Lazy: LazyViewable where R == Viewable {
    public var value: Viewable {
        return getOrCreate()
    }
}

extension WeakLazy: ViewableBuildable where R: Viewable {
    public func build() -> Viewable {
        return getOrCreate()
    }
}

extension WeakLazy: LazyViewable where R: Viewable {
    public var value: Viewable {
        return getOrCreate()
    }
}
