//
//  VirtualMachine.swift
//  VMStart
//
//  Created by Andei Buite on 2025/04/19.
//

import Foundation

/// A configuration model that defines all necessary information required
/// to launch a virtual machine process.
///
/// This structure does not represent a running virtual machine instance.
/// Instead, it encapsulates the runtime environment and process-level
/// configuration needed to initialize and start a VM.
///
/// This struct may be used to persist the fundamental configuration of a
/// virtual machine. However, additional runtime data is required to fully
/// restore a running VM. In other words, restoring from this configuration
/// alone will not recover a VM in its exact running state. Consider using
/// memory snapshots or memory mappings for that purpose.
///
/// Use this model to prepare launch arguments, environment variables,
/// working directory, and other runtime settings. Pass it to a VM-launching
/// extension or utility based on `Process` to create a running instance.
public struct VirtualMachineConfiguration
{
    public var jre:Runtime
    public var env:[String:String]
    public var workingDirectory:URL
    public var properties:[String:String]
    public var options:[CustomStringConvertible]
    public var classpath:[URL]
    public var main:ExecutionMain
    public var arguments:[String]
    
    public enum ExecutionMain
    {
        case clazz(String)
        case archive(URL)
    }
    
    public enum StandardOptions
    {
        /// Loads the specified native agent library. which Equivalent to the JVM option: -agentlib:libname[=options]
        ///
        ///     agentlib(libname:"jdwp",options:"transport=dt_socket,server=y,address=8000")
        ///
        /// The library must be located in the appropriate system path.
        case agentlib(libname:String, options: String? = nil)
    }
}

/// Converts the standard option into its corresponding JVM command-line string.
extension VirtualMachineConfiguration.StandardOptions: CustomStringConvertible
{
    public var description:String
    {
        switch self {
            case .agentlib(let libname, let options):
                // Constructs the agentlib option as: -agentlib:libname or -agentlib:libname=options
                if let options, !options.isEmpty {
                    return "-agentlib:\(libname)=\(options)"
                } else {
                    return "-agentlib:\(libname)"
                }
        }
    }
    
}

extension VirtualMachineConfiguration
{
    public var commandLine:[String]
    {
        var result:[String] = []
        
        // pre-processing
        let executable = jre.files.executable.path()
        let properties = self.properties.lazy.map{ "-D\($0.0)=\($0.1)" }
        let classpath = ["-cp", self.classpath.lazy.map{ $0.path() }.joined(separator:":")]
        let main = switch main
        {
            case .clazz(let clazz): clazz
            case .archive(let archive): "-jar \(archive.path())"
        }
        let arguments = self.arguments
        
        // composing command line
        result.append(executable)
        result += properties
        result += classpath
        result.append(main)
        result += arguments
        
        return result
    }
}

extension Process
{
    convenience init(using configuration:VirtualMachineConfiguration) throws
    {
        self.init()
        self.executableURL = configuration.jre.files.executable
        self.arguments = configuration.commandLine
        self.environment = configuration.env
        self.currentDirectoryURL = configuration.workingDirectory
    }
}
