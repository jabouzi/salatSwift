//
//  Salat.swift
//  SalatSwift
//
//  Created by dev on 10/28/16.
//  Copyright © 2016 dev. All rights reserved.
//

import Foundation

class Salat {
    
    let PI: Double = 4.0*atan(1.0);
    // Calculation Methods
    let Jafari     = 0;    // Ithna Ashari
    let Karachi    = 1;    // University of Islamic Sciences, Karachi
    let ISNA       = 2;    // Islamic Society of North America (ISNA)
    let MWL        = 3;    // Muslim World League (MWL)
    let Makkah     = 4;    // Umm al-Qura, Makkah
    let Egypt      = 5;    // Egyptian General Authority of Survey
    let Tehran     = 6;    // Institute of Geophysics, University of Tehran
    let Custom     = 7;    // Custom Setting
    
    // Juristic Methods
    let Shafii     = 0;    // Shafii (standard)
    let Hanafi     = 1;    // Hanafi
    
    // Adjusting Methods for Higher Latitudes
    let None       = 0;    // No adjustment
    let MidNight   = 1;    // middle of night
    let OneSeventh = 2;    // 1/7th of night
    let AngleBased = 3;    // angle/60th of night
    
    
    // Time Formats
    let Time24     = 0;    // 24-hour format
    let Time12     = 1;    // 12-hour format
    let Time12NS   = 2;    // 12-hour format with no suffix
    let Float      = 3;    // floating point number
    
    // Time Names
    //timeNames = {'Fajr','Sunrise','Dhuhr','Asr','Sunset','Maghrib','Isha'};
    
    let InvalidTime = "-----";     // The string used for invalid times
    
    
    //---------------------- Global Variables --------------------
    
    
    var calcMethod   = 0;        // caculation method
    var asrJuristic  = 0.0;        // Juristic method for Asr
    var dhuhrMinutes = 0.0;        // minutes after mid-day for Dhuhr
    var adjustHighLats = 0;    // adjusting method for higher latitudes
    
    var timeFormat   = 0;        // time format
    
    
    //--------------------- Technical Settings --------------------
    
    
    var numIterations = 1;        // number of iterations needed to compute times
    
    
    var lat: Double = 0.0;        // latitude
    var lng: Double = 0.0;        // longitude
    var timezone: Double = 0.0;   // time-zone
    var JDate: Double = 0.0;      // Julian date
    
    
    //------------------- Calc Method Parameters --------------------
    
    
    /*  methodParams[methodNum] = new Array(fa, ms, mv, is, iv);
     
     fa : fajr angle
     ms : maghrib selector (0 = angle; 1 = minutes after sunset)
     mv : maghrib parameter value (in angle or minutes)
     is : isha selector (0 = angle; 1 = minutes after maghrib)
     iv : isha parameter value (in angle or minutes)
     */
    var methodParams: [[Double]] =
        [
            [
                16.0,
                0.0,
                4.0,
                0.0,
                14.0
            ],
            [
                18.0,
                1.0,
                0.0,
                0.0,
                18.0
            ],
            [
                15.0,
                1.0,
                0.0,
                0.0,
                15.0
            ],
            [
                18.0,
                1.0,
                0.0,
                0.0,
                17.0
            ],
            [
                19.0,
                1.0,
                0.0,
                1.0,
                90.0
            ],
            [
                19.5,
                1.0,
                0.0,
                0.0,
                17.5
            ],
            [
                18.0,
                1.0,
                0.0,
                0.0,
                17.0
            ],
            [
                17.7,
                0.0,
                4.5,
                0.0,
                15.0
            ]
    ]
    //var prayerTimes = [Double]()
    
    var times: [Double] = [0,0,0,0,0,0,0];
    var prayerTimes: [String] = ["","","","","","",""];
    
    init() {
        

    }
    
    func getDatePrayerTimes(year: Int, month: Int, day: Int , latitude: Double , longitude: Double , timeZone: Double)
    {
        lat = latitude;
        lng = longitude;
        timezone = timeZone;
        //timeZone = effectiveTimeZone(year, month, day, timeZone);
        JDate = julianDate(year: year, month: month, day: day) - longitude / (15 * 24);

        computeDayTimes();
        
        //return prayerTimes;
    }
    
    // set the calculation method
    func setCalcMethod(methodID: Int)
    {
        calcMethod = methodID;
    }
    
    // set the juristic method for Asr
    func setAsrMethod(methodID: Int)
    {
        if (methodID < 0 || methodID > 1) {
            return;
        }
        asrJuristic = Double(methodID);
    }
    
    // set the minutes after mid-day for calculating Dhuhr
    func setDhuhrMinutes(minutes: Int)
    {
        dhuhrMinutes = Double(minutes);
    }
    
    // set the minutes after Sunset for calculating Maghrib
    /*func setMaghribMinutes(minutes: Int)
    {
        var customParams: [Int]
        customParams.insert(1, at: 1)
        customParams.insert(minutes, at: 2)
        //= [nil, 1, minutes, nil, nil];
    }
    
    // set the minutes after Maghrib for calculating Isha
    func setIshaMinutes(minutes: Int)
    {
        var customParams: [Int]
        customParams.insert(1, at: 1)
        customParams.insert(minutes, at: 2)
    }*/
    
    // set adjusting method for higher latitudes
    func setHighLatsMethod(methodID: Int)
    {
        adjustHighLats = methodID;
    }
    
    // set the time format
    func setTimeFormat(timeFormat: Int)
    {
        self.timeFormat = timeFormat;
    }
    
    // convert float hours to 24h format
    func floatToTime24( time: inout Double) -> String
    {
        if (time.isNaN) {
            return InvalidTime;
        }
        else {
            var temp: Double = time + 0.5 / 60;
            time = fixhour(_hour: temp);  // add 0.5 minutes to round
            let hours: Double = floor(time);
            let minutes: Double = floor((time - hours) * 60);
            return twoDigitsFormat(num: Int(hours))+":"+twoDigitsFormat(num: Int(minutes));
        }
    }
    
    // convert float hours to 12h format
    func floatToTime12(time: inout Double) -> String
    {
        if (time.isNaN) {
            return InvalidTime;
        }
        else {
            var temp: Double = (time + 0.5) / 60;
            time = fixhour(_hour: temp);  // add 0.5 minutes to round
            var hours: Int = Int(time)
            let minutes: Int = ((Int(time)-hours)*60);
            let suffix: String = hours >= 12 ? " pm" : " am";
            hours = (hours + 12 - 1) % 12 + 1;
            return "\(hours)" + twoDigitsFormat(num: minutes) + suffix;
        }
    }
    
    
    //---------------------- Calculation Functions -----------------------
    
    // References:
    // http://www.ummah.net/astronomy/saltime
    // http://aa.usno.navy.mil/faq/docs/SunApprox.html
    
    
    // compute declination angle of sun and equation of time
    func sunPosition(jd: Double, flag: Int) -> Double
    {
        var temp: Double = 0;
        var D: Double = jd - 2451545.0;
        temp = 357.529 + 0.98560028 * D;
        var g: Double = fixangle(a: &temp);
        temp = 280.459 + 0.98564736 * D;
        var q: Double = fixangle(a: &temp);
        temp = q + 1.915*dsin(d: g)+0.020*dsin(d: 2*g);
        var L: Double = fixangle(a: &temp);
        //double R = 1.00014 - 0.01671* dcos(g) - 0.00014* dcos(2*g);
        var e: Double = 23.439 - 0.00000036*D;
        var d: Double = darcsin(x: dsin(d: e)*dsin(d: L));
        var RA: Double = darctan2(y: dcos(d: e)*dsin(d: L), x: dcos(d: L))/15;
        RA = fixhour(_hour: RA);
        var EqT: Double = q/15 - RA;
        //double * result = new double[2];
        if (flag == 0) {
            return d;
        }
        return EqT;
    }
    
    // compute equation of time
    func equationOfTime(jd: Double) -> Double
    {
        return sunPosition(jd: jd, flag: 1);
    }
    
    // compute declination angle of sun
    func sunDeclination(jd: Double) -> Double
    {
        return sunPosition(jd: jd, flag: 0);
    }
    
    // compute mid-day (Dhuhr, Zawal) time
    func computeMidDay(t: Double) -> Double
    {
        var T: Double = equationOfTime(jd: (JDate + t));
        var temp = 12 - T;
        var Z: Double = fixhour(_hour: temp);
        return Z;
    }
    
    // compute time for a given angle G
    func computeTime(G: Double, t: Double) -> Double
    {
        var D: Double = sunDeclination(jd: (JDate + t));
        var Z: Double = computeMidDay(t: t);
        var V: Double = 1.0/15.0*darccos(x: (-dsin(d: G)-dsin(d: D)*dsin(d: lat))/dcos(d: D)*dcos(d: lat));
        return Z + (G > 90.0 ? -V : V);
    }
    
    // compute the time of Asr
    func computeAsr(step: Int, t: Double) -> Double // Shafii: step=1, Hanafi: step=2
    {
        var D: Double = sunDeclination(jd: (JDate+t));
        var G: Double = -darccot(x: Double(step) + dtan(d: abs(lat-D)));
        return computeTime(G: G, t: t);
    }
    
    
    //---------------------- Compute Prayer Times -----------------------
    
    
    // compute prayer times at given julian date
    func computeTimes()
    {
        dayPortion();
        let Fajr: Double     = computeTime(G: 180.0 - methodParams[calcMethod][0], t: times[0]);
        let Sunrise: Double  = computeTime(G: 180.0 - 0.833, t: times[1]);
        let Dhuhr: Double    = computeMidDay(t: times[2]);
        let Asr: Double      = computeAsr(step: Int(1.0 + asrJuristic), t: times[3]);
        let Sunset: Double   = computeTime(G: 0.833, t: times[4]);
        let Maghrib: Double  = computeTime(G: methodParams[calcMethod][2], t: times[5]);
        let Isha: Double     = computeTime(G: methodParams[calcMethod][4], t: times[6]);
        times[0] = Fajr;
        times[1] = Sunrise;
        times[2] = Dhuhr;
        times[3] = Asr;
        times[4] = Sunset;
        times[5] = Maghrib;
        times[6] = Isha;
    }
    
    
    // compute prayer times at given julian date
    func computeDayTimes()
    {
        times[0] = 5.0;
        times[1] = 6.0;
        times[2] = 12.0;
        times[3] = 13.0;
        times[4] = 18.0;
        times[5] = 18.0;
        times[6] = 18.0; //default times
    
        for i in 1...numIterations
        {
            computeTimes();
        }
        
        adjustTimes();
        adjustTimesFormat();
    }
    
    // adjust times in a prayer time array
    func adjustTimes()
    {
        for i in 0 ..< 7
        {
            times[i] += timezone - lng/15.0;
        }
        times[2] += dhuhrMinutes / 60.0; //Dhuhr
        
        if (methodParams[calcMethod][1] == 1) { // Maghrib
            times[5] = times[4] + methodParams[calcMethod][2] / 60.0;
        }
        
        if (methodParams[calcMethod][3] == 1) { // Isha
            times[6] = times[5] + methodParams[calcMethod][4] / 60.0;
        }
        
        if (adjustHighLats != None) {
            adjustHighLatTimes();
        }
    }
    
    
    // convert times array to given time format
    func adjustTimesFormat()
    {
        var temp: Double = 0.0;
        for i in 0 ..< 7 {
            temp = times[i];
            if (timeFormat == Time12) {
                prayerTimes[i] = floatToTime12(time: &temp);
            }
            else {
                prayerTimes[i] = floatToTime24(time: &temp);
            }
        }
    }
    
    
    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    func adjustHighLatTimes()
    {
        var nightTime: Double = timeDiff(time1: times[4], time2: times[1]); // sunset to sunrise
    
        // Adjust Fajr
        var FajrDiff: Double = nightPortion(angle: methodParams[calcMethod][0]) * nightTime;
        if (times[0].isNaN || timeDiff(time1: times[0], time2: times[1]) > FajrDiff) {
            times[0] = times[1] - FajrDiff;
        }
    
        // Adjust Isha
        var IshaAngle: Double = (methodParams[calcMethod][3] == 0) ? methodParams[calcMethod][4] : 18;
        var IshaDiff: Double = nightPortion(angle: IshaAngle) * nightTime;
        if (times[6].isNaN || timeDiff(time1: times[4], time2: times[6]) > IshaDiff) {
            times[6] = times[4] + IshaDiff;
        }
    
        // Adjust Maghrib
        var MaghribAngle: Double = (methodParams[calcMethod][1] == 0) ? methodParams[calcMethod][2] : 4;
        var MaghribDiff: Double = nightPortion(angle: MaghribAngle) * nightTime;
        if (times[5].isNaN || timeDiff(time1: times[4], time2: times[5]) > MaghribDiff) {
            times[5] = times[4] + MaghribDiff;
        }
    }
    
    
    // the night portion used for adjusting times in higher latitudes
    func nightPortion(angle: Double) -> Double
    {
        var result: Double = 0.0;
        if (adjustHighLats == AngleBased) {
            result = 1.0/60.0 * angle;
        }
        
        if (adjustHighLats == MidNight) {
            result = 1.0/2.0;
        }
        
        if (adjustHighLats == OneSeventh) {
            result = 1.0/7.0;
        }
        
        return result;
    }
    
    
    // convert hours to day portions
    func dayPortion()
    {
        for i in 0 ..< 7 {
            times[i] /= 24;
        }
        
        //return times;
    }
    
    
    
    //---------------------- Misc Functions -----------------------
    
    
    // compute the difference between two times
    func timeDiff(time1: Double, time2: Double) -> Double
    {
        var temp = time2 - time1;
        return fixhour(_hour: temp);
    }
    
    
    // add a leading 0 if necessary
    func twoDigitsFormat(num: Int) -> String
    {
        return (num < 10) ? "0" + "\(num)" : "\(num)";
    }
    
    /*func isNaN(_var: Double) -> Bool
    {
        return (isnan(_var) != 0);
    }*/
    
    
    //---------------------- Julian Date Functions -----------------------
    
    
    // calculate julian date from a calendar date
    func julianDate(year: Int, month: Int, day: Int) -> Double
    {
        var _month = month;
        var _year = year;
        if (_month <= 2)
        {
            _year -= 1;
            _month += 12;
        }
        
        let A: Double = floor(Double(_year / 100));
        let B: Double = 2.0 - A + floor(A / 4.0);
    
        var JD: Double = floor(365.25 * Double(_year + 4716)) + floor(30.6001 * Double(_month + 1));
        JD += Double(day) + B - 1524.5;

        return JD;
    }
    
    //---------------------- Time-Zone Functions -----------------------
    
    
    // compute local time-zone for a specific date
    /*func getTimeZone(date)
     {
     double localDate = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
     double GMTstring = localDate.toGMTstring();
     double GMTDate = new Date(GMTstring.substring(0, GMTstring.lastIndexOf(' ')- 1));
     double hoursDiff = (localDate- GMTDate) / (1000* 60* 60);
     return hoursDiff;
     }*/
    
    
    // compute base time-zone of the system
    /*func getBaseTimeZone()
     {
     return getTimeZone(new Date(2000, 0, 15))
     }*/
    
    
    // detect daylight saving in a given date
    /*func detectDaylightSaving(date)
     {
     return getTimeZone(date) != getBaseTimeZone();
     }*/
    
    
    // return effective timezone for a given date
    //double func effectiveTimeZone(int year, int month, int day, int timeZone)
    //{
    //    if (timeZone == NULL || typeof(timeZone) == 'undefined' || timeZone == 'auto')
    //        timeZone = getTimeZone(new Date(year, month- 1, day));
    //    return 1* timeZone;
    //}
    
    
    //---------------------- Trigonometric Functions -----------------------
    
    // degree sin
    func dsin(d: Double) -> Double
    {
        return sin(dtr(d: d));
    }
    
    // degree cos
    func dcos(d: Double) -> Double
    {
        return cos(dtr(d: d));
    }
    
    // degree tan
    func dtan(d: Double) -> Double
    {
        return tan(dtr(d: d));
    }
    
    // degree arcsin
    func darcsin(x: Double) -> Double
    {
        return rtd(r: asin(x));
    }
    
    // degree arccos
    func darccos(x: Double) -> Double
    {
        return rtd(r: acos(x));
    }
    
    // degree arctan
    func darctan(x: Double) -> Double
    {
        return rtd(r: atan(x));
    }
    
    // degree arctan2
    func darctan2(y: Double, x: Double) -> Double
    {
        return rtd(r: atan2(y, x));
    }
    
    // degree arccot
    func darccot(x: Double) -> Double
    {
        return rtd(r: atan(1/x));
    }
    
    // degree to radian
    func dtr(d: Double) -> Double
    {
        return (d * PI) / 180.0;
    }
    
    // radian to degree
    func rtd(r: Double) -> Double
    {
        return (r * 180.0) / PI;
    }
    
    // range reduce angle in degrees.
    func fixangle(a: inout Double) -> Double
    {
        a = a - 360.0 * (floor(a / 360.0));
        a = a < 0 ? a + 360.0 : a;
        return a;
    }
    
    // range reduce hours to 0..23
    func fixhour(_hour: Double) -> Double
    {
        var a = _hour;
        let f = 24.0 * (floor(a / 24.0));
        a = a - (24.0 * (floor(a / 24.0)));
        a = a < 0 ? a + 24.0 : a;
        
        return a;
    }
    
    /*func _2String(double number) -> String
    {
        std::ostringstream ostr;
        ostr << number;
        return ostr.str();
    }
    
    func _2String(int number) -> String
    {
    std::ostringstream ostr;
    ostr << number;
    return ostr.str();
    }**/
    
    /*func debug(string* array)
    {
    int numElements = sizeof(array)/sizeof(array[0]);
    for (int i = 0; i < numElements; i++) 
    cout << array[i];
    }
    func debug(int* array)
    {
    int numElements = sizeof(array)/sizeof(array[0]);
    for (int i = 0; i < numElements; i++) 
    cout << array[i];
    }*/
}
