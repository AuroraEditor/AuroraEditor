//
//  QuickHelpInspector.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

// When selecting a function in the editor the QuickHelp
// will give you a summary, decleration and discussion.
struct QuickHelpInspector: View {

    @ObservedObject
    var sharedObjects: SharedObjects = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Help")
                .foregroundColor(.secondary)
                .fontWeight(.bold)
                .font(.system(size: 13))
                .frame(minWidth: 250, maxWidth: .infinity, alignment: .leading)

            if let currentToken = sharedObjects.currentToken {
                VStack(alignment: .leading) {
                    Text("Identity and Type")
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                        .font(.system(size: 11))
                        .padding(.top, 2)
                    Text(currentToken.scopes.map({ $0.name.rawValue }).joined(separator: "\n"))
                        .font(.system(size: 11))
                }
                Divider()
            } else {
                Text("No Quick Help")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .frame(minWidth: 250, maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                Button("Search Documentation") {

                }
                .background(in: RoundedRectangle(cornerRadius: 4))
                .frame(minWidth: 250, maxWidth: .infinity, alignment: .center)
                .font(.system(size: 12))
                Divider().padding(.top, 15)
            }
        }
        .frame(minWidth: 250, maxWidth: .infinity)
        .padding(5)
    }
}

struct QuickHelpInspector_Previews: PreviewProvider {
    static var previews: some View {
        QuickHelpInspector()
    }
}
