//
//  OpenJDKTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/30.
//

import Foundation
import Testing
import SwiftSoup
@testable import VMStart

@Test func analyzeReleaseListTest() throws
{
    let result = try OpenJDK.Releases.resolveToList()
    let cacheFile = URL(fileURLWithPath: "/Users/andei_buite/Workspaces/VMStart/Archived OpenJDK Release Cache")
    
    try result.string.write(to: cacheFile, atomically: true, encoding: .utf8)
}


private extension [OpenJDK.RuntimeMetadata]
{
    var string: String
    {
        get
        {
            var result = "["
            for (index, item) in self.enumerated()
            {
                result.append("\n\tRuntimeMetadata{ version:\(item.version), platform:\(item.platform), downloadLink:\(item.downloadLink) },")
                if index == self.count-1
                {
                    result.append("\n")
                }
            }
            result.append("]")
            return result
        }
    }
}
