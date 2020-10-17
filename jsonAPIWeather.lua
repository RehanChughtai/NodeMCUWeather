keyAPI = "9f418d12e2c0f5e721197b55a91010a3"
--This free API key allows no more than 1 request per second
--if it fails please register your own which is free- Dalin
lat = 50.80
lon = -1.09
--Using the longitude and latitude of Portsmouth to retrieve weather data
urlAPI = "http://api.openweathermap.org/data/2.5/weather?lat="..lat.."&lon="..lon.."&APPID="..keyAPI
http.get(urlAPI, nil, function(code, data)
    if (code < 0) then
--200 is success code
--for the rest, refer to https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
        print("http request failed")
    else
        print ("http response code:"..code)
        obj:write(data)
        weatherPrint(currentWeather)
    end 
end)


currentWeather = {}
mt = {}
t = {metatable = mt}
mt.__newindex = function(table, key, value)
    if
    (key == "description") or 
    (key == "temp") or 
    (key == "temp_min") or 
    (key == "temp_max") or 
    (key == "humidity")or 
    (key == "speed")or 
    (key == "deg")or 
    (key == "sunrise")or 
    (key == "sunset")
    then
        rawset(currentWeather, key, value)
    end
end
obj = sjson.decoder(t)
--from json to a readable table 

function weatherPrint(t)
    print("\nWeather Today: "..t["description"])
    print("\nTemperature: "..t["temp"]-273.15)
    print("\nMin Temperature: "..t["temp_min"]-273.15)
    print("\nMax Temperature: "..t["temp_max"]-273.15)
    print("\nHumidity: "..t["humidity"])
    print("\nWind Speed: "..t["speed"])
    print("\nWind Degree: "..t["deg"])
    tm = rtctime.epoch2cal(t["sunrise"])
    print("\nSunrise Time: "..string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])) 
    tm = rtctime.epoch2cal(t["sunset"])
    print("\nSunset Time: "..string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end
