//
//  NavigatorSidebar.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 25.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// # Project Navigator - Sidebar
///
/// A list that functions as a project navigator, showing collapsable folders
/// and files.
///
/// When selecting a file it will open in the editor.
///
struct ProjectNavigator: View {

    @ObservedObject
    var prefs: AppPreferencesModel = .shared

    /// The view body.
    var body: some View {
        ProjectNavigatorView(prefs: prefs)
    }
}
