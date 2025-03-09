//
//  ReleaseFileAnalyzingTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/12.
//

import Foundation
import Testing
@testable import VMStart

private let packageURL = URL(fileURLWithPath:"/Library/Java/JavaVirtualMachines/zulu_17_FX.jdk")

@Test func analyzeToRuntimeMetadataTest() async throws
{
    let releaseInfo = try String(contentsOf: packageURL.appending(components:"Contents","Home","release"), encoding: .utf8)
    let runtimeMetadata = try RuntimeMetadata(withReleaseInformation:releaseInfo.split(separator:"\n").map{ String($0) })
    
    print(runtimeMetadata)
}

@Test func analyzeToRuntimeTest() async throws
{
    let runtime = try Runtime(packageURL:packageURL)
    
    print(runtime.files)
}
