//
//  AirportFactory.swift
//  2018-sqlite
//
//  Created by Diederich Kroeske on 18/09/2018.
//  Copyright © 2018 Diederich Kroeske. All rights reserved.
//

import Foundation

// volgens: https://cocoacasts.com/what-is-a-singleton-and-how-to create-one-in-swift

class AirportFactory {
    
    var airports: [Airport] = []
    
    private static var sharedAirportFactory: AirportFactory = {
        let factory = AirportFactory()
        return factory;
    }()
    
    class func getInstance() -> AirportFactory {
        return sharedAirportFactory
    }
    
    var db : OpaquePointer? = nil
    
    //
    init() {
        
        //
        let bundlePathUrl = Bundle.main.url(forResource: "airports", withExtension: "sqlite")
        let docPathUrl = getDocumentsDirectory().appendingPathComponent("airports.sqlite")
        
        // Copy db file als deze niet bestaat
        if !FileManager.default.fileExists(atPath: docPathUrl.path) {
            try! FileManager.default.copyItem(at: bundlePathUrl!, to: docPathUrl)
        }
        
        // Open vanaf de document directory de db
        if sqlite3_open(docPathUrl.path, &db) != SQLITE_OK {
            print("Error opening database!!")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0];
    }
    
    // Get all airports from db
    func getAllAirports(force: Bool) -> [Airport] {
        
        if( !force ) {
            return self.airports
        } else {
        
            let query = "SELECT * FROM airports"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error query: \(errmsg)")
            }
            
            
            // Construct airports
            self.airports.removeAll();
            while sqlite3_step(statement) == SQLITE_ROW {
                let icao = String(cString: sqlite3_column_text(statement, 0));
                let name = String(cString: sqlite3_column_text(statement, 1));
                let longitude = sqlite3_column_double(statement, 2)
                let latitude = sqlite3_column_double(statement, 3)
                let elevation = sqlite3_column_double(statement, 4)
                let iso_country = String(cString: sqlite3_column_text(statement, 5))
                let muncipality = String(cString: sqlite3_column_text(statement, 6))
                
                self.airports.append(Airport(icao: icao, name: name, longitude: longitude, latitude: latitude,  elevation : elevation, iso_country : iso_country, muncipality : muncipality));
            }
            
            return self.airports;
        }
    }
    

}

