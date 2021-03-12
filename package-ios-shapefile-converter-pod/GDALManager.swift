//
// Created by Ramirez, Luis Manuel on 12/03/21.
//

import Foundation

open class GDALManager {
    //
    // MARK: - Constants
    //
    private struct Constants {
        // Driver names:
        static let driverNameGeoJSON = "GeoJSON"
        static let driverNameESRIShp = "ESRI Shapefile"
        // Others:
        static let defaultGeneratedFileName = "OGRGeoJSON"
    }

    //
    // MARK: - Singleton
    //
    public static let shared = GDALManager()

    private init() {
    }

    //
    // MARK: - Public methods
    //
    public func performConversion(of geojson: String,
                                  destinationFileName: String) {
        FileManager.default.clearTmpDirectoryFromShapefiles(with: destinationFileName)
        FileManager.default.clearTmpDirectoryFromShapefiles(with: Constants.defaultGeneratedFileName)
        convertToShapefile(geojson: geojson)
        // By default GDAL library give the name OGRGeoJSON to the generated files when
        // the source is not a file (i.e. a string)
        // So we need to rename them to the intended file name:
        FileManager.default.renameTmpDirectoryShapefiles(from: Constants.defaultGeneratedFileName,
                to: destinationFileName)
    }

    //
    // MARK: - Private properties
    //
    private var driverNames: [String] {
        var driverNames = [String]()
        for i in 0..<OGRGetDriverCount() {
            let driver = OGRGetDriver(i)
            let driverName = String(cString: OGR_Dr_GetName(driver))
            driverNames.append(driverName)
        }
        return driverNames
    }

    //
    // MARK: - Private methods
    //
    private func convertToShapefile(geojson: String) {
        registerIfNeeded()
        let datasource = OGROpen(geojson, 0, nil)
        print("datasource = \(String(describing: datasource))")
        guard let out_driver = getDriverIfExists(by: Constants.driverNameESRIShp) else {
            return
        }
        print("out_driver = \(String(describing: out_driver))")
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shapefile = OGR_Dr_CreateDataSource(out_driver, destinationPath.path, nil)
        print("shapefile = \(String(describing: shapefile))")
        copyLayers(origin: datasource, destination: shapefile)
    }

    private func registerIfNeeded() {
        if GDALGetDriverCount() == 0 {
            GDALAllRegister()
        }
    }

    private func getDriverIfExists(by keyword: String) -> OGRSFDriverH? {
        if driverNames.contains(keyword) {
            return OGRGetDriverByName(keyword)
        }
        return nil
    }

    private func copyLayers(origin: OGRDataSourceH?, destination: OGRDataSourceH?) {
        let layerCount = OGR_DS_GetLayerCount(origin)
        for layerIndex in 0..<layerCount {
            let layer = OGR_DS_GetLayer(origin, layerIndex)

            let layerName = String(cString: OGR_L_GetName(layer), encoding: .utf8)
            print(layerName ?? "")

            let featureDefinition = OGR_L_GetLayerDefn(layer)

            let out_layer = OGR_DS_CreateLayer(destination, OGR_L_GetName(layer), OGR_L_GetSpatialRef(layer), OGR_L_GetGeomType(layer), nil)

            print(out_layer ?? "")

            for fieldIndex in 0..<OGR_FD_GetFieldCount(featureDefinition) {
                OGR_L_CreateField(out_layer, OGR_FD_GetFieldDefn(featureDefinition, fieldIndex), 1)
            }
            OGR_L_ResetReading(layer)
            var feat = OGR_L_GetNextFeature(layer)

            let featureCount = OGR_L_GetFeatureCount(layer, 1)
            print(featureCount)
            while feat != nil {
                let feature = OGR_F_Clone(feat)
                _ = OGR_L_CreateFeature(out_layer, feature)
                OGR_F_Destroy(feat)
                OGR_F_Destroy(feature)
                feat = OGR_L_GetNextFeature(layer)
            }

            OGR_DS_Destroy(origin)
            OGR_DS_Destroy(destination)
            OGRCleanupAll()
        }
    }
}
