engine.name = 'TrigStress'

init = function() 
    local handle_trig = function(i, x)
        print(i, x)
    end 


    local phase_poll = {}
    for i=1,4 do

        params:add{type = "number", id = "trig_hz_"..i, name = "Trigger Rate "..i, min = 1, max = 500, default = 5, action = function(value)
            engine.trig_hz(i, value)    
          end}

        phase_poll[i] = poll.set("trig_"..i, function(x) handle_trig(i, x) end)
        phase_poll[i]:start()
    end
    
      
end 
