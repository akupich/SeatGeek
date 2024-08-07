//
//  Scene+ViewController.swift
//  SeatGeek
//
//  Created by Andriy Kupich on 5/6/19.
//  Copyright © 2019 Andriy Kupich. All rights reserved.
//

import UIKit

extension Scene {
    func viewController() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
        case .events(let viewModel):
            let uiNC = storyboard.instantiateViewController(withIdentifier:
                "EventsNav") as? UINavigationController
            var uiVC = uiNC?.viewControllers.first as? EventsViewController
            uiVC?.bindViewModel(to: viewModel)
            return uiNC
        case .eventDetails(let viewModel):
            var uiVC = storyboard.instantiateViewController(withIdentifier:
                "EventDetails") as? EventDetailsViewController
            uiVC?.bindViewModel(to: viewModel)
            return uiVC
        } }
}
