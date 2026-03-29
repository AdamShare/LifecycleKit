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

import Lifecycle
import SwiftUI

public protocol ViewLifecycleController: LifecycleController,
    ViewLifecycleOwner,
    ViewLifecycleSubscriber
{}

@MainActor open class ViewLifecycleOwnerController: LifecycleOwnerController, ViewLifecycleController {
    public let viewLifecycle: ViewLifecycle

    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle(),
                viewLifecycle: ViewLifecycle = ViewLifecycle()) {
        self.viewLifecycle = viewLifecycle
        super.init(scopeLifecycle: scopeLifecycle)
        viewLifecycle.subscribe(self)
        viewLifecycle.setScopeLifecycle(scopeLifecycle)
    }

    open func viewDidLoad() {}
    open func viewDidAppear() {}
    open func viewDidDisappear() {}
}

public protocol ViewController: ViewLifecycleController, ObservableObject {}

open class ViewModelController<Model: ObservableObject & ViewLifecycleOwner>: ViewLifecycleOwnerController {
    public let viewModel: Model

    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle(),
                viewModel: Model) {
        self.viewModel = viewModel
        super.init(scopeLifecycle: scopeLifecycle, viewLifecycle: viewModel.viewLifecycle)
    }
}
