1. Set a CSV path or pass a CSV as a string literal
2. Define a type that conforms to `CSVConvertible`
3. Parse away


```swift
  let testCSVString = """
      name,age,email
      Johnny,30,some@some.com
      Mary,23,this@that.com
      Mark,21,then@then.com
      """

  struct TestPerson: CSVConvertible {
      let name: String
      let age: String
      let email: String
      
      static var columnMappings: [String : any CodingKey] {
          ["name": CodingKeys.name, "age": CodingKeys.age, "email": CodingKeys.email]
      }
  }

    let parser = try CSVParser<TestPerson>(stringLiteral: testCSVString)
    let results = try parser.parse()
```
