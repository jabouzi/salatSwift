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
    
    
    var lat: Double;        // latitude
    var lng: Double;        // longitude
    var timezone: Double;   // time-zone
    var JDate: Double;      // Julian date
    
    
    //------------------- Calc Method Parameters --------------------
    
    
    /*  methodParams[methodNum] = new Array(fa, ms, mv, is, iv);
     
     fa : fajr angle
     ms : maghrib selector (0 = angle; 1 = minutes after sunset)
     mv : maghrib parameter value (in angle or minutes)
     is : isha selector (0 = angle; 1 = minutes after maghrib)
     iv : isha parameter value (in angle or minutes)
     */
    var methodParams: [[Double]] = []
    var prayerTimes = [Double]()
    
    init() {
        
        methodParams[0][0] = 16.0;
        methodParams[0][1] = 0.0;
        methodParams[0][2] = 4.0;
        methodParams[0][3] = 0.0;
        methodParams[0][4] = 14.0;
        
        methodParams[1][0] = 18.0;
        methodParams[1][1] = 1.0;
        methodParams[1][2] = 0.0;
        methodParams[1][3] = 0.0;
        methodParams[1][4] = 18.0;
        
        methodParams[2][0] = 15.0;
        methodParams[2][1] = 1.0;
        methodParams[2][2] = 0.0;
        methodParams[2][3] = 0.0;
        methodParams[2][4] = 15.0;
        
        methodParams[3][0] = 18.0;
        methodParams[3][1] = 1.0;
        methodParams[3][2] = 0.0;
        methodParams[3][3] = 0.0;
        methodParams[3][4] = 17.0;
        
        methodParams[4][0] = 19.0;
        methodParams[4][1] = 1.0;
        methodParams[4][2] = 0.0;
        methodParams[4][3] = 1.0;
        methodParams[4][4] = 90.0;
        
        methodParams[5][0] = 19.5;
        methodParams[5][1] = 1.0;
        methodParams[5][2] = 0.0;
        methodParams[5][3] = 0.0;
        methodParams[5][4] = 17.5;
        
        methodParams[6][0] = 18.0;
        methodParams[6][1] = 1.0;
        methodParams[6][2] = 0.0;
        methodParams[6][3] = 0.0;
        methodParams[6][4] = 17.0;
        
        methodParams[7][0] = 17.7;
        methodParams[7][1] = 0.0;
        methodParams[7][2] = 4.5;
        methodParams[7][3] = 0.0;
        methodParams[7][4] = 15.0;
        

    }
    
    func getDatePrayerTimes(year: Int, month: Int, day: Int , latitude: Double , longitude: Double , timeZone: Double) -> [String]
    {
        var prayerTimes: [String]
        var lat = latitude;
        var lng = longitude;
        var timezone = timeZone;
        //timeZone = effectiveTimeZone(year, month, day, timeZone);
        var JDate = julianDate(year, month, day)- longitude/ (15*24);
        computeDayTimes();
        
        return prayerTimes;
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
    func setMaghribMinutes(minutes: Int)
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
    }
    
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
            time = fixhour(time + 0.5 / 60);  // add 0.5 minutes to round
            var hours: Double = floor(time);
            var minutes: Double = floor((time - hours) * 60);
            return twoDigitsFormat(hours)+":"+twoDigitsFormat(minutes);
        }
    }
    
    // convert float hours to 12h format
    func floatToTime12( time: inout Double) -> String
    {
        if (time.isNaN) {
            return InvalidTime;
        }
        else {
            time = fixhour(time+0.5/60);  // add 0.5 minutes to round
            var hours: Int = Int(time)
            var minutes: Int = ((Int(time)-hours)*60);
            var suffix: String = hours >= 12 ? " pm" : " am";
            hours = (hours + 12 - 1) % 12 + 1;
            return _2String(hours)+":"+twoDigitsFormat(minutes)+suffix;
        }
    }
    
    
    //---------------------- Calculation Functions -----------------------
    
    // References:
    // http://www.ummah.net/astronomy/saltime
    // http://aa.usno.navy.mil/faq/docs/SunApprox.html
    
    
    // compute declination angle of sun and equation of time
    func sunPosition(jd: Double, flag: Int) -> Double
    {
        var D: Double = jd - 2451545.0;
        var g: Double = fixangle(357.529 + 0.98560028*D);
        var q: Double = fixangle(280.459 + 0.98564736*D);
        var L: Double = fixangle(q + 1.915*dsin(g)+0.020*dsin(2*g));
        //double R = 1.00014 - 0.01671* dcos(g) - 0.00014* dcos(2*g);
        var e: Double = 23.439 - 0.00000036*D;
        var d: Double = darcsin(dsin(e)*dsin(L));
        var RA: Double = darctan2(dcos(e)*dsin(L), dcos(L))/15;
        RA = fixhour(RA);
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
        var T: Double = equationOfTime(jd: JDate + t);
        var Z: Double = fixhour(12 - T);
        return Z;
    }
    
    // compute time for a given angle G
    func computeTime(G: Double, t: Double)
    {
        var D: Double = sunDeclination(jd: JDate + t);
        var Z: Double = computeMidDay(t: t);
        var V: Double = 1.0/15.0* darccos((-dsin(G)-dsin(D)*dsin(lat))/dcos(D)*dcos(lat)));
        return Z + (G > 90.0 ? -V : V);
    }
    
    // compute the time of Asr
    double func computeAsr(int step, double t)  // Shafii: step=1, Hanafi: step=2
    {
    double D = sunDeclination(JDate+ t);
    double G = -darccot(step+ dtan(abs(lat-D)));
    return computeTime(G, t);
    }
    
    
    //---------------------- Compute Prayer Times -----------------------
    
    
    // compute prayer times at given julian date
    void func computeTimes()
    {
    dayPortion();
    double Fajr    = computeTime(180.0 - methodParams[calcMethod][0], times[0]);
    double Sunrise = computeTime(180.0 - 0.833, times[1]);
    double Dhuhr   = computeMidDay(times[2]);
    double Asr     = computeAsr(1.0 + asrJuristic, times[3]);
    double Sunset  = computeTime(0.833, times[4]);;
    double Maghrib = computeTime(methodParams[calcMethod][2], times[5]);
    double Isha    = computeTime(methodParams[calcMethod][4], times[6]);
    times[0] = Fajr;
    times[1] = Sunrise;
    times[2] = Dhuhr;
    times[3] = Asr;
    times[4] = Sunset;
    times[5] = Maghrib;
    times[6] = Isha;
    }
    
    
    // compute prayer times at given julian date
    void func computeDayTimes()
    {
    times[0] = 5.0;
    times[1] = 6.0;
    times[2] = 12.0;
    times[3] = 13.0;
    times[4] = 18.0;
    times[5] = 18.0;
    times[6] = 18.0; //default times
    
    for (int i=1; i<=numIterations; i++)
    computeTimes();
    adjustTimes();
    adjustTimesFormat();
    }
    
    
    // adjust times in a prayer time array
    void func adjustTimes()
    {
    for (int i=0; i<7; i++)
    times[i] += timezone - lng/15.0;
    times[2] += dhuhrMinutes/ 60.0; //Dhuhr
    if (methodParams[calcMethod][1] == 1) // Maghrib
    times[5] = times[4]+ methodParams[calcMethod][2]/ 60.0;
    if (methodParams[calcMethod][3] == 1) // Isha
    times[6] = times[5]+ methodParams[calcMethod][4]/ 60.0;
    
    if (adjustHighLats != None)
    adjustHighLatTimes();
    }
    
    
    // convert times array to given time format
    void func adjustTimesFormat()
    {
    for (int i=0; i<7; i++)
    if (timeFormat == Time12)
    prayerTimes[i] = floatToTime12(times[i]);
    /*else if (timeFormat == Time12NS)
     timesF[i] = floatToTime12(times[i], true);*/
    else
    prayerTimes[i] = floatToTime24(times[i]);
    }
    
    
    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    void func adjustHighLatTimes()
    {
    double nightTime = timeDiff(times[4], times[1]); // sunset to sunrise
    
    // Adjust Fajr
    double FajrDiff = nightPortion(methodParams[calcMethod][0])* nightTime;
    if (isNaN(times[0]) || timeDiff(times[0], times[1]) > FajrDiff)
    times[0] = times[1]- FajrDiff;
    
    // Adjust Isha
    double IshaAngle = (methodParams[calcMethod][3] == 0) ? methodParams[calcMethod][4] : 18;
    double IshaDiff = nightPortion(IshaAngle)* nightTime;
    if (isNaN(times[6]) || timeDiff(times[4], times[6]) > IshaDiff)
    times[6] = times[4]+ IshaDiff;
    
    // Adjust Maghrib
    double MaghribAngle = (methodParams[calcMethod][1] == 0) ? methodParams[calcMethod][2] : 4;
    double MaghribDiff = nightPortion(MaghribAngle)* nightTime;
    if (isNaN(times[5]) || timeDiff(times[4], times[5]) > MaghribDiff)
    times[5] = times[4]+ MaghribDiff;
    }
    
    
    // the night portion used for adjusting times in higher latitudes
    double func nightPortion(double angle)
    {
    double result = 0.0;
    if (adjustHighLats == AngleBased)
    result = 1.0/60.0* angle;
    if (adjustHighLats == MidNight)
    result = 1.0/2.0;
    if (adjustHighLats == OneSeventh)
    result = 1.0/7.0;
    return result;
    }
    
    
    // convert hours to day portions
    void func dayPortion()
    {
    for (int i=0; i<7; i++)
    times[i] /= 24;
    //return times;
    }
    
    
    
    //---------------------- Misc Functions -----------------------
    
    
    // compute the difference between two times
    double func timeDiff(double time1, double time2)
    {
    return fixhour(time2- time1);
    }
    
    
    // add a leading 0 if necessary
    string func twoDigitsFormat(int num)
    {
    return (num <10) ? '0'+ _2String(num) : _2String(num);
    }
    
    bool func isNaN(double var)
    {
    return (isnan(var) != 0);
    }
    
    
    //---------------------- Julian Date Functions -----------------------
    
    
    // calculate julian date from a calendar date
    double func julianDate(int year, int month, int day)
    {
    if (month <= 2)
    {
    year -= 1;
    month += 12;
    }
    double A = floor(year/ 100.0);
    double B = 2.0 - A+ floor(A/ 4.0);
    
    double JD = floor(365.25* (year+ 4716))+ floor(30.6001* (month+ 1))+ day+ B- 1524.5;
    return JD;
    }
    
    //---------------------- Time-Zone Functions -----------------------
    
    
    // compute local time-zone for a specific date
    /*void func getTimeZone(date)
     {
     double localDate = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
     double GMTstring = localDate.toGMTstring();
     double GMTDate = new Date(GMTstring.substring(0, GMTstring.lastIndexOf(' ')- 1));
     double hoursDiff = (localDate- GMTDate) / (1000* 60* 60);
     return hoursDiff;
     }*/
    
    
    // compute base time-zone of the system
    /*void func getBaseTimeZone()
     {
     return getTimeZone(new Date(2000, 0, 15))
     }*/
    
    
    // detect daylight saving in a given date
    /*void func detectDaylightSaving(date)
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
    double func dsin(double d)
    {
    return sin(dtr(d));
    }
    
    // degree cos
    double func dcos(double d)
    {
    return cos(dtr(d));
    }
    
    // degree tan
    double func dtan(double d)
    {
    return tan(dtr(d));
    }
    
    // degree arcsin
    double func darcsin(double x)
    {
    return rtd(asin(x));
    }
    
    // degree arccos
    double func darccos(double x)
    {
    return rtd(acos(x));
    }
    
    // degree arctan
    double func darctan(double x)
    {
    return rtd(atan(x));
    }
    
    // degree arctan2
    double func darctan2(double y, double x)
    {
    return rtd(atan2(y, x));
    }
    
    // degree arccot
    double func darccot(double x)
    {
    return rtd(atan(1/x));
    }
    
    // degree to radian
    double func dtr(double d)
    {
    return (d * PI) / 180.0;
    }
    
    // radian to degree
    double func rtd(double r)
    {
    return (r * 180.0) / PI;
    }
    
    // range reduce angle in degrees.
    double func fixangle(double a)
    {
    a = a - 360.0 * (floor(a / 360.0));
    a = a < 0 ? a + 360.0 : a;
    return a;
    }
    
    // range reduce hours to 0..23
    double func fixhour(double a)
    {
    a = a - 24.0 * (floor(a / 24.0));
    a = a < 0 ? a + 24.0 : a;
    return a;
    }
    
    string func _2String(double number)
    {
    std::ostringstream ostr;
    ostr << number;
    return ostr.str();
    }
    
    string func _2String(int number)
    {
    std::ostringstream ostr;
    ostr << number;
    return ostr.str();
    }
    
    void func debug(string* array)
    {
    int numElements = sizeof(array)/sizeof(array[0]);
    for (int i = 0; i < numElements; i++) 
    cout << array[i];
    }
    void func debug(int* array)
    {
    int numElements = sizeof(array)/sizeof(array[0]);
    for (int i = 0; i < numElements; i++) 
    cout << array[i];
    }
}
