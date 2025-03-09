//
//  FileChangesWatcherTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/05.
//

import Foundation
import Testing
@testable import VMStart

@Test func watchingTest() throws
{
    let targetFile = URL(fileURLWithPath: "/Users/andei_buite/Workspaces/VMStart.workspace")
    let _ = FileChangeObserver(watchingFile: targetFile)
    {
        print("folder changed")
    }
    let _ = readLine()
}
