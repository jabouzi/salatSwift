//
//  main.swift
//  SalatSwift
//
//  Created by dev on 10/28/16.
//  Copyright © 2016 dev. All rights reserved.
//

import Foundation

var salat = Salat();

let date = Date();
let calendar = Calendar.current;

let year: Int = calendar.component(.year, from: date);
let month:Int = calendar.component(.month, from: date);
let day:Int = calendar.component(.day, from: date);

let calcMethod:Int = 2;
let asrMethod:Int = 0;
let highLatitude:Int = 0;
let latitude: Double = 45.5454;
let longitude: Double = -73.6391;
let timezone: Double = -4;

salat.setCalcMethod(methodID: calcMethod);
salat.setAsrMethod(methodID: asrMethod);
salat.setDhuhrMinutes(minutes: 0);
salat.setHighLatsMethod(methodID: highLatitude);

salat.getDatePrayerTimes(year: year, month: month, day: day, latitude: latitude, longitude: longitude, timeZone: timezone);

print(salat.prayerTimes);
