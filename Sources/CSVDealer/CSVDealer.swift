// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation


struct CSVParser<T: CSVConvertible> {
    private let headers: [String]
    private var nonHeaderRows: [[String]]
    
    init?(csvPath: String, encoding: String.Encoding = .utf8) throws {
        
        let content = try String(contentsOfFile: csvPath, encoding: encoding)
        
        var interimResults = [[String]]()
        content.components(separatedBy: "\n").forEach { line in
            let columns = line.split(separator: ",").map(String.init)
            interimResults.append(columns)
        }
        guard let interimHeaders = interimResults.first else { throw CSVDecodingError.invalidCSVFormat }
        
        headers = interimHeaders
        nonHeaderRows = interimResults
    }
    
    init(stringLiteral: String, encoding: String.Encoding = .utf8) throws {
        let lines = stringLiteral.components(separatedBy: "\n")
        guard let headerLine = lines.first else { throw CSVDecodingError.invalidCSVFormat }
        headers = headerLine.components(separatedBy: ",").map { String($0) }
        
        let rows = lines
            .dropFirst()
            .map { $0.components(separatedBy: ",").map { String($0) } }
            
        nonHeaderRows = rows
    }
    
    func parse() throws -> [T] {
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

protocol CSVConvertible: Decodable {
    static var columnMappings: [String: CodingKey] { get }
}

private struct CSVDecoder<T: CSVConvertible> {
    func decode(row: [String: String]) throws -> T {
        var decodedValues: [String: Any] = [:]
        
        for (csvColumn, codingKey) in T.columnMappings {
            guard let value = row[csvColumn] else { throw CSVDecodingError.missingRequiredColumn(csvColumn) }
            decodedValues[codingKey.stringValue] = value
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: decodedValues)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}

enum CSVDecodingError: Error {
    case invalidCSVFormat
    case missingRequiredColumn(String)
}

