//
//  ButtonView.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 11.03.2022.
//

import SwiftUI
import UIKit

struct ButtonView: View {
    
    var onButtonPressed : ((Bool) -> Void)?
    var buttonText: String
    
    @State private var isButtonPressed: Bool = false
    private var buttonColor: UIColor? {
        isButtonPressed ? UIColor(named: "ColorOrange") : UIColor.systemBackground
   }
    private var fontWeight: Font.Weight {
        isButtonPressed ? .bold : .regular
    }
    
    var body: some View {
        ZStack {
            Color(buttonColor!)
            Button(buttonText) {
                isButtonPressed = !isButtonPressed
                onButtonPressed?(isButtonPressed)
            }
            .font(.system(size: 14, weight: fontWeight, design: .default))
            .foregroundColor(isButtonPressed ? Color(.white) : Color(.label))

        }
        .frame(width: 180, height: 30, alignment: .center)
        .cornerRadius(15)
        .overlay(
            isButtonPressed ? RoundedRectangle(cornerRadius: 15)
                .stroke(.orange, style: StrokeStyle(lineWidth: 1))
            
            : RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor.label), style: StrokeStyle(lineWidth: 1)) )
        .padding(.horizontal, 2)
        
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(buttonText: "KEK")
    }
}
