//
//  ArtAdvisorWidgetBundle.swift
//  ArtAdvisorWidget
//
//  Created by Jonathan Allured on 2/9/23.
//

import WidgetKit
import SwiftUI

@main
struct ArtAdvisorWidgetBundle: WidgetBundle {
    var body: some Widget {
        ArtAdvisorWidget()
        ArtAdvisorWidgetLiveActivity()
    }
}
