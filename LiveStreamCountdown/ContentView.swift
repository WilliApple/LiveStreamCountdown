//
//  ContentView.swift
//  LiveStreamCountdown
//
//  Created by William Gallegos on 5/27/25.
//

import SwiftUI

let announcements = [
    "Subscribe for content about iOS 27, macOS 27, and watchOS 27 post WWDC!",
    "WilliApple will be reacting to WWDC25 live on this channel! Stay tuned for that!",
    "Join our Discord Server for a chance to win a $25 Apple Giftcard and Discord Nitro! All you got to do is correctly guess the California name of macOS 27!",
    "Subscribing with your subscriptions public will show your name on the stream!",
    "Superchatting and donating lets you add a custom message on the stream for everyone to see!",
    "WilliWidgets, WilliStudy, and WilliDreams are all free apps available for you to download on the App Store funded by you watching WilliApple!",
    "Send a chat about what you want the most from WWDC this year!",
]

struct ContentView: View {
    @State private var now = Date()
    @State private var error: String = ""
    @State private var currentAnnouncement = announcements[0]

    @AppStorage("countdownType") private var countdownType: String = "standard"
    @AppStorage("textShadow") private var textShadow: Bool = true
    @AppStorage("countdownDate") private var countdownDate: Double = Date.now.timeIntervalSince1970
    @AppStorage("countdownName") private var countdownName: String = "Apple Event"
    @AppStorage("announcement1") private var announcement1: String = ""
    @AppStorage("announcement2") private var announcement2: String = ""

    var targetDestinationDate: Date {
        let savedDate = Date(timeIntervalSince1970: countdownDate)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: savedDate)
        return Calendar.current.date(from: components) ?? savedDate
    }
        
    var body: some View {
        let remaining = getTimeRemaining(from: now, to: targetDestinationDate)
        
        ZStack {
            switch countdownType {
            case "standard":
                SlideshowBackground()
            case "greenScreen":
                Color.green
                    .ignoresSafeArea()
            default:
                Color.black
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 4) {
                Spacer()
                VStack(spacing: 0) {
                    Text(countdownName)
                        .bold()
                        .shadow(color: textShadow ? .black : .clear, radius: 10, x: 2, y: 2)
                        .font(.custom("Lato-Regular", size: 50))
                }

                HStack(spacing: 20) {
                    timeBlock(value: remaining.days, label: "Days")
                    timeBlock(value: remaining.hours, label: "Hours")
                    timeBlock(value: remaining.minutes, label: "Minutes")
                    timeBlock(value: remaining.seconds, label: "Seconds")
                }
                .font(.title)
                .foregroundColor(.white)
                Spacer()
                
                if !error.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text(error)
                    }
                    .shadow(color: textShadow ? .black : .clear, radius: 10, x: 2, y: 2)
                } else {
                    VStack {
                        Text(announcement1)
                            .font(.custom("Lato-Bold", size: 50))
                        Text(announcement2)
                            .font(.custom("Lato-Bold", size: 30))
                    }
                    .shadow(color: textShadow ? .black : .clear, radius: 10, x: 2, y: 2)
                }
            }
            .padding()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { input in
            now = input
        }
        .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.smooth) {
                currentAnnouncement = announcements.randomElement() ?? ""
            }
        }
    }

    func getTimeRemaining(from: Date, to: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(to.timeIntervalSince(from)))
        return (
            interval / 86400,
            (interval % 86400) / 3600,
            (interval % 3600) / 60,
            interval % 60
        )
    }

    func timeBlock(value: Int, label: String) -> some View {
        VStack {
            Text("\(value)")
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: value)
                .shadow(color: textShadow ? .black : .clear, radius: 10, x: 2, y: 2)
                .font(.custom("Lato-Black", size: 100))
            Text(label)
                .shadow(color: textShadow ? .black : .clear, radius: 10, x: 2, y: 2)
                .font(.custom("Lato-Regular", size: 30))
        }
    }
}

#Preview {
    ContentView()
}
