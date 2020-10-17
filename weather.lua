-- Get weather from openweathermap.org and display in a browser
-- John Longworth - June 2017
-- Needs sjson and rtctime modules

city ="2639310"   -- Put your own city code here
apid = "9f418d12e2c0f5e721197b55a91010a3" -- Put you own API code here

wifi.setmode(wifi.STATIONAP)
station_cfg={}
station_cfg.ssid="Wifi Name" 
station_cfg.pwd="Password"
station_cfg.save=true
wifi.sta.config(station_cfg)
cfg={ip="192.168.0.50",netmask="255.255.255.0",gateway="192.168.0.1"}
wifi.sta.setip(cfg)
ip = wifi.sta.getip()
if ip ~= nil then
  print("\n Weather Server started.\n")
  print("Key this IP address "..ip.." into a browser")
end  

pinADC = 0

-- Alarm function part
alarm_falg = false
current_time = ""
tmsrv = "uk.pool.ntp.org"
sntp.sync(tmsrv,function()
    print("Sync succeeded")
    stampTime()
    end,function()
    print("Synchronization failed!")
    end, 1
)

function stampTime()
    sec,microsec,rate = rtctime.get()
    tm = rtctime.epoch2cal(sec,microsec,rate)
    current_time = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], 
    tm["min"], tm["sec"])
    print(current_time)
end

cron.schedule("40 17 * * *", function(e) --3
  alarm_falg = true
  print("\n Alarm Clock \n It is 16:32!!! \n Get UP! \n")
end)

-- End of Alarm function part

conn = nil
conn=net.createConnection(net.TCP, 0) 

conn:on("connection", function(conn, payload) 
    print("\n Connected to openweathermap.org")
    conn:send("GET /data/2.5/weather?id="..city.."&APPID="..apid.."&units=metric"
    .." HTTP/1.1\r\n" 
    .."Host: api.openweathermap.org\r\n" 
    .."Connection: close\r\n"
    .."Accept: */*\r\n" 
    .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
    .."\r\n")
end) 
 
conn:on("receive", function(conn, payload)     
    payload = string.match(payload, "{.*}") -- Select json part of payload
    print(payload)
    if payload ~= nil then      
        forecast = sjson.decode(payload)  -- Decode json string 
        print_weather()     
    else                       
        print("Connection failed")  
    end     
end)       

function print_weather()
    print("Weather for")      
    print(forecast.name.." "..forecast.sys.country) 
    print("Long "..forecast.coord.lon.." Lat "..forecast.coord.lat)
    print("ID          "..forecast.id)
    print("Temperature "..forecast.main.temp.." °C")                      
    print("Max Temp    "..forecast.main.temp_max.." °C")
    print("Min Temp    "..forecast.main.temp_min.." °C")                      
    print("Pressure    "..forecast.main.pressure.." hPa")                    
    print("Humidity    "..forecast.main.humidity.."%")                      
    --print("Visibility  "..forecast.visibility.." m")
    print("id          "..forecast.weather[1].id)    
    print("Main        "..forecast.weather[1].main)
    print("Description "..forecast.weather[1].description)
    print("Icon        "..forecast.weather[1].icon)
    print("Windspeed   "..forecast.wind.speed)
    print("Wind dir    "..forecast.wind.deg)
    st = rtctime.epoch2cal(forecast.sys.sunrise)
    print("Sunrise     "..st.hour.."."..st.min)
    st = rtctime.epoch2cal(forecast.sys.sunset)
    print("Sunset      "..st.hour.."."..st.min)
    
    st = rtctime.epoch2cal(forecast.dt)
    print("Date        "..st.hour.."."..st.min,st.day.."/"..st.mon.."/"..st.year)
end


function receiver81(sck, data)
  if string.find(data, "ON")  then
   local str = ""
   str = adc.read(pinADC)
   sck:send("\r\nON ADC Display"..str)       
   
  elseif string.find(data, "OFF")  then
   sck:send("\r\nOFF  Light Sensor diable")

  elseif string.find(data, "EXIT")  then
   sck:close()
  else
   sck:send("\r\nCommand Not Found...!!!")
  end
end

srv=net.createServer(net.TCP,0) 
srv1 = net.createServer(net.TCP, 120)

srv:listen(80,function(server) 
    server:on("receive",function(server,payload) 
    local buf = ""
    buf=buf.."<HTML><HEAD><TITLE>NodeMCU Weather Page</TITLE><meta http-equiv=\"refresh\" content=\"5\"></HEAD>"
    buf=buf.."<BODY><h2>Weather from NodeMCU & openweathermap.org</h2>"
    buf=buf.."<H3>ESP8266 Chip ID  "..node.chipid().."<BR><BR>" 
    buf=buf.."<IMG SRC=https://openweathermap.org/img/w/"..forecast.weather[1].icon..".png><BR>"
    buf=buf..forecast.weather[1].main.."<BR></H3>"
    buf=buf.."<H4>Max Temp    "..forecast.main.temp_max.."°C<BR>"
    buf=buf.."Min Temp    "..forecast.main.temp_min.."°C<BR></H4>"
    if alarm_falg == true then 
     buf=buf.."<H4>Alarm Clock! Get Up! It is 17:40!!!<BR>"
     buf=buf.."Current Time   "..current_time.." <BR><BR><BR></H4>"
    end
    buf=buf.."<H4>Hello Client   <BR>"
    buf=buf.."1. Send \"ON\" command to Display the ADC  <BR>"
    buf=buf.."2. Send \"OFF\" command to Light Sensor diable  <BR>"
    buf=buf.."3. Send \"EXIT\" command to Exit  <BR></H4>"
    buf=buf.."<form action=\"/get\">Command: <input type=\"text\" name=\"command\"><input type=\"submit\" value=\"Submit\"></form><br>"

      
       if string.find(payload, "ON")  then
       local str = ""
       str = adc.read(pinADC)
       buf=buf.."<H4> ON ADC Display "..str.." <BR>"
       --server:send("\r\nON ADC Display"..str)       
       
      elseif string.find(payload, "OFF")  then
      buf=buf.."<H4> OFF Light Sensor diable <BR>"
      --server:send("\r\nOFF  Light Sensor diable")
    
      elseif string.find(payload, "EXIT")  then
       server:close()
      else
      buf=buf.."<H4> OFF Command Not Found...!!! <BR>"
      --server:send("\r\nCommand Not Found...!!!")
      end
    
    buf=buf.."</BODY></HTML>"
    server:send(buf)

   
    end)
    server:on("sent",function(srv) 
        srv:close() 
    end)
end)

srv1:listen(81, function(server)
server:on("receive", receiver81)
server:send("Hello Client\r\n")
server:send("1. Send 'ON' command to Display the ADC\r\n")
server:send("2. Send 'OFF' command to Light Sensor diable\r\n")
server:send("3. Send 'EXIT' command to Exit\r\n")
end)

conn:connect(80,'api.openweathermap.org')   


