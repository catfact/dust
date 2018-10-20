Engine_TrigStress : CroneEngine { 
    var syn;
    var osc;
    var poll;
    classvar num = 4;

    *new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	*initClass {
		StartUp.add {
			CroneDefs.add(
				// send trigger when quantized KR signal changes
				SynthDef.new(\quant_trig,  {
					arg in, quant=48000, offset=0, id=0;
					var sgl, tr;
					//sgl = In.kr(in).round(quant);
					sgl = ((In.kr(in)+offset) / quant).floor * quant;
					tr = Changed.kr(sgl);
					SendTrig.kr(tr, id, sgl);
				});
			);
		}

	}

	alloc {
        var s = context.server;

        SynthDef.new(\trig_sine, { 
            arg out=0, amp=0.1, id=0, trig_hz = 5, hz_mul=100, hz_add = 200, smooth_factor=0.2;
            var noise, trig, hz, hz_smooth, snd;
            noise = WhiteNoise.kr;
            trig = Impulse.kr(trig_hz);
            hz = Latch.kr(noise, trig) * hz_mul + hz_add;
            hz_smooth = Lag.ar(K2A.ar(hz), trig_hz.reciprocal * smooth_factor);
            snd = SinOsc.ar(hz_smooth) * amp;
            SendTrig.kr(trig, id, noise);
            Out.ar(out, snd);
        }).send(s);

        s.sync;


        syn = Array.fill(num, { |i| 
            Synth.new(\trig_sine, [\out, context.out_b.index + (i%2), \id, i], s);
        });

        osc = OSCFunc({ arg msg, time;
            var id = msg[2];
            var val = msg[3];
            poll[id].update(val);
            // [time, msg].postln;
        },'/tr', s.addr);

        poll = Array.fill(num, { |i| 
			this.addPoll("trig_" ++ (i+1), periodic:false);
		});

        this.addCommand(\trig_hz, \if, { |msg| syn[msg[1]-1].set(\trig_hz, msg[2]); });
        this.addCommand(\hz_mul, \if, { |msg| syn[msg[1]-1].set(\hz_mul, msg[2]); });
        this.addCommand(\hz_add, \if, { |msg| syn[msg[1]-1].set(\hz_add, msg[2]); });
    }

    free  {
        syn.do({|sn| sn.free; });
        osc.free;
    }
}
