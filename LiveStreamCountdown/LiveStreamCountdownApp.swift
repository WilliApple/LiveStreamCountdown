//
//  LiveStreamCountdownApp.swift
//  LiveStreamCountdown
//
//  Created by William Gallegos on 5/27/25.
//

import SwiftUI

@main
struct LiveStreamCountdownApp: App {
    @AppStorage("countdownType") private var countdownType: String = "standard"
    @AppStorage("textShadow") private var textShadow: Bool = true
    @AppStorage("countdownDate") private var countdownDate: Double = Date.now.timeIntervalSince1970
    @AppStorage("countdownName") private var countdownName: String = "Apple Event"
    @AppStorage("announcement1") private var announcement1: String = ""
    @AppStorage("announcement2") private var announcement2: String = ""
    
    var body: some Scene {
        var countdownTime: Date {
            get { Date(timeIntervalSince1970: countdownDate) }
            set { countdownDate = newValue.timeIntervalSince1970 }
        }
        
        WindowGroup {
            ContentView()
        }
        
        Settings {
            TabView {
                Tab("General", systemImage: "gear") {
                    Form {
                        Picker("Countdown Background", selection: $countdownType) {
                            Text("Standard")
                                .tag("standard")
                            Text("Green Screen")
                                .tag("greenScreen")
                        }
                        Toggle(isOn: $textShadow) {
                            Text("Show Shadow")
                        }
                        
                        TextField("Countdown Name", text: $countdownName)
                        
                        DatePicker("Countdown Date", selection: Binding(
                            get: { countdownTime },
                            set: { countdownTime = $0 }
                        ), displayedComponents: .date)
                        DatePicker("Countdown Time", selection: Binding(
                            get: { countdownTime },
                            set: { countdownTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                        
                        TextField("Announcement1", text: $announcement1)
                        TextField("Announcement2", text: $announcement2)
                    }
                    .padding()
                }
            }
        }
    }
}
