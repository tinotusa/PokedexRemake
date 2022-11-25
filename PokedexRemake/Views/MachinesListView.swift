//
//  MachinesListView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MachinesListView: View {
    let title: String
    let description: LocalizedStringKey
    @StateObject private var viewModel: MachinesListViewModel
    
    init(title: String, description: LocalizedStringKey, urls: [URL]) {
        self.title = title
        self.description = description
        _viewModel = StateObject(wrappedValue: MachinesListViewModel(urls: urls))
    }
    
    var body: some View {
        DetailListView(
            title: title,
            description: description
        ) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadPage()
                            }
                        }
                case .loaded:
                    LazyVStack {
                        ForEach(viewModel.machines) { machine in
                            MachineCard(machine: machine)
                        }
                        if viewModel.hasNextPage {
                            ProgressView()
                                .task {
                                    await viewModel.loadPage()
                                }
                        }
                    }
                case .error(let error):
                    ErrorView(text: error.localizedDescription)
                }
            }
        }
    }
}

struct MachinesListView_Previews: PreviewProvider {
    static var previews: some View {
        MachinesListView(
            title: "some title",
            description: "a description",
            urls: Move.example.machines.map { $0.machine.url}
        )
    }
}
