// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation


public struct CSVParser<T: CSVConvertible> {
    let headers: [String]
    var nonHeaderRows: [[String]]
    
    public init(csvPath: String, encoding: String.Encoding = .utf8) throws {
        let content = try String(contentsOfFile: csvPath, encoding: encoding)
        (headers, nonHeaderRows) = try Self.separateHeadersFromRows(from: content)
    }
    
    public init(stringLiteral: String, encoding: String.Encoding = .utf8) throws {
        (headers, nonHeaderRows) = try Self.separateHeadersFromRows(from: stringLiteral)
    }
    
    static private func separateHeadersFromRows(from string: String) throws -> (headers: [String], nonHeaderRows: [[String]]) {
        var headers: [String] = []
        var nonHeaderRows: [[String]] = []
        
        let lines = string.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
        guard let headerLine = lines.first else { throw CSVDecodingError.invalidCSVFormat }
        
        headers = headerLine.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",").map { String($0) }
        let rows = lines
            .dropFirst()
            .map { $0.components(separatedBy: ",").map { String($0) } }
            
        nonHeaderRows = rows
        return (headers, nonHeaderRows)
    }
    
    public func parse() throws -> [T] {
        let decoder = CSVDecoder<T>()
        var results: [T] = []
        
        for row in nonHeaderRows {
            guard row.count == headers.count else { throw CSVDecodingError.invalidCSVFormat }
            let rowDict = Dictionary(uniqueKeysWithValues: zip(headers, row))
            
            let decodedRow = try decoder.decode(row: rowDict)
            results.append(decodedRow)
        }
        
        return results
    }
}

public protocol CSVConvertible: Decodable {
    static var columnMappings: [String: CodingKey] { get }
}


public enum CSVDecodingError: Error {
    case invalidCSVFormat
    case cannotFindFile
    case missingRequiredColumn(String)
}

