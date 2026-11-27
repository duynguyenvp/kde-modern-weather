.pragma library

var STRINGS = {
    en: {
        appName: "Modern Weather",
        tabLocations: "Locations",
        tabUnits: "Units",
        tabGeneral: "General",

        loading: "Loading weather...",
        locating: "Detecting location...",
        noLocation: "No location configured",
        noLocationHint: "Open widget settings to add a location or enable OS location.",
        openSettings: "Open Settings",
        refresh: "Refresh",
        retry: "Retry",
        updatedAt: "Updated {time}",
        systemLocation: "OS Location",
        systemLocationGps: "OS Location (System)",
        systemLocationIp: "OS Location (Network)",
        manualLocation: "Manual",
        switchLocation: "Switch location",

        feelsLike: "Feels like",
        humidity: "Humidity",
        wind: "Wind",
        pressure: "Pressure",
        uvIndex: "UV Index",
        visibility: "Visibility",
        precipitation: "Precipitation",
        sunrise: "Sunrise",
        sunset: "Sunset",
        highLow: "H: {high}  L: {low}",

        hourlyForecast: "Hourly Forecast",
        dailyForecast: "7-Day Forecast",
        today: "Today",
        now: "Now",

        uvLow: "Low",
        uvModerate: "Moderate",
        uvHigh: "High",
        uvVeryHigh: "Very High",
        uvExtreme: "Extreme",

        // Settings - Locations
        locationSource: "Location Source",
        useOsLocation: "Use operating system location",
        useOsLocationDesc: "Uses system geolocation (GeoClue2) with automatic network fallback.",
        searchCity: "Search city or place",
        searchPlaceholder: "e.g. Hanoi, Ho Chi Minh City, Tokyo, London...",
        searchButton: "Search",
        searching: "Searching...",
        noResults: "No matching locations found.",
        addLocation: "Add",
        savedLocations: "Saved Locations",
        noSavedLocations: "No manual locations saved yet. Search above or add coordinates manually.",
        setActive: "Use",
        activeBadge: "Active",
        remove: "Remove",
        manualCoordinates: "Add by coordinates",
        locationName: "Name",
        latitude: "Latitude",
        longitude: "Longitude",
        addManualButton: "Add Coordinates",
        invalidCoordinates: "Please enter a name and valid latitude (-90..90) / longitude (-180..180).",

        // Settings - Units
        temperatureUnit: "Temperature",
        celsius: "Celsius (°C)",
        fahrenheit: "Fahrenheit (°F)",
        windSpeedUnit: "Wind Speed",
        kmh: "km/h",
        ms: "m/s",
        mph: "mph",
        kn: "knots",
        pressureUnit: "Pressure",
        hpa: "hPa",
        inhg: "inHg",
        mmhg: "mmHg",
        precipitationUnit: "Precipitation",
        mm: "mm",
        inch: "inch",
        timeFormat: "Time Format",
        timeAuto: "System default",
        time24h: "24-hour",
        time12h: "12-hour",

        // Settings - General
        languageLabel: "Language",
        langAuto: "System default (fallback: English)",
        langEn: "English",
        langVi: "Tiếng Việt",
        refreshInterval: "Auto-refresh interval",
        everyMinutes: "Every {n} minutes",
        everyHour: "Every 1 hour",
        panelAppearance: "Taskbar / Panel",
        showTempInPanel: "Show temperature next to weather icon",
        showTempUnitInPanel: "Show temperature unit (°C / °F)",
        panelFontFamily: "Font family",
        fontDefault: "System default",
        panelFontSize: "Font size",
        fontSizeAuto: "Auto",
        panelFontStyle: "Font style",
        weightNormal: "Regular",
        weightMedium: "Medium",
        weightDemiBold: "Semi-bold",
        weightBold: "Bold",
        fontItalic: "Italic",
        fontPreview: "Preview",
        showCondInTooltip: "Show detailed weather condition in tooltip",
        dynamicIconNote: "The taskbar icon automatically updates to match the current weather and day/night cycle.",

        // Errors
        errNetwork: "Unable to fetch weather data. Check your internet connection.",
        errLocation: "Could not detect OS location. Add a manual location in settings.",

        // WMO Weather Codes
        wmo_0: "Clear sky",
        wmo_1: "Mainly clear",
        wmo_2: "Partly cloudy",
        wmo_3: "Overcast",
        wmo_45: "Fog",
        wmo_48: "Rime fog",
        wmo_51: "Light drizzle",
        wmo_53: "Moderate drizzle",
        wmo_55: "Dense drizzle",
        wmo_56: "Light freezing drizzle",
        wmo_57: "Dense freezing drizzle",
        wmo_61: "Slight rain",
        wmo_63: "Moderate rain",
        wmo_65: "Heavy rain",
        wmo_66: "Light freezing rain",
        wmo_67: "Heavy freezing rain",
        wmo_71: "Slight snow",
        wmo_73: "Moderate snow",
        wmo_75: "Heavy snow",
        wmo_77: "Snow grains",
        wmo_80: "Slight rain showers",
        wmo_81: "Moderate rain showers",
        wmo_82: "Violent rain showers",
        wmo_85: "Slight snow showers",
        wmo_86: "Heavy snow showers",
        wmo_95: "Thunderstorm",
        wmo_96: "Thunderstorm with slight hail",
        wmo_99: "Thunderstorm with heavy hail",
        wmo_unknown: "Unknown",

        weekdaysShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        windDirs: ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    },
    vi: {
        appName: "Thời tiết hiện đại",
        tabLocations: "Vị trí",
        tabUnits: "Đơn vị",
        tabGeneral: "Cài đặt chung",

        loading: "Đang tải dữ liệu thời tiết...",
        locating: "Đang xác định vị trí...",
        noLocation: "Chưa thiết lập vị trí",
        noLocationHint: "Mở cài đặt widget để thêm vị trí thủ công hoặc bật vị trí hệ điều hành.",
        openSettings: "Mở cài đặt",
        refresh: "Làm mới",
        retry: "Thử lại",
        updatedAt: "Cập nhật lúc {time}",
        systemLocation: "Vị trí hệ điều hành",
        systemLocationGps: "Vị trí hệ điều hành (Hệ thống)",
        systemLocationIp: "Vị trí hệ điều hành (Mạng)",
        manualLocation: "Thủ công",
        switchLocation: "Đổi vị trí",

        feelsLike: "Cảm giác như",
        humidity: "Độ ẩm",
        wind: "Gió",
        pressure: "Áp suất",
        uvIndex: "Chỉ số UV",
        visibility: "Tầm nhìn",
        precipitation: "Lượng mưa",
        sunrise: "Bình minh",
        sunset: "Hoàng hôn",
        highLow: "C: {high}  T: {low}",

        hourlyForecast: "Dự báo theo giờ",
        dailyForecast: "Dự báo 7 ngày",
        today: "Hôm nay",
        now: "Bây giờ",

        uvLow: "Thấp",
        uvModerate: "Trung bình",
        uvHigh: "Cao",
        uvVeryHigh: "Rất cao",
        uvExtreme: "Cực đoan",

        // Settings - Locations
        locationSource: "Nguồn vị trí",
        useOsLocation: "Dùng vị trí của hệ điều hành",
        useOsLocationDesc: "Sử dụng định vị hệ thống (GeoClue2), tự động dự phòng qua mạng nếu cần.",
        searchCity: "Tìm kiếm thành phố / địa điểm",
        searchPlaceholder: "VD: Hà Nội, Hồ Chí Minh, Đà Nẵng, Tokyo...",
        searchButton: "Tìm kiếm",
        searching: "Đang tìm kiếm...",
        noResults: "Không tìm thấy địa điểm phù hợp.",
        addLocation: "Thêm",
        savedLocations: "Vị trí đã lưu",
        noSavedLocations: "Chưa có vị trí thủ công nào. Hãy tìm kiếm phía trên hoặc nhập tọa độ.",
        setActive: "Chọn",
        activeBadge: "Đang dùng",
        remove: "Xóa",
        manualCoordinates: "Thêm bằng tọa độ",
        locationName: "Tên địa điểm",
        latitude: "Vĩ độ",
        longitude: "Kinh độ",
        addManualButton: "Thêm tọa độ",
        invalidCoordinates: "Vui lòng nhập tên và vĩ độ (-90..90), kinh độ (-180..180) hợp lệ.",

        // Settings - Units
        temperatureUnit: "Nhiệt độ",
        celsius: "Độ C (°C)",
        fahrenheit: "Độ F (°F)",
        windSpeedUnit: "Tốc độ gió",
        kmh: "km/h",
        ms: "m/s",
        mph: "mph",
        kn: "hải lý/giờ (kn)",
        pressureUnit: "Áp suất",
        hpa: "hPa",
        inhg: "inHg",
        mmhg: "mmHg",
        precipitationUnit: "Lượng mưa",
        mm: "mm",
        inch: "inch",
        timeFormat: "Định dạng giờ",
        timeAuto: "Theo hệ điều hành",
        time24h: "24 giờ",
        time12h: "12 giờ",

        // Settings - General
        languageLabel: "Ngôn ngữ",
        langAuto: "Theo hệ điều hành (mặc định: Tiếng Anh)",
        langEn: "English",
        langVi: "Tiếng Việt",
        refreshInterval: "Tần suất tự động cập nhật",
        everyMinutes: "Mỗi {n} phút",
        everyHour: "Mỗi 1 giờ",
        panelAppearance: "Thanh tác vụ (Taskbar)",
        showTempInPanel: "Hiển thị nhiệt độ bên cạnh icon thời tiết",
        showTempUnitInPanel: "Hiển thị đơn vị nhiệt độ (°C / °F)",
        panelFontFamily: "Phông chữ",
        fontDefault: "Mặc định hệ thống",
        panelFontSize: "Cỡ chữ",
        fontSizeAuto: "Tự động",
        panelFontStyle: "Kiểu chữ",
        weightNormal: "Thường",
        weightMedium: "Vừa",
        weightDemiBold: "Bán đậm",
        weightBold: "Đậm",
        fontItalic: "In nghiêng",
        fontPreview: "Xem trước",
        showCondInTooltip: "Hiển thị chi tiết tình trạng thời tiết khi di chuột",
        dynamicIconNote: "Icon trên taskbar sẽ tự động thay đổi theo tình hình thời tiết thực tế và ngày/đêm.",

        // Errors
        errNetwork: "Không thể tải dữ liệu thời tiết. Vui lòng kiểm tra kết nối mạng.",
        errLocation: "Không thể xác định vị trí hệ điều hành. Hãy thêm vị trí thủ công trong cài đặt.",

        // WMO Weather Codes
        wmo_0: "Trời quang đãng",
        wmo_1: "Ít mây",
        wmo_2: "Có mây rải rác",
        wmo_3: "Nhiều mây",
        wmo_45: "Sương mù",
        wmo_48: "Sương mù đóng băng",
        wmo_51: "Mưa phùn nhẹ",
        wmo_53: "Mưa phùn vừa",
        wmo_55: "Mưa phùn dày",
        wmo_56: "Mưa phùn đóng băng nhẹ",
        wmo_57: "Mưa phùn đóng băng dày",
        wmo_61: "Mưa nhẹ",
        wmo_63: "Mưa vừa",
        wmo_65: "Mưa to",
        wmo_66: "Mưa đóng băng nhẹ",
        wmo_67: "Mưa đóng băng to",
        wmo_71: "Tuyết rơi nhẹ",
        wmo_73: "Tuyết rơi vừa",
        wmo_75: "Tuyết rơi dày",
        wmo_77: "Mưa tuyết hạt",
        wmo_80: "Mưa rào nhẹ",
        wmo_81: "Mưa rào vừa",
        wmo_82: "Mưa rào rất to",
        wmo_85: "Mưa tuyết rào nhẹ",
        wmo_86: "Mưa tuyết rào dày",
        wmo_95: "Dông bão",
        wmo_96: "Dông kèm mưa đá nhẹ",
        wmo_99: "Dông kèm mưa đá lớn",
        wmo_unknown: "Không xác định",

        weekdaysShort: ["CN", "T2", "T3", "T4", "T5", "T6", "T7"],
        windDirs: ["B", "ĐB", "Đ", "ĐN", "N", "TN", "T", "TB"]
    }
};

function resolveLang(langSetting) {
    if (langSetting === "vi") {
        return "vi";
    }
    if (langSetting === "en") {
        return "en";
    }
    // Auto: detect OS locale, fallback to English
    try {
        var localeName = Qt.locale().name || "";
        if (localeName.toLowerCase().indexOf("vi") === 0) {
            return "vi";
        }
    } catch (e) {
        // Fallback to English if Qt.locale() is unavailable
    }
    return "en";
}

function t(key, langSetting, params) {
    var lang = resolveLang(langSetting);
    var dict = STRINGS[lang] || STRINGS.en;
    var text = dict[key];
    if (text === undefined) {
        text = STRINGS.en[key];
    }
    if (text === undefined) {
        return key;
    }
    if (params && typeof text === "string") {
        for (var k in params) {
            if (params.hasOwnProperty(k)) {
                text = text.replace(new RegExp("\\{" + k + "\\}", "g"), String(params[k]));
            }
        }
    }
    return text;
}

function weatherDescription(wmoCode, langSetting) {
    var key = "wmo_" + wmoCode;
    var lang = resolveLang(langSetting);
    var dict = STRINGS[lang] || STRINGS.en;
    if (dict[key] !== undefined) {
        return dict[key];
    }
    return t("wmo_unknown", langSetting);
}

function weekdayShort(isoDateStr, langSetting) {
    if (!isoDateStr) {
        return "";
    }
    // Parse YYYY-MM-DD in local time to avoid UTC off-by-one shifts
    var parts = isoDateStr.split("-");
    if (parts.length < 3) {
        return isoDateStr;
    }
    var d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
    var lang = resolveLang(langSetting);
    var list = (STRINGS[lang] || STRINGS.en).weekdaysShort;
    return list[d.getDay()] || "";
}

function windDirection(degrees, langSetting) {
    if (degrees === undefined || degrees === null || isNaN(degrees)) {
        return "";
    }
    var lang = resolveLang(langSetting);
    var dirs = (STRINGS[lang] || STRINGS.en).windDirs;
    var idx = Math.round(((degrees % 360) + 360) % 360 / 45) % 8;
    return dirs[idx];
}

function uvLevel(uvValue, langSetting) {
    if (uvValue === undefined || uvValue === null || isNaN(uvValue)) {
        return "";
    }
    if (uvValue < 3) return t("uvLow", langSetting);
    if (uvValue < 6) return t("uvModerate", langSetting);
    if (uvValue < 8) return t("uvHigh", langSetting);
    if (uvValue < 11) return t("uvVeryHigh", langSetting);
    return t("uvExtreme", langSetting);
}
