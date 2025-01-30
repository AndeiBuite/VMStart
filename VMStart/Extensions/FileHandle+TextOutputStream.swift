//
//  FileHandle+TextOutputStream.swift
//  VMStart
//
//  Created by Andei Buite on 2025/01/24.
//

import Foundation

var stderr = FileHandle.standardError

extension FileHandle: @retroactive TextOutputStream
{
    public func write(_ string: String)
    {
        let data = Data(string.utf8)
        self.write(data)
    }
}
