-- Based off https://oc.cil.li/topic/1570-drone-controll-bios/
-- Modified by enthusiasticGeek to give the drone inventory capabilities, as well as the ability to update itself without disassembly*.
-- * Did not actually add that
-- Version 0.01

local fwv = "0.01"
local d = component.proxy(component.list("drone")())
local t = component.proxy(component.list("tunnel")())
while true do
  local evt,_,sender,_,_,name,cmd,a,b,c = computer.pullSignal()
  if evt == "modem_message" and name == d.name() then
    if cmd == "gfw" then -- Get Firmware Version
      t.send(fwv)
    end
    if cmd == "ufw" then -- Update Firmware
      t.send("Coming soon(TM)")
    end
    if cmd == "gst" then -- Get Status Text
      t.send(d.name(),"gst",d.getStatusText())
    end
    if cmd == "sst" then -- Set Status Text
      t.send(d.name(),"sst",d.setStatusText(a))
    end
    if cmd == "mov" then -- MOVe
      d.move(a,b,c)
    end
    if cmd == "gos" then -- Get OffSet
      t.send(d.name(),"gos",d.getOffset())
    end
    if cmd == "gve" then - Get VElocity
      t.send(d.name(),"gv",d.getVelocity())
    end
    if cmd == "gmv" then -- Get Max Velocity
      t.send(d.name(),"gmv",d.getMaxVelocity())
    end
    if cmd == "gac" then - Get ACceleration
      t.send(d.name(),"ga",d.getAcceleration())
    end
    if cmd == "sac" then -- Set ACceleration
      d.setAcceleration(a)
    end
    if cmd == "glc" then -- Get Light Color
      t.send(d.name(),"glc",d.getLightColor())
    end
    if cmd == "slc" then -- Set Light Color (RGB is important!)
      d.setLightColor(a)
    end
    if cmd == "eif" then -- External Inventory Find (Instead of detect)
      local b, s = d.detect(a)
      t.send(d.name(),"dct",b,s)
    end
    if cmd == "eco" then -- External inventory COmpare
      t.send(d.name(),"c",d.compare(a))
    end
    if cmd == "esu" then -- External inventory SUck
      o = d.suck(a, b)
      t.send(o)
    end
    if cmd == "edr" then -- External inventory DRop
      o = d.drop(a, b)
      t.send(o)
    end
    if cmd == "igs" then -- Internal inventory Get Slot
        t.send(d.select())
    end
    if cmd == "iss" then -- Internal inventory Set Slot
        o = d.select(a)
        t.send(o)
    end
    if cmd == "gis" then -- Get Inventory Size
      t.send(d.inventorySize())
    end
    if cmd == "gsr" then -- Get Slot space Remaining
        t.send(d.space(a))
    end
  end
end
