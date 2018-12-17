//
//  Text.swift
//  Vision
//
//  Created by Ankit Jaiswal on 05/12/18.
//  Copyright © 2018 Ankit Jaiswal. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct Welcome: Codable {
    let responses: [Response]
}

struct Response: Codable {
    let textAnnotations: [TextAnnotation]
    let fullTextAnnotation: FullTextAnnotation
}

struct FullTextAnnotation: Codable {
    let pages: [Page]
    let text: String
}

struct Page: Codable {
    let property: PageProperty
    let width, height: Int
    let blocks: [Block]
}

struct Block: Codable {
    let boundingBox: Bounding
    let paragraphs: [Paragraph]
    let blockType: String
    let confidence: Double
}

struct Bounding: Codable {
    let vertices: [Vertex]
}

struct Vertex: Codable {
    let x, y: Int
}

struct Paragraph: Codable {
    let boundingBox: Bounding
    let words: [Word]
    let confidence: Double
}

struct Word: Codable {
    let property: WordProperty?
    let boundingBox: Bounding
    let symbols: [Symbol]
    let confidence: Double
}

struct WordProperty: Codable {
    let detectedLanguages: [PurpleDetectedLanguage]
}

struct PurpleDetectedLanguage: Codable {
    let languageCode: Locale?
}

enum Locale: String, Codable {
    case ar = "ar"
    case en = "en"
    case nl = "nl"
    case vi = "vi"
}

struct Symbol: Codable {
    let property: SymbolProperty?
    let boundingBox: Bounding
    let text: String
    let confidence: Double
}

struct SymbolProperty: Codable {
    let detectedLanguages: [PurpleDetectedLanguage]?
    let detectedBreak: DetectedBreak?
}

struct DetectedBreak: Codable {
    let type: TypeEnum?
}

enum TypeEnum: String, Codable {
    case eolSureSpace = "EOL_SURE_SPACE"
    case lineBreak = "LINE_BREAK"
    case space = "SPACE"
}

struct PageProperty: Codable {
    let detectedLanguages: [FluffyDetectedLanguage]?
}

struct FluffyDetectedLanguage: Codable {
    let languageCode: Locale?
    let confidence: Double
}

struct TextAnnotation: Codable {
    let locale: Locale?
    let description: String
    let boundingPoly: Bounding
}
