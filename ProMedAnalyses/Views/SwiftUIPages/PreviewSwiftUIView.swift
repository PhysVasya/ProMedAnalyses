//
//  PreviewSwiftUIView.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 10.03.2022.
//

import SwiftUI

struct PreviewSwiftUIView: View {
    
    var value: String
    var normalValue: String
    var description: String
    var color: UIColor
    
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundColor(Color(color))
                    .frame(height: 50, alignment: .center)
                Text(value)
                    .frame(height: 50, alignment: .center)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            ZStack {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundColor(Color("ColorGreen"))
                    .frame(height: 50, alignment: .center)
                Text(normalValue)
                    .frame(height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            
            ScrollView(.vertical, showsIndicators: true) {
                
                Text(description)
                    .font(.system(size: 16, weight: .light, design: .rounded))
            }
            .frame(height: height / 2, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
   
        }
        .frame(width: width - 20)
        
        
    }
}


struct PreviewSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewSwiftUIView(value: "KRK", normalValue: "KEK", description: "KOOK", color: UIColor(named: "ColorOrange")!)
    }
}
