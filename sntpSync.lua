wifi.sta.sethostname("uopNodeMCU")
wifi.setmode(wifi.STATION)
station_cfg={}
station_cfg.ssid="Wifi Name" 
station_cfg.pwd="Password"
station_cfg.save=true
wifi.sta.config(station_cfg)

tmsrv = "uk.pool.ntp.org"

mytimer = tmr.create()
mytimer:register(3000, 1, function() 
   if wifi.sta.getip()==nil then
        print("Connecting to AP...\n")
   else
   
        ip, nm, gw=wifi.sta.getip()
        mac = wifi.sta.getmac()
        rssi = wifi.sta.getrssi()
        print("IP Info: \nIP Address: ",ip)
        print("Netmask: ",nm)
        print("Gateway Addr: ",gw)
        print("MAC: ",mac)  
        print("RSSI: ",rssi,"\n")
       
        sntp.sync(tmsrv,function()
        print("Sync succeeded")
        mytimer:stop()
        stampTime()
        end,function()
        print("Synchronization failed!")
        end, 1
        )
--sntp.sync([server_ip], [callback], [errcallback], [autorepeat])
   end 
end)
mytimer:start()

function stampTime()
    sec,microsec,rate = rtctime.get()
    tm = rtctime.epoch2cal(sec,microsec,rate)
    print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end
--get the stamp of the time from synchronized clock
