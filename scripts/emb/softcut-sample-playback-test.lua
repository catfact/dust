-- basic sample playback test
--
-- one long sample
-- all voices
-- random rate changes

local math = require 'math'

engine.name = "SoftCut"

local e = engine

-- sample rate
local SR = 48000
-- total buffer size
local BUFDUR = 300

-- region data
local r = { start = 1, stop = BUFDUR }

function init()
   local path = "/home/we/dust/audio/tape/hermit_leaves.wav"
   local ch, len = sound_file_inspect(path)
   local dur = len / SR
   print('file length: ' .. len)
   -- clamp the number of frames to load
   if r.start + dur > BUFDUR then
      dur = BUFDUR - r.start
   end
   -- set the region
   r.stop = r.start + dur
   -- load the buffer
   e.read(path, r.start, dur)

   local rate = { -2, -1, 1, 2 }
   local pan = {{1, 0}, {0.75, 0.25}, {0.25, 0.75}, {0, 1}}
   
   for i=1,4 do
      engine.loop_on(i, 1)
      engine.amp(i, 1)
      -- set all voices to same loop region
      e.loop_start(i, r.start)
      e.loop_end(i, r.stop)
      -- set playback rate
      e.rate(i, rate[i])      
      
      -- set pan posiion
      e.play_dac(i, 1, pan[i][1])
      e.play_dac(i, 2, pan[i][2])
     
      e.pos(i, r.start)      
      e.reset(i)
      e.start(i)

      -- randomly change a playback rate once per second
      local rate_m = metro.alloc( function()
	    local v = math.random(4)
	    
	 -- set rate to a random ratio and random direction
	 rate[v] = math.random(4) / math.random(4) * (math.random(2) == 2 and 1 or -1)
	 print("rate " .. v .. " = " .. rate[v])
	 e.rate(i, rate[i])
      end, 1.0)
      rate_m:start()

      
      -----------
      -- enabling this stuff seems to cause the crash??
      --[[
      -- show phase...
      local phase_poll = {}
      for i=1,4 do
	 phase_poll[i] = poll.set("phase_quant_"..i, function(x) phase[i] = x end)
	 phase_poll[i]:start()
      end
      --]]
   end   
end

local phase = {0, 0, 0, 0 }	       
-- hm, redraw as a global is... weird. for one thing we cant see stuff in local scope
local my_redraw = function()   
   screen.clear()
   screen.level(15)
--   screen.font_face(1)
--   screen.font_size(12)
  
   for i=1,4 do
      screen.move(10, i * 12)
      screen.text("phase ".. i .. " = "  .. phase[i] )
   end
   
   screen.update()
end

-- set global redraw
function redraw()
   print("redraw!")
   my_redraw()
end
