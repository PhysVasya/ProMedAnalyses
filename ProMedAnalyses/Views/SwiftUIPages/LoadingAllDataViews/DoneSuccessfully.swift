//
//  DoneSuccessfully.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 12.03.2022.
//

import SwiftUI

struct DoneSuccessfully: View {
    @State var isAnimating: Bool
    
    var body: some View {
        ZStack {
            ZStack {
                Circle().strokeBorder(Color.green)
                    .background(Circle().foregroundColor(Color.green))
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                Circle().strokeBorder(Color.green, lineWidth: 2)
                    .background(Circle().foregroundColor(Color.green))
                    .opacity(0.3)
                    .frame(width: 50, height: 50)
            }
            .opacity(isAnimating ? 1 : 0.8)
            .scaleEffect(isAnimating ? 1 : 0)
            .animation(.easeOut(duration: 0.3), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
            Image(systemName: "checkmark")
                .resizable()
                .frame(width: 20, height: 20)
                .scaledToFit()
                .foregroundColor(Color.white)
                .scaleEffect(isAnimating ? 1 : 0.6)
                .animation(.easeOut(duration: 0.4), value: isAnimating)
        }
    }
}

struct DoneSuccessfully_Previews: PreviewProvider {
    static var previews: some View {
        DoneSuccessfully(isAnimating: true)
        
    }
}
