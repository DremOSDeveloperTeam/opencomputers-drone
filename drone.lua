-- Based off https://oc.cil.li/topic/1570-drone-controll-bios/
-- Modified by enthusiasticGeek to give the drone inventory capabilities, as well as the ability to update itself without disassembly.
-- Version 0.02

local fwv = "0.02"
local d = component.proxy(component.list("drone")())
local t = component.proxy(component.list("modem")())
local eeprom = component.proxy(component.list("eeprom")())
local interweb = component.proxy(component.list("internet")())
local str = string
local fwaddress = "https://raw.githubusercontent.com/DremOSDeveloperTeam/opencomputers-drone/master/drone.lua"
local commport = 6500
local idle_color = 0xFF00FF
local cmdrec_color = 0xFF00FF
local cmdacc_color = 0xFFFFFF

t.open(6500)

while true do
  d.setLightColor(idle_color)
  local evt,_,sender,port,_,name,cmd,a,b,c = computer.pullSignal()
  d.setLightColor(cmdrec_color)
  if evt == "modem_message" and name == d.name() then
    d.setLightColor(cmdacc_color)
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
      t.broadcast(commport, d.name(),"up",d.getStatusText())
    end
    if cmd == "sst" then -- Set Status Text
      t.broadcast(commport, d.name(),"up",d.setStatusText(a))
    end
    if cmd == "gpn" then -- Get Port Number
      t.broadcast(commport, d.name(),"up",commport)
    end
    if cmd == "spn" then -- Set Port Number
      if a ~= nil and a ~= '' then
        commport = a
      end
    end
    if cmd == "mov" then -- MOVe
      d.move(a,b,c)
    end
    if cmd == "gos" then -- Get OffSet
      t.broadcast(commport, d.name(),"up",d.getOffset())
    end
    if cmd == "gve" then -- Get VElocity
      t.broadcast(commport, d.name(),"up",d.getVelocity())
    end
    if cmd == "gmv" then -- Get Max Velocity
      t.send(commport, d.name(),"up",d.getMaxVelocity())
    end
    if cmd == "gac" then -- Get ACceleration
      t.broadcast(commport, d.name(),"up",d.getAcceleration())
    end
    if cmd == "sac" then -- Set ACceleration
      d.setAcceleration(a)
    end
    if cmd == "glc" then -- Get Light Color
      t.broadcast(commport, d.name(),"up",d.getLightColor())
    end
    if cmd == "slc" then -- Set Light Color (RGB is important!)
      if b ~= nil and b ~= '' then
        if b == "0" then
          idle_color = a
        end
        if b == "1" then
          cmdrec_color = a
        end
        if b == "2" then
          cmdacc_color = a
        end
      end
    end
    if cmd == "eif" then -- External Inventory Find (Instead of detect)
      local b, s = d.detect(a)
      t.broadcast(commport, d.name(),"up",b,s)
    end
    if cmd == "eco" then -- External inventory COmpare
      t.broadcast(commport, d.name(),"up",d.compare(a))
    end
    if cmd == "esu" then -- External inventory SUck
      o = d.suck(a, b)
      t.broadcast(commport, d.name, "up", o)
    end
    if cmd == "edr" then -- External inventory DRop
      o = d.drop(a, b)
      t.broadcast(commport, d.name(), "up", o)
    end
    if cmd == "igs" then -- Internal inventory Get Slot
      t.broadcast(commport, d.name(), "up", d.select())
    end
    if cmd == "iss" then -- Internal inventory Set Slot
      o = d.select(a)
      --t.broadcast(commport, d.name(), "up", o)
    end
    if cmd == "gis" then -- Get Inventory Size
      t.broadcast(commport, d.name(), "up", d.inventorySize())
    end
    if cmd == "gsr" then -- Get Slot space Remaining
      t.broadcast(commport, d.name(), "up", d.space(a))
    end
  end
end
