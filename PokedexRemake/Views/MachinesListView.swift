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
    let id: Int
    let description: LocalizedStringKey
    let machineURLs: [URL]
    @StateObject private var viewModel = MachinesListViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(urls: machineURLs)
                }
        case .loaded:
            DetailListView(
                title: title,
                id: id,
                description: description
            ) {
                LazyVStack {
                    ForEach(viewModel.sortedMachines()) { machine in
                        //                    MachineCard(machine: machine)
                        Text("\(machine.item.name!)")
                            .padding()
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct MachinesListView_Previews: PreviewProvider {
    static var previews: some View {
        MachinesListView(
            title: "some title",
            id: 123,
            description: "a description",
            machineURLs: Move.example.machines.map { $0.machine.url}
        )
    }
}
