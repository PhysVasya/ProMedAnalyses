//
//  LoginViewSwiftUI.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 08.03.2022.
//

import SwiftUI


struct LoginViewSwiftUI: View {
    
    var sendData : ((String, String) -> Void)?
    
    @State private var login: String = ""
    @State private var password: String = ""
    @State private var isAnimating: Bool = false
    @State private var imageOffset: CGSize = .zero
    
    var body: some View {
        
        //MARK: - 1. TOP
        VStack {
            VStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1), value: isAnimating)
                    .shadow(color: Color(.systemGray), radius: 4, x: 2, y: 4)
                    .offset(x: imageOffset.width * 1.2)
                    .rotationEffect(.degrees(Double(imageOffset.width / 10)))
                    .gesture(
                    DragGesture()
                        .onChanged({ value in
                            if abs(imageOffset.width) <= 20 {
                                withAnimation(.linear(duration: 1)) {
                                    imageOffset = value.translation

                                }

                            }
                        })
                        .onEnded({ _ in
                            withAnimation(.linear(duration: 1)) {
                                imageOffset = .zero

                            }
                        })
                    )
                    
                Spacer()
                Text("ПроМед Анализы")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                Spacer()
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : -40)
            .animation(.easeOut(duration: 0.5), value: isAnimating)
            
            
            //MARK: - 2. CENTER
            VStack {
                VStack(alignment: .leading) {
                    Text("Логин:")
                        .font(.system(size: 14, design: .rounded))
                    TextField(
                        "Введите логин",
                        text: $login
                    )
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                } // VSTACK
                VStack(alignment: .leading) {
                    Text("Пароль:")
                        .font(.system(size: 14, design: .rounded))
                    SecureField (
                        "Введите пароль",
                        text: $password
                    )
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                    
                }
            }
            .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeOut(duration: 0.5), value: isAnimating)
            
            //MARK: - 3. BOTTOM Button
            
            VStack(alignment: .leading) {
                Button("Забыли пароль?"){
                    print("KEK")
                }
                .font(.system(size: 14))
                ZStack {
                    Button() {
                        if login != "" && password != "" {
                            sendData?(login, password)
                        }
                    } label: {
                        Text("Просмотр пациентов")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .frame(width: UIScreen.main.bounds.width - 80, height: 50, alignment: .center)
                    .background(Color(.systemOrange))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(Color(.white))
                }
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 40)
            .animation(.easeOut, value: isAnimating)
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}
//
//struct LoginViewSwiftUI_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginViewSwiftUI(sendData: )
//    }
//}
