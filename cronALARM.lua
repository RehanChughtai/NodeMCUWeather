tmsrv = "uk.pool.ntp.org"
sntp.sync(tmsrv,function()
    print("Sync succeeded")
    stampTime()
    end,function()
    print("Synchronization failed!")
    end, 1
)
--sntp.sync([server_ip], [callback], [errcallback], [autorepeat])


function stampTime()
    sec,microsec,rate = rtctime.get()
    tm = rtctime.epoch2cal(sec,microsec,rate)
    print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end
--get the stamp of the time from synchronized clock

--cron.schedule()
--refer to https://en.wikipedia.org/wiki/Cron
--for the mask "* * * * *" information
--minute, hour, day of a month, month of a year, day of the week
cron.schedule("* * * * *", function(e)
  print("For every minute function will be executed once")
end)

cron.schedule("*/5 * * * *", function(e)
  print("For every 5 minutes function will be executed once")
end)

cron.schedule("33 16 * * *", function(e)
  print("\n Alarm Clock \n It is 16:32!!! \n Get UP! \n")
end)
--set your own alarm at 07:00
--please change it to 2 minutes later from now on
--and see if it will alarm you according to the synchronized time.
