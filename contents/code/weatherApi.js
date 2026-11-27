.pragma library

function httpGetJson(url, timeoutMs, callback) {
    var xhr = new XMLHttpRequest();
    var finished = false;

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE && !finished) {
            finished = true;
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var json = JSON.parse(xhr.responseText);
                    callback(null, json);
                } catch (e) {
                    callback("Invalid JSON response", null);
                }
            } else {
                callback("HTTP " + xhr.status, null);
            }
        }
    };

    xhr.onerror = function() {
        if (!finished) {
            finished = true;
            callback("Network error", null);
        }
    };

    xhr.ontimeout = function() {
        if (!finished) {
            finished = true;
            callback("Request timeout", null);
        }
    };

    xhr.open("GET", url, true);
    xhr.timeout = timeoutMs || 12000;
    xhr.send();
}

function fetchWeather(lat, lon, callback) {
    var url = "https://api.open-meteo.com/v1/forecast"
        + "?latitude=" + encodeURIComponent(lat)
        + "&longitude=" + encodeURIComponent(lon)
        + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_direction_10m"
        + "&hourly=temperature_2m,precipitation_probability,weather_code,is_day,visibility,uv_index"
        + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max,precipitation_sum"
        + "&timezone=auto"
        + "&forecast_days=7";

    httpGetJson(url, 15000, function(err, data) {
        if (err || !data || !data.current) {
            callback(err || "No weather data", null);
            return;
        }

        // Find current hour index in hourly array to grab visibility, uv_index, and next 24h slice
        var currentIso = data.current.time || "";
        var currentHourPrefix = currentIso.length >= 13 ? currentIso.substring(0, 13) : "";
        var hourlyTimes = (data.hourly && data.hourly.time) ? data.hourly.time : [];
        var startIdx = 0;
        for (var i = 0; i < hourlyTimes.length; i++) {
            if (hourlyTimes[i].indexOf(currentHourPrefix) === 0) {
                startIdx = i;
                break;
            }
        }

        var hourlyList = [];
        var maxHourly = Math.min(hourlyTimes.length, startIdx + 24);
        for (var h = startIdx; h < maxHourly; h++) {
            hourlyList.push({
                time: hourlyTimes[h],
                temperature: data.hourly.temperature_2m[h],
                precipProb: data.hourly.precipitation_probability ? data.hourly.precipitation_probability[h] : 0,
                weatherCode: data.hourly.weather_code[h],
                isDay: data.hourly.is_day ? (data.hourly.is_day[h] === 1) : true
            });
        }

        var dailyList = [];
        var dailyTimes = (data.daily && data.daily.time) ? data.daily.time : [];
        for (var d = 0; d < dailyTimes.length; d++) {
            dailyList.push({
                date: dailyTimes[d],
                weatherCode: data.daily.weather_code[d],
                tempMax: data.daily.temperature_2m_max[d],
                tempMin: data.daily.temperature_2m_min[d],
                sunrise: data.daily.sunrise ? data.daily.sunrise[d] : "",
                sunset: data.daily.sunset ? data.daily.sunset[d] : "",
                uvMax: data.daily.uv_index_max ? data.daily.uv_index_max[d] : null,
                precipProbMax: data.daily.precipitation_probability_max ? data.daily.precipitation_probability_max[d] : 0,
                precipSum: data.daily.precipitation_sum ? data.daily.precipitation_sum[d] : 0
            });
        }

        var currentVisibility = (data.hourly && data.hourly.visibility && data.hourly.visibility.length > startIdx)
            ? data.hourly.visibility[startIdx] : null;
        var currentUv = (data.hourly && data.hourly.uv_index && data.hourly.uv_index.length > startIdx)
            ? data.hourly.uv_index[startIdx] : (dailyList.length > 0 ? dailyList[0].uvMax : null);

        var parsed = {
            timezone: data.timezone || "",
            current: {
                time: data.current.time,
                temperature: data.current.temperature_2m,
                feelsLike: data.current.apparent_temperature,
                humidity: data.current.relative_humidity_2m,
                isDay: data.current.is_day === 1,
                precipitation: data.current.precipitation,
                weatherCode: data.current.weather_code,
                cloudCover: data.current.cloud_cover,
                pressure: data.current.pressure_msl,
                windSpeed: data.current.wind_speed_10m,
                windDirection: data.current.wind_direction_10m,
                visibility: currentVisibility,
                uvIndex: currentUv,
                tempMax: dailyList.length > 0 ? dailyList[0].tempMax : null,
                tempMin: dailyList.length > 0 ? dailyList[0].tempMin : null,
                sunrise: dailyList.length > 0 ? dailyList[0].sunrise : "",
                sunset: dailyList.length > 0 ? dailyList[0].sunset : ""
            },
            hourly: hourlyList,
            daily: dailyList
        };

        callback(null, parsed);
    });
}

function searchLocations(query, lang, callback) {
    var trimmed = (query || "").trim();
    if (trimmed.length < 2) {
        callback(null, []);
        return;
    }
    var url = "https://geocoding-api.open-meteo.com/v1/search"
        + "?name=" + encodeURIComponent(trimmed)
        + "&count=8"
        + "&language=" + encodeURIComponent(lang || "en")
        + "&format=json";

    httpGetJson(url, 10000, function(err, data) {
        if (err) {
            callback(err, []);
            return;
        }
        var results = [];
        if (data && data.results) {
            for (var i = 0; i < data.results.length; i++) {
                var r = data.results[i];
                results.push({
                    name: r.name || "",
                    admin1: r.admin1 || "",
                    country: r.country || "",
                    countryCode: r.country_code || "",
                    latitude: r.latitude,
                    longitude: r.longitude
                });
            }
        }
        callback(null, results);
    });
}

function fetchIpLocation(callback) {
    var url = "https://get.geojs.io/v1/ip/geo.json";
    httpGetJson(url, 10000, function(err, data) {
        if (err || !data || !data.latitude || !data.longitude) {
            callback(err || "IP location unavailable", null);
            return;
        }
        callback(null, {
            name: data.city || data.region || data.country || "Current Location",
            admin1: data.region || "",
            country: data.country || "",
            latitude: parseFloat(data.latitude),
            longitude: parseFloat(data.longitude),
            source: "ip"
        });
    });
}

function reverseGeocode(lat, lon, lang, callback) {
    var url = "https://api.bigdatacloud.net/data/reverse-geocode-client"
        + "?latitude=" + encodeURIComponent(lat)
        + "&longitude=" + encodeURIComponent(lon)
        + "&localityLanguage=" + encodeURIComponent(lang || "en");

    httpGetJson(url, 8000, function(err, data) {
        if (err || !data) {
            callback(err || "Reverse geocode failed", null);
            return;
        }
        var city = data.city || data.locality || data.principalSubdivision || "";
        var admin1 = data.principalSubdivision || "";
        var country = data.countryName || "";
        callback(null, {
            name: city || (lat.toFixed(2) + ", " + lon.toFixed(2)),
            admin1: admin1 !== city ? admin1 : "",
            country: country,
            latitude: lat,
            longitude: lon,
            source: "gps"
        });
    });
}
