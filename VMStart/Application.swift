//
//  Application.swift
//  VMStart
//
//  Created by Andei Buite on 2025/02/05.
//

import Foundation

public protocol Application
{
    var applicationName:String { get }
    var mainClass:String { get }
    var defaultArguments:[String] { get }
    var files:ApplicationFiles { get }
}

public enum ApplicationFiles
{
    case archive(path:URL)
    case classes(files:[URL])
}
