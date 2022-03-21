//
//  OnDisappear.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 12.03.2022.
//

import SwiftUI

struct OnDisappear: View {
    
    @Binding var double: Double
    
    var body: some View {
        VStack {
            ProgressView(value: double)
                .tint(Color("ColorOrange"))
            Text(String(format: "%.1f", double * 100)+"%")
                .font(.system(size: 12))
        }
        
    }
}

//struct OnDisappear_Previews: PreviewProvider {
//    static var previews: some View {
//        OnDisappear(double: Binding<0.2>)
//    }
//}
