//
//  ContentView.swift
//  TimeStopWatch Watch App
//
//  Created by 어재선 on 2/1/26.
//

import SwiftUI

struct ContentView: View {
    @State private var targetSeconds: Int = 10
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select Time")
                    .font(.headline)
                
                Picker("Seconds", selection: $targetSeconds) {
                    ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { seconds in
                        Text("\(seconds)s").tag(seconds)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
                
                NavigationLink {
                    WatchTimerScreen(viewModel: WatchTimerViewModel(targetSeconds: targetSeconds))
                } label: {
                    Label(String(localized: "start"), systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .navigationTitle("TimeSense")
        }
    }
}

#Preview {
    ContentView()
}
