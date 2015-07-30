//: Playground - noun: a place where people can play

import Cocoa
import CloudKit


class Super {
    
    enum List: String {
        case basic, items
    }
    
    static var subtypes: [String: AnyClass] = [
        "Test": Test.self
    ]
    
    var somePlaceHolder = ""
    
    required init() {}

}

class Test: Super {
    
    enum List: String {
        case number1
        case number2
        
    }
}


let hey = Test() as! Super

let tester = hey.dynamicType.List(rawValue: "number1")

tester



let type = Super.subtypes["Test"]

var holder = type

h