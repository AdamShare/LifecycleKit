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
import Foundation
import Lifecycle
import SwiftUI

/// Type erased `Presenter`.
public protocol Presentable: ViewLifecycleOwner {
    /// Type erased view for public use.
    var viewable: Viewable { get }
}

/// The base protocol for all `Presenter`s.
public protocol Presenting: ViewLifecycleOwner, ViewLifecycleSubscriber {}

/// The base class of all `Presenter`s. A `Presenter` translates business models into values the corresponding
/// `View` can consume and display. It also maps UI events to business logic method, invoked to
/// its listener.
@MainActor open class Presenter: BaseViewLifecycleOwner, Presenting {}

@MainActor open class InteractablePresenter: Presenter, Interactable, LifecycleSubscriber, LifecycleOwnerRouting {
    public let scopeLifecycle: ScopeLifecycle

    /// Initializer.
    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle(),
                viewLifecycle: ViewLifecycle = ViewLifecycle())
    {
        self.scopeLifecycle = scopeLifecycle
        super.init(viewLifecycle: viewLifecycle)
        scopeLifecycle.subscribe(self)
        viewLifecycle.setScopeLifecycle(scopeLifecycle)
    }

    open func didLoad(_ lifecyclePublisher: LifecyclePublisher) {}

    open func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {}

    open func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {}
}

/// Conformance by `Presenter` subclasses to provide a `ViewType` and be an `ObservableObject`.
public protocol ViewPresentable: Presentable, ObservableObject {
    /// View type confroming to `View`.
    associatedtype ContentView: View

    /// Typed view for internal reference.
    var view: ModifiedContent<ContentView, TrackingViewModifier> { get }
}

public extension ViewPresentable where ContentView: PresenterView, ContentView.PresenterType == Self {
    var view: ModifiedContent<Self.ContentView, TrackingViewModifier> {
        return ContentView(presenter: self).tracked(by: self)
    }
}

public extension ViewPresentable {
    /// The corresponding `View` owned by this `Presenter`.
    var viewable: Viewable {
        return ViewProvider(view: view)
    }
}
