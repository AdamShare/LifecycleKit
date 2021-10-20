# LifecycleKit
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

LifecycleKit is a framework for building lifecycle-aware architecture components.

Inspired by [RIBs](https://github.com/uber/ribs) and [Android Jetpack Lifecycle](https://developer.android.com/jetpack/androidx/releases/lifecycle).

## Overview

[Lifecycle](https://github.com/ashare80/LifecycleKit/wiki/Lifecycle) provides protocols and implementations that can be used to facilitate building safe and scalable application architecture.

[SPIR](https://github.com/ashare80/LifecycleKit/wiki/SPIR) is an app architecture utilizing Lifecycle to create a scoped business logic tree independent of the view hierarchy. Complemented by [Needle](https://github.com/uber/needle), a compile-time safe Swift dependency injection framework.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ashare80/LifecycleKit.git", .upToNextMajor(from: "0.3.6"))
]
```

# License

    Copyright (C) 2020 Adam Share

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
