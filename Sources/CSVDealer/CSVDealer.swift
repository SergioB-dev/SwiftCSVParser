// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation


public struct CSVParser<T: CSVConvertible> {
    let headers: [String]
    var nonHeaderRows: [[Any]]
    
    public init(csvPath: String, encoding: String.Encoding = .utf8) throws {
        let content = try String(contentsOfFile: csvPath, encoding: encoding)
        (headers, nonHeaderRows) = try Self.separateHeadersFromRows(from: content)
    }
    
    public init(stringLiteral: String, encoding: String.Encoding = .utf8) throws {
        (headers, nonHeaderRows) = try Self.separateHeadersFromRows(from: stringLiteral)
    }
    
    static private func separateHeadersFromRows(from string: String) throws -> (headers: [String], nonHeaderRows: [[Any]]) {
        var headers: [String] = []
        var nonHeaderRows: [[Any]] = []
        
        // Parse the CSV properly, respecting quotes
        let parsedRows = try parseCSVRespectingQuotes(string)
        
        guard let headerLine = parsedRows.first, !headerLine.isEmpty else {
            throw CSVDecodingError.invalidCSVFormat
        }
        
        headers = headerLine.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Process the non-header rows, converting array strings to actual arrays
        nonHeaderRows = parsedRows.dropFirst().map { row in
            return row.map { field in
                // Check if this field looks like a JSON array
                if field.hasPrefix("[") && field.hasSuffix("]") {
                    do {
                        // Try to parse it as a JSON array of strings
                        if let data = field.data(using: .utf8),
                           let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String] {
                            return jsonArray
                        }
                    } catch {
                        // If parsing fails, just return the original string
                        print("Failed to parse JSON array: \(error)")
                    }
                }
                // Return the field as is if it's not a JSON array
                return field
            }
        }
        
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
    
    // Helper function to parse CSV while respecting quotes
    static private func parseCSVRespectingQuotes(_ csvString: String) throws -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        // Add handling for escaped quotes within quoted fields
        let chars = Array(csvString)
        var i = 0
        
        while i < chars.count {
            let char = chars[i]
            
            switch char {
            case "\"":
                if insideQuotes && i + 1 < chars.count && chars[i + 1] == "\"" {
                    // This is an escaped quote inside a quoted field
                    currentField.append("\"")
                    i += 1 // Skip the next quote
                } else {
                    // Toggle the quote state
                    insideQuotes = !insideQuotes
                }
            case ",":
                if insideQuotes {
                    // Comma inside quotes - add it to the current field
                    currentField.append(char)
                } else {
                    // Comma outside quotes - end of field
                    currentRow.append(currentField)
                    currentField = ""
                }
            case "\n", "\r":
                if insideQuotes {
                    // Newline inside quotes - add it to the current field
                    currentField.append(char)
                } else {
                    // Handle \r\n sequence
                    if char == "\r" && i + 1 < chars.count && chars[i + 1] == "\n" {
                        i += 1 // Skip the next \n
                    }
                    
                    // Newline outside quotes - end of row
                    currentRow.append(currentField)
                    rows.append(currentRow)
                    currentRow = []
                    currentField = ""
                }
            default:
                // Any other character - add to the current field
                currentField.append(char)
            }
            
            i += 1
        }
        
        // Add the last field and row if there's anything pending
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            rows.append(currentRow)
        }
        
        return rows
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

