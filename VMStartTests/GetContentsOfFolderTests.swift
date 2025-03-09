//
//  GetContentsOfFolderTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/12.
//

import Foundation
import Testing

@Test func listFolderContentsTest() async throws
{
    let folder = URL(fileURLWithPath: "/etc/")
    let subitems = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    print(subitems)
}

