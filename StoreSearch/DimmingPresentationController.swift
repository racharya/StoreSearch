//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/23/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit

class DimmingPresentationController: UIPresentationController {
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}// end of DimmingPresentationController
