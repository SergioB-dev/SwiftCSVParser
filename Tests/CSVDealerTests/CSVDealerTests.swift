import Testing
@testable import CSVDealer

struct TestPerson: CSVConvertible {
    let name: String
    let age: String
    let email: String
    
    static var columnMappings: [String : any CodingKey] {
        ["name": CodingKeys.name, "age": CodingKeys.age, "email": CodingKeys.email]
    }
    
}

@Test func decodeType() async throws {
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
