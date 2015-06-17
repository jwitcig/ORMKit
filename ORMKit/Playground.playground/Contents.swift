//: Playground - noun: a place where people can play

import Cocoa


class Super {
    func makeNoise() {
        println("super noise")
    }
    
    class var name: String { return "Super" }
}


class Sub: Super {
    
    override func makeNoise() {
        println("sub noise")
    }
    
    override class var name: String { return "Sub" }
    
}


func checher(model: Super.Type) -> String {
    return model.name
}



checher(Sub)