//
//  VirtualMachineTests.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/19.
//

import Testing
@testable import VMStart

public struct VirtualMachineTests
{
    @Test func composingCommandLineFromConfigurationTest() async throws
    {
        let configuration = VirtualMachineConfiguration(
            jre:try! Runtime(withBundleURL:URL(filePath:"/Library/Java/JavaVirtualMachines/zulu_17_FX.jdk")),
            env:ProcessInfo.processInfo.environment,
            workingDirectory:URL(filePath:"/root/"),
            properties:["property":"value"],
            classpath:[URL(filePath:"/Users/andei_buite/Downloads/jar")],
            main: .clazz("com.example.main"),
            arguments:["-help", "-someArgs"]
        )
        
        let commandLine = configuration.commandLine
        let expected =
        [
            "/Library/Java/JavaVirtualMachines/zulu_17_FX.jdk/Contents/Home/bin/java",
            "-Dproperty=value",
            "-cp", "/Users/andei_buite/Downloads/jar",
            "com.example.main",
            "-help", "-someArgs"
        ]
        
        assert(commandLine == expected)
    }
    
    @Test func initliazeAndStartVMTest() async throws
    {
        let configuration = VirtualMachineConfiguration(
            jre:try! Runtime(withBundleURL:URL(filePath:"/Library/Java/JavaVirtualMachines/zulu_17_FX.jdk")),
            env:ProcessInfo.processInfo.environment,
            workingDirectory:URL(filePath:"/Users/andei_buite/Workspaces/VMStart.workspace"),
            properties:["property":"value"],
            classpath:[URL(filePath:"/Users/andei_buite/Workspaces/VMStart.workspace/Printout.jar")],
            main: .clazz("PrintoutApp"),
            arguments:["--mode=graphics", "-someArgs"]
        )
    }
}
