//
//  Tests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/06.
//

import Foundation
import Testing

private func extractModules(_ content:String) -> [String]
{
    let lines = content.split(separator: "\n")
    
    var modules:String = ""
    for line in lines
    {
        if !line.hasPrefix("MODULES=") { continue }
        if let start = line.range(of: "\"")?.upperBound, let end = line.range(of: "\"", options: .backwards)?.lowerBound
        {
            modules = String(line[start..<end])
        }
    }
    return modules.split(separator: " ").map{ String($0) }
}
