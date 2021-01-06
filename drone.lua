-- Based off https://oc.cil.li/topic/1570-drone-controll-bios/
-- Modified by enthusiasticGeek to give the drone inventory capabilities, as well as the ability to update itself without disassembly.
-- Version 0.01

local fwv = "0.01"
local d = component.proxy(component.list("drone")())
local t = component.proxy(component.list("modem")())
local eeprom = component.proxy(component.list("eeprom")())
local interweb = component.proxy(component.list("internet")())
local event = require("event")
local fwaddress = "https://raw.githubusercontent.com/DremOSDeveloperTeam/opencomputers-drone/master/drone.lua"
local commport = 6500

t.open(6500)

while true do
  local evt,_,sender,port,_,name,cmd,a,b,c = event.pull("modem_message")
  if evt == "modem_message" and name == d.name() then
    if cmd == "gfw" then -- Get Firmware Version
      t.broadcast(commport, fwv)
    end
    if cmd == "ufw" then -- Update Firmware. Essentially stolen from https://github.com/osmarks/oc-drone/
      local web_request = interweb.request(fwaddress)
      t.broadcast(commport, "Updating firmware...")
      t.broadcast(commport, "  Connecting...")
      web_request.finishConnect()
      t.broadcast(commport, "  Connected!")
      t.broadcast(commport, "  Downloading new firmware...")
      local full_response = ""
      while true do
        --status "Processing"
        local chunk = web_request.read()
        if chunk then
          str.gsub(chunk, "\r\n", "\n")
          full_response = full_response .. chunk
        else
          break
        end
      end
      t.broadcast(commport, "  Firmware file downloaded!")
      t.broadcast(commport, "  Flashing new firmware...")
      eeprom.set(full_response)
      t.broadcast(commport, "  Done flashing firmware!")
      t.broadcast(commport, "Update process done! Please reboot the drone for changes to take effect.")
    end
    if cmd == "gst" then -- Get Status Text
      t.broadcast(commport, d.name(),"gst",d.getStatusText())
    end
    if cmd == "sst" then -- Set Status Text
      t.broadcast(commport, d.name(),"sst",d.setStatusText(a))
    end
    if cmd == "mov" then -- MOVe
      d.move(a,b,c)
    end
    if cmd == "gos" then -- Get OffSet
      t.broadcast(commport, d.name(),"gos",d.getOffset())
    end
    if cmd == "gve" then -- Get VElocity
      t.broadcast(commport, d.name(),"gv",d.getVelocity())
    end
    if cmd == "gmv" then -- Get Max Velocity
      t.send(commport, d.name(),"gmv",d.getMaxVelocity())
    end
    if cmd == "gac" then -- Get ACceleration
      t.broadcast(commport, d.name(),"ga",d.getAcceleration())
    end
    if cmd == "sac" then -- Set ACceleration
      d.setAcceleration(a)
    end
    if cmd == "glc" then -- Get Light Color
      t.broadcast(commport, d.name(),"glc",d.getLightColor())
    end
    if cmd == "slc" then -- Set Light Color (RGB is important!)
      d.setLightColor(a)
    end
    if cmd == "eif" then -- External Inventory Find (Instead of detect)
      local b, s = d.detect(a)
      t.broadcast(commport, d.name(),"dct",b,s)
    end
    if cmd == "eco" then -- External inventory COmpare
      t.broadcast(commport, d.name(),"c",d.compare(a))
    end
    if cmd == "esu" then -- External inventory SUck
      o = d.suck(a, b)
      t.broadcast(commport, o)
    end
    if cmd == "edr" then -- External inventory DRop
      o = d.drop(a, b)
      t.broadcast(commport, o)
    end
    if cmd == "igs" then -- Internal inventory Get Slot
        t.broadcast(commport, d.select())
    end
    if cmd == "iss" then -- Internal inventory Set Slot
        o = d.select(a)
        t.broadcast(commport, o)
    end
    if cmd == "gis" then -- Get Inventory Size
      t.broadcast(commport, d.inventorySize())
    end
    if cmd == "gsr" then -- Get Slot space Remaining
        t.broadcast(commport, d.space(a))
    end
  end
end
