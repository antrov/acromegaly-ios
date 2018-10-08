//
//  TabBarWrapper.swift
//  PlayNow
//
//  Created by Jakub Lyskawka on 26/04/2018.
//  Copyright © 2018 N7 Mobile Sp. z o.o. All rights reserved.
//

import UIKit

protocol TabBarWrapper: class {
    func selectTab(at index: Int)
    func navigationWrapper(at index: Int) -> NavigationWrapper?
}

protocol TabBarWrapperDelegate: class {
    func tabSelected(at index: Int)
}
