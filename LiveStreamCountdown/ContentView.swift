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

struct SlideshowBackground: View {
    @State private var unplayedWallpapers: [String] = (1...106).map { "wallpaper\($0)" }.shuffled()
    @State private var lastPlayed: String = ""
    
    @State private var currentDirection: CGFloat = 1
    @State private var isLayerAActive = true
    @State private var transitionTask: Task<Void, Never>?

    // Using an incrementing zIndex guarantees the incoming layer is always on top
    @State private var topZIndex: Double = 1

    @State private var layerAImage = ""
    @State private var layerAOffset: CGFloat = -80
    @State private var layerAOpacity: Double = 1.0
    @State private var layerAZIndex: Double = 1

    @State private var layerBImage = ""
    @State private var layerBOffset: CGFloat = 80
    @State private var layerBOpacity: Double = 0.0
    @State private var layerBZIndex: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                
                if !layerAImage.isEmpty {
                    Image(layerAImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .scaleEffect(1.15)
                        .offset(x: layerAOffset)
                        .opacity(layerAOpacity)
                        .zIndex(layerAZIndex)
                }
                
                if !layerBImage.isEmpty {
                    Image(layerBImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .scaleEffect(1.15)
                        .offset(x: layerBOffset)
                        .opacity(layerBOpacity)
                        .zIndex(layerBZIndex)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startSlideshow()
        }
        .onDisappear {
            transitionTask?.cancel()
        }
    }

    func getNextWallpaperName() -> String {
        if unplayedWallpapers.isEmpty {
            unplayedWallpapers = (1...106).map { "wallpaper\($0)" }.shuffled()
            if unplayedWallpapers.first == lastPlayed {
                unplayedWallpapers.swapAt(0, unplayedWallpapers.count - 1)
            }
        }
        let next = unplayedWallpapers.removeFirst()
        lastPlayed = next
        return next
    }

    func startSlideshow() {
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            layerAImage = getNextWallpaperName()
            layerAZIndex = topZIndex
            
            var initialTransaction = Transaction()
            initialTransaction.disablesAnimations = true
            withTransaction(initialTransaction) {
                layerAOffset = currentDirection == 1 ? -80 : 80
                layerAOpacity = 1.0
            }
            
            // INCREASED to 7.0 to prevent drift stoppage
            withAnimation(.linear(duration: 7.0)) {
                layerAOffset = currentDirection == 1 ? 80 : -80
            }
            
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if Task.isCancelled { break }
                
                currentDirection *= -1
                
                if isLayerAActive {
                    layerBImage = getNextWallpaperName()
                    
                    topZIndex += 1
                    layerBZIndex = topZIndex
                    
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        layerBOffset = currentDirection == 1 ? -80 : 80
                        layerBOpacity = 0.0
                    }
                    
                    withAnimation(.easeInOut(duration: 1.0)) { layerBOpacity = 1.0 }
                    // INCREASED to 7.0 to prevent drift stoppage
                    withAnimation(.linear(duration: 7.0)) { layerBOffset = currentDirection == 1 ? 80 : -80 }
                    
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if Task.isCancelled { break }
                    
                    layerAOpacity = 0.0
                    
                } else {
                    layerAImage = getNextWallpaperName()
                    
                    topZIndex += 1
                    layerAZIndex = topZIndex
                    
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        layerAOffset = currentDirection == 1 ? -80 : 80
                        layerAOpacity = 0.0
                    }
                    
                    withAnimation(.easeInOut(duration: 1.0)) { layerAOpacity = 1.0 }
                    // INCREASED to 7.0 to prevent drift stoppage
                    withAnimation(.linear(duration: 7.0)) { layerAOffset = currentDirection == 1 ? 80 : -80 }
                    
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if Task.isCancelled { break }
                    
                    layerBOpacity = 0.0
                }
                
                isLayerAActive.toggle()
            }
        }
    }
}

struct ContentView: View {
    @State private var now = Date()
    @State private var error: String = ""
    @State private var currentAnnouncement = announcements[0]

    let dateOfEvent = Date(timeIntervalSince1970: 1749488400)

    @AppStorage("countdownType") private var countdownType: String = "standard"
    @AppStorage("textShadow") private var textShadow: Bool = true
    @AppStorage("countdownDate") private var countdownDate: Double = Date.now.timeIntervalSince1970
    @AppStorage("countdownName") private var countdownName: String = "Apple Event"
    @AppStorage("announcement1") private var announcement1: String = ""
    @AppStorage("announcement2") private var announcement2: String = ""

    var countdownTime: Date {
        get { Date(timeIntervalSince1970: countdownDate) }
        set { countdownDate = newValue.timeIntervalSince1970 }
    }
        
    var body: some View {
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
                    timeBlock(value: getTimeRemaining(countdownTime: countdownTime).days, label: "Days")
                    timeBlock(value: getTimeRemaining(countdownTime: countdownTime).hours, label: "Hours")
                    timeBlock(value: getTimeRemaining(countdownTime: countdownTime).minutes, label: "Minutes")
                    timeBlock(value: getTimeRemaining(countdownTime: countdownTime).seconds, label: "Seconds")
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
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
        .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.smooth) {
                currentAnnouncement = announcements.randomElement() ?? ""
            }
        }
    }

    func getTimeRemaining(countdownTime: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(countdownTime.timeIntervalSince(now)))
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
