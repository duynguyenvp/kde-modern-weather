.pragma library

function iconName(wmoCode, isDay) {
    if (wmoCode === undefined || wmoCode === null || isNaN(wmoCode)) {
        return "not-available";
    }
    var day = (isDay === undefined || isDay === null) ? true : Boolean(isDay);
    var code = parseInt(wmoCode, 10);

    switch (code) {
    case 0:
        return day ? "clear-day" : "clear-night";
    case 1:
        return day ? "partly-cloudy-day" : "partly-cloudy-night";
    case 2:
        return day ? "overcast-day" : "overcast-night";
    case 3:
        return "overcast";
    case 45:
        return day ? "fog-day" : "fog-night";
    case 48:
        return "fog";
    case 51:
    case 53:
        return day ? "partly-cloudy-day-drizzle" : "partly-cloudy-night-drizzle";
    case 55:
        return "overcast-drizzle";
    case 56:
    case 57:
        return day ? "partly-cloudy-day-sleet" : "partly-cloudy-night-sleet";
    case 61:
    case 63:
        return day ? "partly-cloudy-day-rain" : "partly-cloudy-night-rain";
    case 65:
        return "overcast-rain";
    case 66:
    case 67:
        return "overcast-sleet";
    case 71:
    case 73:
        return day ? "partly-cloudy-day-snow" : "partly-cloudy-night-snow";
    case 75:
        return "extreme-snow";
    case 77:
        return "snowflake";
    case 80:
    case 81:
        return day ? "partly-cloudy-day-rain" : "partly-cloudy-night-rain";
    case 82:
        return "extreme-rain";
    case 85:
        return day ? "partly-cloudy-day-snow" : "partly-cloudy-night-snow";
    case 86:
        return "overcast-snow";
    case 95:
        return day ? "thunderstorms-day" : "thunderstorms-night";
    case 96:
        return day ? "thunderstorms-day-rain" : "thunderstorms-night-rain";
    case 99:
        return "thunderstorms-extreme-rain";
    default:
        return "not-available";
    }
}

function iconUrl(wmoCode, isDay) {
    return Qt.resolvedUrl("../icons/meteocons/" + iconName(wmoCode, isDay) + ".svg");
}

function metricIconUrl(name) {
    return Qt.resolvedUrl("../icons/meteocons/" + name + ".svg");
}

function accentGradient(wmoCode, isDay) {
    var day = (isDay === undefined || isDay === null) ? true : Boolean(isDay);
    var code = parseInt(wmoCode, 10);

    if (!day) {
        if (code >= 95) return ["#1b1f3b", "#3a2d5c"];
        if (code >= 51) return ["#182848", "#2c3e50"];
        return ["#0f172a", "#1e3a5f"];
    }

    if (code === 0 || code === 1) return ["#2563eb", "#38bdf8"];
    if (code === 2 || code === 3) return ["#475569", "#64748b"];
    if (code === 45 || code === 48) return ["#64748b", "#94a3b8"];
    if (code >= 95) return ["#312e81", "#4c1d95"];
    if ((code >= 71 && code <= 77) || code === 85 || code === 86) return ["#3b82f6", "#93c5fd"];
    if (code >= 51) return ["#1d4ed8", "#475569"];
    return ["#2563eb", "#38bdf8"];
}
