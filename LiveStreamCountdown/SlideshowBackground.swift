//
//  SlideshowBackground.swift
//  LiveStreamCountdown
//
//  Created by Will Gallegos on 03-06-2026.
//

import SwiftUI

struct SlideshowBackground: View {
    @State private var unplayedWallpapers: [String] = (1...106).map { "wallpaper\($0)" }.shuffled()
    @State private var lastPlayed: String = ""
    
    @State private var currentDirection: CGFloat = 1
    @State private var isLayerAActive = true
    @State private var transitionTask: Task<Void, Never>?

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
