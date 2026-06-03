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
    
    var countdownTimeBinding: Binding<Date> {
        Binding(
            get: {
                let savedDate = Date(timeIntervalSince1970: countdownDate)
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: savedDate)
                return Calendar.current.date(from: components) ?? savedDate
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: newDate)
                if let zeroedSecondsDate = Calendar.current.date(from: components) {
                    countdownDate = zeroedSecondsDate.timeIntervalSince1970
                } else {
                    countdownDate = newDate.timeIntervalSince1970
                }
            }
        )
    }
    
    var body: some Scene {
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
                        
                        DatePicker("Countdown Date", selection: countdownTimeBinding, displayedComponents: .date)
                        DatePicker("Countdown Time", selection: countdownTimeBinding, displayedComponents: .hourAndMinute)
                        
                        TextField("Announcement1", text: $announcement1)
                        TextField("Announcement2", text: $announcement2)
                    }
                    .padding()
                }
            }
        }
    }
}
