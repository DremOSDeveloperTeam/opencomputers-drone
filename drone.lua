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

sendMsg(msg)
  t.broadcast(commport,d.name(),"up",msg)
end

while true do
  d.setLightColor(idle_color)
  local evt,_,sender,port,_,name,cmd,a,b,c = computer.pullSignal()
  d.setLightColor(cmdrec_color)
  if evt == "modem_message" and name == d.name() then
    d.setLightColor(cmdacc_color)
    if cmd == "gfw" then -- Get Firmware Version
      t.broadcast(commport, fwv)
    end
    if cmd == "ufw" then -- Update Firmware.
      local web_request = interweb.request(fwaddress)
      sendMsg("Updating firmware...")
      sendMsg("  Connecting...")
      web_request.finishConnect()
      sendMsg("  Connected!")
      sendMsg("  Downloading new firmware...")
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
      sendMsg("  Firmware file downloaded!")
      sendMsg("  Flashing new firmware...")
      eeprom.set(full_response)
      sendMsg("  Done flashing firmware!")
      sendMsg("Update process done! Please reboot the drone for changes to take effect.")
    end
    if cmd == "gst" then -- Get Status Text
      sendMsg(d.getStatusText())
    end
    if cmd == "sst" then -- Set Status Text
      sendMsg(d.setStatusText(a))
    end
    if cmd == "gpn" then -- Get Port Number
      sendMsg(commport)
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
      sendMsg(d.getOffset())
    end
    if cmd == "gve" then -- Get VElocity
      sendMsg(d.getVelocity())
    end
    if cmd == "gmv" then -- Get Max Velocity
      sendMsg(d.getMaxVelocity())
    end
    if cmd == "gac" then -- Get ACceleration
      sendMsg(d.getAcceleration())
    end
    if cmd == "sac" then -- Set ACceleration
      d.setAcceleration(a)
    end
    if cmd == "glc" then -- Get Light Color
      sendMsg(d.getLightColor())
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
    if cmd == "eif" then -- External Inventory Find
      local b, s = d.detect(a)
      sendMsg(b)
      sendMsg(s)
    end
    if cmd == "eco" then -- External inventory COmpare
      sendMsg(d.compare(a))
    end
    if cmd == "esu" then -- External inventory SUck
      o = d.suck(a, b)
      sendMsg(o)
    end
    if cmd == "edr" then -- External inventory DRop
      o = d.drop(a, b)
      sendMsg(o)
    end
    if cmd == "igs" then -- Internal inventory Get Slot
      sendMsg(d.select())
    end
    if cmd == "iss" then -- Internal inventory Set Slot
      o = d.select(a)
      sendMsg(o)
    end
    if cmd == "gis" then -- Get Inventory Size
      sendMsg(d.inventorySize())
    end
    if cmd == "gsr" then -- Get Slot space Remaining
      sendMsg(d.space(a))
    end
  end
end
