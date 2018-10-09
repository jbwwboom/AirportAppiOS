//
//  Airport.swift
//  AirportApp
//
//  Created by Justin van den Boomen on 19/09/2018.
//  Copyright © 2018 Justin van den Boomen. All rights reserved.
//

import Foundation

class Airport{
    var icao : String?
    var name : String?
    var longitude : Double?
    var latitude : Double?
    var elevation : Double?
    var iso_country : String?
    var muncipality: String?
    
    required init(icao : String, name : String, longitude : Double, latitude : Double, elevation : Double, iso_country : String, muncipality : String){
        self.icao = icao
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.elevation = elevation
        self.iso_country = iso_country
        self.muncipality = muncipality
    }
}
