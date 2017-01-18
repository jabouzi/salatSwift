//
//  main.swift
//  SalatSwiftObjectiveC
//
//  Created by dev on 1/18/17.
//  Copyright © 2017 Skander Jabouzi. All rights reserved.
//

import Foundation

var salatTimes : NSMutableArray = [];
let date = Date();
let calendar = Calendar.current;

let year: Int = calendar.component(.year, from: date);
let month: Int = calendar.component(.month, from: date);
let day: Int = calendar.component(.day, from: date);

let calcMethod:Int = 2;
let asrMethod:Int = 0;
let highLatitude:Int = 0;
let latitude: Double = 45.5454;
let longitude: Double = -73.6391;
let timezone: Double = -4;

var salat = Salat();
salat.setCalcMethod(Int32(calcMethod));
salat.setAsrMethod(Int32(asrMethod));
salat.setDhuhrMinutes(0);
salat.setHighLatsMethod(Int32(highLatitude));

salatTimes = salat.getDatePrayerTimes(Int32(year), Int32(month), Int32(day), latitude, longitude, timezone);
print(salatTimes);

