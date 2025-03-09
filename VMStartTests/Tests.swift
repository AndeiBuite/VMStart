//
//  Tests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/12.
//

import Foundation
import Testing
@testable import VMStart

@Test func getExtensionNameTest() async throws
{
    let item = URL(fileURLWithPath: "/Users/andei_buite/Workspaces/VMStart.workspace/Release File Examples.md")
    print(item.pathExtension)
}
