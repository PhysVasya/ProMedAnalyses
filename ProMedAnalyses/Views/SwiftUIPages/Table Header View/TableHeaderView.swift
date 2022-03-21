//
//  TableHeaderView.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 11.03.2022.
//

import SwiftUI


struct TableHeaderView: View {
    
    var onSavedButtonPressed: ((Bool)->Void)?
    var onHighCRPButtonPressed: ((Bool)->Void)?
    
    @State private var width = UIScreen.main.bounds.width
     
    var body: some View {
        ZStack(alignment: .center) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ButtonView(onButtonPressed: onSavedButtonPressed, buttonText: "Только сохранённые")
                    ButtonView(onButtonPressed: onHighCRPButtonPressed, buttonText: "Только с высоким C-рб")
                }
                .frame(height: 36)
                
            }
             }
        .padding(EdgeInsets(top: 0, leading: width / 20, bottom: 0, trailing: width / 20))
        .frame(width: width, height: 40)
    }
}

struct TableHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TableHeaderView()
    }
}
