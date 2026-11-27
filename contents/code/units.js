.pragma library

function convertTemp(celsius, unit) {
    if (celsius === undefined || celsius === null || isNaN(celsius)) {
        return null;
    }
    if (unit === "fahrenheit") {
        return (celsius * 9.0 / 5.0) + 32.0;
    }
    return celsius;
}

function formatTemp(celsius, unit, includeUnitSymbol) {
    var val = convertTemp(celsius, unit);
    if (val === null) {
        return "--";
    }
    var rounded = Math.round(val);
    if (includeUnitSymbol === false) {
        return rounded + "°";
    }
    return rounded + (unit === "fahrenheit" ? "°F" : "°C");
}

function formatWind(kmh, unit) {
    if (kmh === undefined || kmh === null || isNaN(kmh)) {
        return "--";
    }
    switch (unit) {
    case "ms":
        return (kmh / 3.6).toFixed(1) + " m/s";
    case "mph":
        return (kmh * 0.621371).toFixed(1) + " mph";
    case "kn":
        return (kmh * 0.539957).toFixed(1) + " kn";
    case "kmh":
    default:
        return Math.round(kmh) + " km/h";
    }
}

function formatPressure(hpa, unit) {
    if (hpa === undefined || hpa === null || isNaN(hpa)) {
        return "--";
    }
    switch (unit) {
    case "inhg":
        return (hpa * 0.02953).toFixed(2) + " inHg";
    case "mmhg":
        return Math.round(hpa * 0.750062) + " mmHg";
    case "hpa":
    default:
        return Math.round(hpa) + " hPa";
    }
}

function formatPrecipitation(mm, unit) {
    if (mm === undefined || mm === null || isNaN(mm)) {
        return "--";
    }
    if (unit === "inch") {
        return (mm / 25.4).toFixed(2) + " in";
    }
    return mm.toFixed(1) + " mm";
}

function formatVisibility(meters, tempUnit, windUnit) {
    if (meters === undefined || meters === null || isNaN(meters)) {
        return "--";
    }
    if (windUnit === "mph" || tempUnit === "fahrenheit") {
        return (meters / 1609.344).toFixed(1) + " mi";
    }
    if (meters >= 1000) {
        return (meters / 1000.0).toFixed(1) + " km";
    }
    return Math.round(meters) + " m";
}

function is12Hour(timeFormat) {
    if (timeFormat === "12h") return true;
    if (timeFormat === "24h") return false;
    try {
        var fmt = Qt.locale().timeFormat(Locale.ShortFormat) || "";
        return fmt.toLowerCase().indexOf("a") !== -1 || fmt.indexOf("h") !== -1;
    } catch (e) {
        return false;
    }
}

function formatIsoTime(isoStr, timeFormat) {
    if (!isoStr || isoStr.indexOf("T") === -1) {
        return "--";
    }
    var timePart = isoStr.split("T")[1];
    var hm = timePart.split(":");
    if (hm.length < 2) {
        return timePart;
    }
    var h = parseInt(hm[0], 10);
    var m = parseInt(hm[1], 10);
    return formatHM(h, m, timeFormat);
}

function formatDateClock(dateObj, timeFormat) {
    if (!dateObj) return "--";
    return formatHM(dateObj.getHours(), dateObj.getMinutes(), timeFormat);
}

function formatHM(h, m, timeFormat) {
    var mm = (m < 10 ? "0" : "") + m;
    if (is12Hour(timeFormat)) {
        var suffix = h >= 12 ? "PM" : "AM";
        var h12 = h % 12;
        if (h12 === 0) h12 = 12;
        return h12 + ":" + mm + " " + suffix;
    }
    var hh = (h < 10 ? "0" : "") + h;
    return hh + ":" + mm;
}
