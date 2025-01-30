//
//  TempTest.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/05.
//

import Foundation
import Testing

let echo = FileManager.default.homeDirectoryForCurrentUser
    .appending(path: "Downloads")
    .appending(path: "TestingEcho")

@Test func produce() throws
{
    let task = Process()
    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    
    task.launchPath = echo.path()
    task.arguments = ["-r", "stdout", "content"]
    task.standardOutput = stdoutPipe
    task.standardError = stderrPipe
    task.launch()
    
    let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    print(output ?? "")
}

@Test func startJVMWithLowLevelAPI() throws
{
    // Define the path to the Java executable
    let javaPath = "/usr/bin/java"
    
    // Specify JVM options, classpath, and main class
    let classpath = "" // Replace with your actual classpath
    let mainClass = "" // Replace with your main class
    let jvmOptions: [String] = ["-Xmx512m", "-Xms256m"] // JVM options
    let programArgs: [String] = ["arg1", "arg2"] // Java program arguments
    
    // Combine all arguments
    let arguments = ["java", "-cp", classpath] + jvmOptions + [mainClass] + programArgs
    
    // Convert arguments to C strings
    let argv = arguments.map { strdup($0) } + [nil]
    
    // Create file descriptors for pipes
    var outputPipe: [Int32] = [-1, -1]
    var errorPipe: [Int32] = [-1, -1]
    
    if pipe(&outputPipe) != 0 || pipe(&errorPipe) != 0
    {
        perror("failed to create pipes")
        return
    }
    
    // Initialize spawn attributes
    var spawnAttr: posix_spawnattr_t? = nil
    posix_spawnattr_init(&spawnAttr)
    
    // Initialize file actions
    var fileActions: posix_spawn_file_actions_t? = nil
    posix_spawn_file_actions_init(&fileActions)
    
    // Redirect stdout and stderr to pipes
    posix_spawn_file_actions_adddup2(&fileActions, outputPipe[1], STDOUT_FILENO)
    posix_spawn_file_actions_adddup2(&fileActions, errorPipe[1], STDERR_FILENO)
    posix_spawn_file_actions_addclose(&fileActions, outputPipe[0])
    posix_spawn_file_actions_addclose(&fileActions, errorPipe[0])
    
    // Spawn the JVM process
    var pid: pid_t = 0
    let status = posix_spawn(&pid, javaPath, &fileActions, &spawnAttr, argv, environ)
    
    // Clean up file actions and spawn attributes
    posix_spawn_file_actions_destroy(&fileActions)
    posix_spawnattr_destroy(&spawnAttr)
    
    // Free allocated argument strings
    for arg in argv
    {
        free(arg)
    }
    
    // Check spawn status
    if status == 0
    {
        print("JVM process started with PID: \(pid)")
        
        // Close the write ends of the pipes
        close(outputPipe[1])
        close(errorPipe[1])
        
        // Read output and error streams
        let output = FileHandle(fileDescriptor: outputPipe[0])
        let error = FileHandle(fileDescriptor: errorPipe[0])
        
        if let outputData = try? output.readToEnd(),
           let outputString = String(data: outputData, encoding: .utf8) {
            print("Standard Output:\n\(outputString)")
        }
        
        if let errorData = try? error.readToEnd(),
           let errorString = String(data: errorData, encoding: .utf8) {
            print("Standard Error:\n\(errorString)")
        }
        
        // Wait for the process to complete
        var exitStatus: Int32 = 0
        waitpid(pid, &exitStatus, 0)
        print("JVM process exited with status \(exitStatus)")
    } else {
        print("Failed to start JVM process with error code: \(status)")
    }
}
