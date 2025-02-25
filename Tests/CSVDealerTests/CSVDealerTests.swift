import Testing
@testable import CSVDealer
import Foundation

struct TestPerson: CSVConvertible {
    let name: String
    let age: String
    let email: String
    
    static var columnMappings: [String : any CodingKey] {
        ["name": CodingKeys.name, "age": CodingKeys.age, "email": CodingKeys.email]
    }
}
final class CSVParserTests {
    @Test func decodeFromString() throws {
        let testCSVString = """
            name,age,email
            Johnny,30,some@some.com
            Mary,23,this@that.com
            Mark,21,then@then.com
            """
        
        let parser = try CSVParser<TestPerson>(stringLiteral: testCSVString)
        let results = try parser.parse()
        
        #expect(results.count == 3)
        #expect(results[0].email == "some@some.com")
        #expect(results[0].name == "Johnny")
        #expect(results[0].age == "30")
    }

    @Test func decodeFromFile() throws {

        if let resourcePath = Bundle(for: CSVParserTests.self).resourcePath {
            let fileManager = FileManager.default
            do {
                let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
                print("Files in bundle: \(items)")
            } catch {
                print("Could not list files in bundle: \(error)")
            }
        }
        
        // In test code, use the test bundle instead of Bundle.main
        let path = Bundle.module.url(forResource: "personFixture", withExtension: "csv")?.path() ?? ""
        print(path)
        let parser = try CSVParser<TestPerson>(csvPath: path)
        let results = try parser.parse()
    }
}

