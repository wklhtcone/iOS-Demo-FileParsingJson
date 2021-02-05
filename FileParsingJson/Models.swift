//
//  Models.swift
//  FileParsingJson
//
//  Created by 王凯霖 on 2/5/21.
//

import Foundation


struct Result: Codable {
    let jsonData: [ResultItem]
}
struct ResultItem: Codable {
    let title: String
    let items: [String]
}


