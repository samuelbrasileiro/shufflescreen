//
//  ImageSwiftUI.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 25/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//
import SwiftUI

extension Image {

    public init?(data: Data?) {
        guard let data = data,
            let uiImage = UIImage(data: data) else {
                return nil
        }
        self = Image(uiImage: uiImage)
    }
    
    public init(data: Data?, placeholder: String) {
            guard let data = data,
              let uiImage = UIImage(data: data) else {
                self = Image(placeholder)
                return
            }
            self = Image(uiImage: uiImage)
        }
}
