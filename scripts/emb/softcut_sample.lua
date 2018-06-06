--- softcut-sample
---
--- simple demonstration: play sample and randomly change rate


-- if the script sets this global variable,
-- norns will attempt to load the requested engine when launching the script.
-- 'SoftCut' is a polyphonic, tape-like record system with crossfading, used in MLR.

engine.name = 'SoftCut'

-- if the script sets this variable to a function, it will be executed when the engine is done loading.
function init()
   print("softcut_sample init")

   -- the global table 'engine' should now be populated with a lot of function-type fields,
   -- corresponding to "commands" declared in the engine's SC class.
   -- these should be printed in the REPL output at this point.

   -- in SoftCut, all the voices share one large audio buffer.
   -- by default, they are assigned to read and write from adjacent regions.
   -- the "read" function loads a soundfile into the buffer,
   -- specifying a destination start and end point.
   -- this will load 4 seconds of the given soundfile into the top of the buffer
   engine.read("/home/we/dust/audio/tehn/whirl1.aif", 0.0, 4.0)
   -- set the voice 1 loop points to (1s, 2s), allowing post-roll for crossfading.
   engine.loop_start(1, 1)
   engine.loop_end(1, 3)
   -- enable looping
   engine.loop_on(1, 1)

   -- set voice 1 to both output channels and turn it up

   engine.play_dac(1, 1, 1.0)
   engine.play_dac(1, 2, 1.0)
   engine.amp(1, 1.0)
   
   -- no rate lag
   engine.rate_lag(1, 0.0)
   
   -- start voice 1 playing
   engine.start(1)
   -- explicitly tell it to jump to the start of the buffer
   -- this requires two commands"
   -- 1. set the position
   engine.pos(1, 0)
   -- 2. jump to the position
   engine.reset(1)

   -- the "metro" class provides high-resolution timers that we can use for sequencing

   -- here we request a metro object,
   -- and assign a callback for it by passing a function as the first argument.
   -- in our callback, we'll set playback to a random rate.
   local random_rate = function()
      -- new rate will be a just-intoned interval using two random integers from 1 to 8
      local num = math.floor(math.random() * 7 + 1)
      local denom = math.floor(math.random() * 7 + 1)
      local rate = num / denom
      -- toss a coin for negative rate
      if math.random() > 0.5 then rate = rate * -1 end
      engine.rate(1, rate)	   
      print((function() if rate < 0 then return "-" else return "" end end)() .. num .. "/" .. denom)
   end
   
   local seq = metro.alloc(random_rate)

   -- set the callback period of the sequence
   seq.time = 0.5
   -- note the ":" notation, which is a _method call_ in lua.
   -- this starts the sequencer
   seq:start()
end
