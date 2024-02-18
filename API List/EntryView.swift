//
//  EntryView.swift
//  API List
//
//  Created by Fabiola Rocha Marquez on 2/17/24.
//

import SwiftUI

struct EntryView: View {
    @State private var entries = [Entry]()
    @State private var showingAlert = false
    let category: String
    var body: some View {
        List(entries) { entry in
            VStack(alignment: .leading) {
                Link(destination: URL(string: entry.link)!) {
                    Text(entry.link)
                }
                Text(entry.description)
            }
            .navigationTitle(category)
        }
        .task {
            await getEntries()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
            message: Text("There was a problem loading the API entries"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func getEntries() async {
        let category = category.components(separatedBy: " ").first!
        let query = "https://api.publicapis.org/entries?category=\(category)"
        if let url = URL(string: query) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode(Entries.self, from: data) {
                    entries = decodedResponse.entries
                    return
                }
            }
        }
        showingAlert = true
    }
}

struct Entry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var link: String
    
    enum CodingKeys : String, CodingKey {
        case title = "API"
        case description = "Description"
        case link = "Link"
    }
}

struct Entries: Codable {
    var entries: [Entry]
}

#Preview {
    EntryView(category: "Test")
}
