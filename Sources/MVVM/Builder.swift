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

public protocol ControllerProviding {
    associatedtype Controller: LifecycleOwner, ViewLifecycleOwner

    var controller: Controller { get }
}

public protocol ViewModelProviding {
    associatedtype ViewModel: ObservableObject

    var viewModel: ViewModel { get }
}

@MainActor public extension ViewLifecycleOwnerViewProviding where Self: ViewModelProviding, ContentView: ViewModelView, ContentView.Model == ViewModel {
    var view: ContentView {
        return ContentView(model: viewModel)
    }
}

public protocol MVVMComponent: ViewLifecycleOwnerViewProviding, ControllerProviding, ViewModelProviding, ObservableObject {}

public extension MVVMComponent where Controller == Self  {
    var controller: Controller {
        return self
    }
}

public extension MVVMComponent where Controller == ViewModel {
    var viewModel: ViewModel {
        return controller
    }
}

public extension MVVMComponent {
    var lifecycleOwner: LifecycleOwner {
        return controller
    }

    var viewLifecycleOwner: ViewLifecycleOwner {
        return controller
    }
}

@MainActor public extension ViewLifecycleOwnerViewProviding where Self: ViewModelProviding & ControllerProviding, ContentView: ViewModelControllerView, ContentView.Model == ViewModel, ContentView.Controller == Controller {
    var view: ContentView {
        return ContentView(controller: controller, model: viewModel)
    }
}
