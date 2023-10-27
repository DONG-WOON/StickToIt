//
//  FileManagerError.swift
//  StickToIt
//
//  Created by 서동운 on 10/28/23.
//

import Foundation

enum FileManagerError: Error {
    case invalidDirectory
    case emptyData
    case fileSaveError
    case fileIsNil
}
