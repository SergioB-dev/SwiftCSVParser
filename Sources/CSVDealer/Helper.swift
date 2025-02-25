//
//  File.swift
//  CSVDealer
//
//  Created by Sergio Bost on 2/24/25.
//

import Foundation

struct CSVDecoder<T: CSVConvertible> {
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
