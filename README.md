# Acromegaly iOS

Acromegaly iOS is a controlling app for the desk with automatically adjustable height. 

This resposity is a part of the [Acromegaly project](https://github.com/antrov/acromegaly) - Open Source desk with adjustable height.

![Settings exact height](https://raw.githubusercontent.com/antrov/acromegaly-ios/develop/docs/height.gif)
![Swipe gesture](https://raw.githubusercontent.com/antrov/acromegaly-ios/develop/docs/swipe.gif)

### Features:

* auto scanning and connecting to dedicated BLE device ([acromegaly-nrf51](https://github.com/antrov/acromegaly-nrf51))
* visual representation of current and requested desk height
* setting exact height of a desk
* swipe gesture to set bounding positions
* storing of the favourites positions

## Build with Xcode

### Prerequisites

* iOS 10+
* Xcode 10+
* Carthage 0.31+
* [acromegaly-nrf51 BLE device](https://github.com/antrov/acromegaly-nrf51)

### Build

```bash
git clone git@github.com:antrov/acromegaly-ios.git
cd acromegaly-ios/
carthage build --platform iOS
open acromegaly.xcodeproj
```

Hit run and test your acromegaly-nrf51 device. Without available and properly configured BLE device, the Acromegaly iOS app would stay in scanning mode with an interface disabled.

### Customize UUID

Acromegaly iOS app looks for an acromegaly-nrf51 device using UUIDs of its services: 
* status service: 00005E1F-1212-EFDE-1523-785FEF13D123,
* control Service: 00001EAD-1212-EFDE-1523-785F90190523

In case of a customized acromegaly-nrf51 device and its UUIDs, values in enum `BluetoothConstants.Service` should be updated as well

## Further develop

The application reached satisfacting state and there is no further develop planned. 
In case of other developer's unexpected free time or rise of this project popularity, there is a short list of possible goals to achieve:

* security of pairing with BLE device
* iOS widget
* Panic Stop Button
* current measurement display
* OTA DFU support

## Contact
In case of new issues, concepts or just a will to say hello:

* antrof@gmail.com
* https://www.linkedin.com/in/handr/

## License 

Copyright 2019 Hubert Andrzejewski

This code is distributed under the terms and conditions of the MIT license.

```
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
