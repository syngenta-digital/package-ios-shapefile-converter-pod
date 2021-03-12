//
// Created by Ramirez, Luis Manuel on 12/03/21.
//

import Foundation

public extension FileManager {

    static let shapefileExtensions = ["dbf", "prj", "shp", "shx"]

    func clearTmpDirectoryFromShapefiles(with filename: String) {
        var possibleNamesWithExtension = [String]()
        for fileExtension in FileManager.shapefileExtensions {
            let fileFullName = "\(filename).\(fileExtension)"
            possibleNamesWithExtension.append(fileFullName)
        }
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { [unowned self] file in
                if possibleNamesWithExtension.contains(file) {
                    let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                    try self.removeItem(atPath: path)
                }
            }
        } catch {
            print(error)
        }
    }

    func getShapsFilesInTemporaryDirectory() -> [URL]? {
        var shapsFiles: [URL]? = nil
        do {
            let files = try contentsOfDirectory(
                    at: URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true),
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles)
            shapsFiles = files.filter({ FileManager.shapefileExtensions.contains($0.pathExtension) })
        } catch {
            print(error)
        }
        return shapsFiles
    }

    func renameTmpDirectoryShapefiles(from originalFilename: String, to finalFilename: String) {
        var possibleNamesWithExtension = [String]()
        for fileExtension in FileManager.shapefileExtensions {
            let fileFullName = "\(originalFilename).\(fileExtension)"
            possibleNamesWithExtension.append(fileFullName)
        }
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                if possibleNamesWithExtension.contains(file) {
                    var currentExtension = ""
                    let fileNameArray = file.components(separatedBy: ".")
                    if fileNameArray.count == 2 {
                        currentExtension = fileNameArray.last ?? ""
                        if !currentExtension.isEmpty {
                            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                            // Rename file
                            var url = URL(fileURLWithPath: path)
                            var rv = URLResourceValues()
                            rv.name = "\(finalFilename).\(currentExtension)"
                            try url.setResourceValues(rv)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }

    func clearAllTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { [unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}