//
//  main.swift
//  Example
//
//  Created by Andei Buite on 2025/02/03.
//

import Foundation
import VMStart

@main
public class ExampleApp
{
    public struct Library
    {
        public static var shared = Library(jar: URL(fileURLWithPath: "/Users/andei_buite/Workspaces/VMStart/example.jar"))
        
        public var applicationJar: URL
        
        init(jar: URL)
        {
            self.applicationJar = jar
        }
    }
    
    public static func main() async throws
    {
        
    }
}
