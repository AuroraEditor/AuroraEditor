//
//  AIMLProjectView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct AIMLProjectView: View {
    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    private var gridItemLayout = [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())]

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(creationSheetModel.aiMLProjects, id: \.self) { language in
                        VStack {
                            Image(language.langaugeIcon)
                                .padding(.bottom, 10)

                            Text(language.languageName)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .font(.system(size: 11))
                        }
                        .padding()
                    }
                }
            }.frame(maxWidth: .infinity)
        }
    }
}

struct AIMLProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AIMLProjectView()
    }
}
