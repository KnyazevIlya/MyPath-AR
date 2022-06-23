//
//  OnboardingView.swift
//  MyPath
//
//  Created by Illia Kniaziev on 23.06.2022.
//

import SwiftUI

struct SlideView: View {
    let imageName: String
    let text: String
    
    var body: some View {
        VStack {
            if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 32, height: 300, alignment: .center)
            }
            
            Text(text)
                .font(.system(size: 24, weight: .medium, design: .default))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding([ .leading, .trailing], 16)
        }
    }
}

struct OnboardingView: View {
    let skipPreview: () -> Void
    
    @State private var data = [
        (imageName: "map", text: "Find a place you'd like to explore."),
        (imageName: "", text: "Build a path you want to follow in AR!"),
        (imageName: "", text: "Share with others and go hiking.")
    ]
    @State private var selectedPage = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                LazyHStack {
                    TabView(selection: $selectedPage) {
                        ForEach(Array(data.enumerated()), id: \.0) { index, datum in
                            SlideView(imageName: datum.imageName, text: datum.text)
                        }
                        .tabViewStyle(.page)
                    }
                    .frame(
                        minWidth: geometry.size.width,
                        maxHeight: geometry.size.height,
                        alignment: .center
                    )
                    .tabViewStyle(.page)
                }
                
                HStack(alignment: .center, spacing: 8) {
                    if selectedPage < data.count - 1 {
                        Button(action: {
                            skipPreview()
                        }) {
                            HStack(alignment: .center, spacing: 10) {
                                Text("Skip")
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            maxHeight: 44
                        )
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(
                            [.leading, .trailing, .bottom], 20
                        )
                    }
                    
                    Button(action: {
                        if selectedPage == data.count - 1 {
                            skipPreview()
                        } else {
                            selectedPage += 1
                        }
                    }) {
                        HStack(alignment: .center, spacing: 10) {
                            Text("Next")
                                .foregroundColor(.white)
                            Image(systemName: "chevron.right")
                                .accentColor(.white)
                        }
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        maxHeight: 44
                    )
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(
                        [.leading, .trailing, .bottom], 20
                    )
                }
                
            }
        }
        .background(switchGradient())
        .animation(.easeInOut(duration: 0.2), value: selectedPage)
    }
    
    private func switchColour() -> Color {
        let colours: [Color] = [.blue, .indigo, .purple, .pink, .green]
        return colours[selectedPage].opacity(0.4)
    }
    
    private func switchGradient() -> LinearGradient {
        var colours: [Color] = [.blue, .indigo, .purple, .pink, .green]
        colours = colours.map { $0.opacity(0.75) }
        
        let startColour = colours[selectedPage]
        let endColour = colours[selectedPage + 1]
        
        return LinearGradient(colors: [startColour, endColour], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(skipPreview: {})
            .previewDevice("iPhone 13")
    }
}

