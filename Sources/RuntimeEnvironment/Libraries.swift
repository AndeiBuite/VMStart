//
//  Libraries.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/04.
//

/// A library that provides access to JVM runtime environment packages hosted on a network.
public protocol NetworkRuntimeLibrary
{
    /// Searches for packages that meet the specified requirements.
    func search(requirements:[any RuntimeInspector]) throws -> any Sequence<(any RuntimeResource,RuntimeCompatibility)>
}

/// A library that provides access to JVM runtime environment packages stored locally on the device.
open class LocalRuntimeLibrary
{
    open var packages:[Runtime] = []
    
    open func search(requirements:[any RuntimeInspector]) throws -> any Sequence<(Runtime,RuntimeCompatibility)>
    {
        // calculate compatibilities to all packages.
        var examined:[(Runtime,RuntimeCompatibility)] = []
        for package in packages.lazy
        {
            var factors:[RuntimeCompatibility.Factor] = []
            for requirement in requirements.lazy
            {
                let factor = requirement.examine(package.metadata)
                factors.append(factor)
            }//^for requirements
            let compatibility:RuntimeCompatibility = RuntimeCompatibility(factors)
            let result:(Runtime,RuntimeCompatibility) = (package,compatibility)
            examined.append(result)
        }//^for packages
        
        // look for packages has a good compatibility.
        var result:[(Runtime,RuntimeCompatibility)] = []
        for package in examined
        {
            if package.1 < RuntimeCompatibility(inner:0)
            {
                continue
            }
            result.append(package)
        }//^for examined
        
        return result
    }
    
    init(packages:[Runtime])
    {
        self.packages = packages
    }
}

/// Initializes `LocalRuntimeLibrary` from a folder containing JVM runtime package bundles.
extension LocalRuntimeLibrary
{
    convenience init(libraryFolder folder:URL) throws
    {
        // check whether the provided folder exists and is a directory.
        var isDir:ObjCBool = false
        let exists = FileManager.default.fileExists(atPath:folder.path(), isDirectory:&isDir)
        if !exists || !isDir.boolValue
        {
            throw Errors.libraryFolderNotFound
        }
        
        // fetch all items in the folder. Further analysis will be done later.
        var subitems = try FileManager.default
            .contentsOfDirectory(at:folder, includingPropertiesForKeys:nil, options:[])
        
        // filter valid runtime packages (must have .jdk or .jre extensions).
        var bundles:[URL] = []
        for subitem in subitems
        {
            if subitem.pathExtension != "jdk" && subitem.pathExtension != "jre"
            {
                continue
            }
            bundles.append(subitem)
        }
        
        // convert each valid bundle into a Runtime instance.
        var packges:[Runtime] = []
        for bundle in bundles
        {
            let result = try Runtime(withBundleURL:bundle)
            packges.append(result)
        }
        
        self.init(packages:packges)
    }
    
    public enum Errors: Error
    {
        case libraryFolderNotFound
    }
}

/// Initializes `LocalRuntimeLibrary` from a predefined system or user-level directory.
extension LocalRuntimeLibrary
{
    public enum Level
    {
        case system
        case user
    }
    
    convenience init(level:Level) throws
    {
        let libraryFolder:URL = switch level
        {
            case .system: URL(fileURLWithPath:"/Library/Java/JavaVirtualMachines/")
            case .user: FileManager.default
                    .urls(for: .libraryDirectory, in: .userDomainMask)
                    .first!
                    .appending(component:"Java")
                    .appending(component:"JavaVirtualMachines")
        }
        try self.init(libraryFolder:libraryFolder)
    }
}
