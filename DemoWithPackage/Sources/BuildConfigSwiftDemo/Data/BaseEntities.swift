//
//  BaseEntities.swift
//  BuildConfigSwiftDemo
//
//  Created by 417.72KI on 2023/10/05.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import Foundation

protocol Request: Encodable, Hashable {
}

protocol Response: Decodable, Hashable {
}
