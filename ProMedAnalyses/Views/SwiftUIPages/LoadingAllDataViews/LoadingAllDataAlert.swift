//
//  LoadingAllDataAlert.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 12.03.2022.
//

import SwiftUI


struct LoadingAllDataAlert: View {
    @State var loadingStatus: Double = 0.0
    @State var shouldDisappear: Bool = false
    var shouldStayOnScreen: ((Bool) -> Void)?
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width / 40, style: .circular)
                .foregroundColor(Color(UIColor.systemBackground))
            VStack {
                Text("Загрузка")
                    .font(.system(size: 16, weight: .bold))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                VStack {
                    ZStack {
                        if !shouldDisappear {
                            OnDisappear(double: $loadingStatus)
                        } else {
                            DoneSuccessfully(isAnimating: false)
                        }
                    }
                }
                .padding()
                .transition(.scale)
                Text("Пожалуйста, подождите...")
                    .font(.system(size: 14, weight: .regular))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .opacity(shouldDisappear ? 0 : 1)
                
            }
        }
        .frame(width: UIScreen.main.bounds.width - 50, height: 200, alignment: .center)
        .onAppear {
            Task.init {
                await APICallManager.shared.downloadAll() { double in
                    guard let double = double else {
                        return
                    }
                    
                    loadingStatus = double
                    print(double)
                    if loadingStatus != 1.0 {
                        shouldDisappear = false
                    } else {
                        shouldDisappear = true
                    }
                }
            }
        }
        .onChange(of: shouldDisappear) { newValue in
            HapticsManager.shared.vibrate(for: .success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                shouldStayOnScreen?(!newValue)
                
            }
        }
    }
}

struct LoadingAllDataAlert_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAllDataAlert(loadingStatus: 0.241)
    }
}
