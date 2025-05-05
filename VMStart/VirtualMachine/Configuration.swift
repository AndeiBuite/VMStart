//
//  Configuration.swift
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
    /// The runtime environment that includes the Java executable and related paths.
    public var javaRuntime:Runtime
    
    /// Key-value pairs representing environment variables for the virtual machine process.
    public var environment:[String:String]
    
    /// The working directory in which the virtual machine process will start.
    public var workingDirectory:URL
    
    /// JVM system properties (e.g., -Dkey=value).
    public var properties:[String:String]
    
    /// JVM options or flags that conform to `CustomStringConvertible`.
    ///
    /// These options can be in ``StandardOptions`` or in ``String`` directly,
    /// might you write a enumration or struct to hold your custom options, make
    /// sure it conforms to ``CustomStringConvertible`` with a `description`
    /// property that returns the correct command-line representation.
    ///
    /// Note: To specify an argument for a long option, you can use either --name=value or --name value.
    public var options:[CustomStringConvertible]
    
    /// A list of URLs representing the Java classpath.
    public var classpath:[URL]
    
    /// The main entry point for the virtual machine, either a class name or a JAR file.
    public var main:ExecutionMain
    
    /// Application arguments to be passed to the main method.
    public var arguments:[String]?
    
    public var currentDirectoryURL:URL?
    
    public var terminationHandler:(@Sendable (Process) -> Void)?
    
    /// Standard IO & E
    public var standardOutput: FileHandle
    public var standardInput: FileHandle
    public var standardError: FileHandle
    
    
    /// Entry point for a Java Virtual Machine (JVM).
    public enum ExecutionMain
    {
        case clazz(String)
        case archive(URL)
    }
    
    /// Commonly used standard options for launching a Java virtual machine (JVM), that are formulated
    /// by java standard and are available to every distributions from any builders.
    ///
    /// Each case corresponds to a recognized command-line option supported by the `java` command.
    /// These options include configuration flags for enabling assertions, specifying module paths,
    /// setting agents, and more.
    ///
    /// This enumeration is designed by [The Java Command documentation]("https://docs.oracle.com/en/java/javase/17/docs/specs/man/java.html#standard-options-for-java").
    public enum StandardOptions
    {
        /// Loads the specified native agent library.
        /// Equivalent to the JVM option: -agentlib:libname[=options]
        ///
        ///     agentlib(libname:"jdwp", options:"transport=dt_socket,server=y,address=8000")
        ///
        /// On macOS, the library must be found in DYLD_LIBRARY_PATH.
        case agentlib(libname:String, options:String? = nil)
        
        /// Loads the native agent library specified by the absolute path name.
        /// Equivalent to the JVM option: -agentpath:pathname[=options]
        ///
        ///     agentpath(pathname:"/usr/lib/libjdwp.dylib", options:"transport=dt_socket")
        case agentpath(pathname:String, options:String? = nil)
        
        /// Loads the specified Java language agent.
        /// Equivalent to the JVM option: -javaagent:jarpath[=options]
        case javaagent(jarpath:String, options:String? = nil)
        
        /// Enables assertions for the given class or package.
        /// Equivalent to the JVM option: -ea[:<target>]
        ///
        ///     enableassertions()                 // Enables globally
        ///     enableassertions(target:"com.foo") // Enables for class or package
        case enableassertions(target:String? = nil)
        
        /// Disables assertions for the given class or package.
        /// Equivalent to the JVM option: -da[:<target>]
        case disableassertions(target:String? = nil)
        
        /// Enables assertions in all system classes.
        /// Equivalent to: -esa
        case enablesystemassertions
        
        /// Disables assertions in all system classes.
        /// Equivalent to: -dsa
        case disablesystemassertions
        
        /// Enables preview features in the current release.
        /// Equivalent to: --enable-preview
        case enablePreview
        
        /// Shows module resolution output during startup.
        /// Equivalent to: --show-module-resolution
        case showModuleResolution
        
        /// Lists observable modules and then exits.
        /// Equivalent to: --list-modules
        case listModules
        
        /// Describes the specified module and then exits.
        /// Equivalent to: --describe-module <module>
        case describeModule(moduleName:String)
        
        /// Runs the JVM without executing the main method.
        /// Useful for validating configuration. Equivalent to: --dry-run
        case dryRun
        
        /// Validates all modules and exits.
        /// Equivalent to: --validate-modules
        case validateModules
        
        /// Adds root modules to resolve.
        /// Equivalent to: --add-modules <mod1>,<mod2>
        case addModules([String])
        
        /// Specifies the module path (i.e., where modules are located).
        /// Equivalent to: --module-path or -p
        case modulePath([String])
        
        /// Specifies a path to replace upgradeable modules.
        /// Equivalent to: --upgrade-module-path
        case upgradeModulePath([String])
        
        /// Disables argument file expansion.
        /// Equivalent to: --disable-@files
        case disableAtFiles
        
        /// Enables verbose output for the specified component.
        /// Equivalent to: -verbose:class|gc|jni|module
        case verbose(String)
        
        /// Shows a splash screen with the specified image.
        /// Equivalent to: -splash:<imagepath>
        case splash(imagePath:String)
        
        /// Prints the Java version and exits.
        /// Equivalent to: -version or --version
        case showVersion
        
        /// Prints help message to stdout or stderr.
        /// Equivalent to: -help, --help, -?, --help-extra, -X
        case help
        
        /// Includes the contents of the specified argument file.
        /// Equivalent to: @filename
        case argfile(String)
    }
}

/// Converts the standard option into its corresponding JVM command-line string.
extension VirtualMachineConfiguration.StandardOptions: CustomStringConvertible
{
    public var description:String
    {
        return switch self
        {
            // -agentlib:libname[=options]
            case .agentlib(let libname, let options): if let options, !options.isEmpty
                { "-agentlib:\(libname)=\(options)" } else { "-agentlib:\(libname)" }

            // -agentpath:pathname[=options]
            case .agentpath(let pathname, let options): if let options, !options.isEmpty
                { "-agentpath:\(pathname)=\(options)" } else { "-agentpath:\(pathname)" }
            
            // -javaagent:jarpath[=options]
            case .javaagent(let jarpath, let options): if let options, !options.isEmpty
                { "-javaagent:\(jarpath)=\(options)" } else { "-javaagent:\(jarpath)" }
            
            // -enableassertions[:[packagename]...|:classname]
            case .enableassertions(let target): if let target, !target.isEmpty
                { "-ea:\(target)" } else { "-ea" }
                
            // -disableassertions[:[packagename]...|:classname]
            case .disableassertions(let target): if let target, !target.isEmpty
                { "-da:\(target)" } else { "-da" }
                
            // --describe-module module_name
            case .describeModule(let moduleName): "--describe-module \(moduleName)"
                
            // -splash:<imagepath>
            case .splash(let imagePath): "-splash:\(imagePath)"
                
            case .enablesystemassertions: "-enablesystemassertions"
            case .disablesystemassertions: "-disablesystemassertions"
            case .enablePreview: "--enable-preview"
            case .showModuleResolution: "--show-module-resolution"
            case .dryRun: "--dry-run"
            case .listModules: "--list-modules"
            case .validateModules: "--validate-modules"
            case .showVersion: "-version"
            case .help: "-help"
            case .disableAtFiles: "--disable-@files"
                
            // --add-modules module[,module...]
            case .addModules(let modules): "--add-modules \(modules.joined(separator:","))"
            
            // --module-path modulepath[;modulepath...]
            case .modulePath(let modulePaths): "--module-path \(modulePaths.joined(separator:";"))"
                
            // --upgrade-module-path modulepath[;modulepath...]
            case .upgradeModulePath(let modulePaths): "--upgrade-module-path \(modulePaths.joined(separator:";"))"
            
            // -verbose:(class|gc|jni|module)
            case .verbose(let component): "-verbose:\(component)"
            
            // @filename
            case .argfile(let filename): "@\(filename)"
        }
    }
}

/// Initializes the `Process` instance with the specified `VirtualMachineConfiguration`.
extension Process
{
    convenience init(using configuration:VirtualMachineConfiguration) throws
    {
        func arguments(of configuration:VirtualMachineConfiguration)-> [String]
        {
            var result:[String] = []
            
            // pre-processing
            let properties = configuration.properties.lazy.map{ "-D\($0.0)=\($0.1)" }
            let classpath = ["-cp", configuration.classpath.lazy.map{ $0.path() }.joined(separator:":")]
            let main = switch configuration.main
            {
                case .clazz(let clazz): clazz
                case .archive(let archive): "-jar \(archive.path())"
            }
            guard let arguments = self.arguments else { return [String]() }
            
            // composing command line
            result += properties
            result += classpath
            result.append(main)
            result += arguments
            
            return result
        }
        
        self.init()
        self.executableURL = configuration.javaRuntime.files.executable
        self.arguments = arguments(of:configuration)
        self.environment = configuration.environment
        self.currentDirectoryURL = configuration.workingDirectory
    }
}
