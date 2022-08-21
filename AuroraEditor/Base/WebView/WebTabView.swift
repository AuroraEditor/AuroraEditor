//
//  WebTabView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import WebKit

struct WebTabView: View {

    @State var webTab: WebTab

    var body: some View {
        if webTab.url != nil {
            WebView(pageURL: $webTab.url)
        } else {
            Text("No Web View Open")
        }
    }
}

struct WebTabView_Previews: PreviewProvider {
    static var previews: some View {
        WebTabView(webTab: WebTab(url: URL(string: "https://www.google.com")))
    }
}
