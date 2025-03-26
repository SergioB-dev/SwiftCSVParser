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

struct GrammarByDuaRow: CSVConvertible {
    let dua: String
    let duaWithHarakat: String
    let source: String
    let sourceEnglish: String
    let englishTranslation: String
    let category: String
    let reasoning: String
    let keywords: [String]
    
    static var columnMappings: [String : any CodingKey] {
        [
            "dua": CodingKeys.dua,
            "duaWithHarakat": CodingKeys.duaWithHarakat,
            "source": CodingKeys.source,
            "sourceEnglish": CodingKeys.sourceEnglish,
            "englishTranslation": CodingKeys.englishTranslation,
            "category": CodingKeys.category,
            "reasoning": CodingKeys.reasoning,
            "keywords": CodingKeys.keywords
        ]
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

    @available(iOS 16.0, *)
    @Test func decodeFromFile() throws {
        let path = Bundle.module.url(forResource: "personFixture", withExtension: "csv")?.path() ?? ""
        print(path)
        let parser = try CSVParser<TestPerson>(csvPath: path)
        let results = try parser.parse()
        #expect(results.count > 0)
    }
    
    
    /// Correctly parses columns that have columns with ["x", "y", ...] format
    @available(iOS 16.0, *)
    @Test func decodeFileWithStringArrayColumn() throws {
        let path = Bundle.module.url(forResource: "grammarByDua", withExtension: "csv")?.path() ?? ""
        print(path)
        let parser = try CSVParser<GrammarByDuaRow>(csvPath: path)
        let loaded = try parser.parse()
        #expect(loaded.count > 0)
        #expect(Set(loaded[0].keywords) == Set(["ديني", "الدنيا"]))
    }
    
    @available(iOS 16.0, *)
    @Test func testParseWithLineCount() throws {
        let path = Bundle.module.url(forResource: "personFixture", withExtension: "csv")?.path() ?? ""
        print(path)
        let parser = try CSVParser<TestPerson>(csvPath: path)
        let result = try parser.parse(randomN: 2)
        #expect(result.count == 2)
    }
    
}

