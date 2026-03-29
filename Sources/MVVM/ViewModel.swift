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
import Lifecycle
import SwiftUI

/// Convenience protocol for a `View` with only a `ViewModel` dependency.
@MainActor public protocol ViewModelView: View {
    /// `ObservableObject` view model to bind to the `View`.
    associatedtype Model: ObservableObject, ViewLifecycleOwner

    /// Initializes with an observable object.
    init(model: Model)
}

/// Convenience protocol for a `View` with a `ViewController` and `ViewModel` dependency.
@MainActor public protocol ViewModelControllerView: View {
    /// `ViewLifecycleOwner` view controller.
    associatedtype Controller: ViewLifecycleOwner

    /// `ObservableObject` view model to bind to the `View`.
    associatedtype Model: ObservableObject

    /// Initializes with a lifecycle owner controller and observable object.
    init(controller: Controller, model: Model)
}
