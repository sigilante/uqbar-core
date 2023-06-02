/-  seq=zig-sequencer
/+  default-agent, dbug, verb, io=agentio
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      active=?
      interval=@dr
  ==
--
::
::  This agent allows you to set an interval at which your sequencer app should produce a batch.
::
::  To start, poke with (unit) interval timing:
::  :batcher-interval `~s30
::
::  To stop, poke with empty unit:
::  :batcher-interval ~
::
::
=|  state-0
=*  state  -
%-  agent:dbug
::  %+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ~|  "%batcher: wasn't poked with valid @dr"
  =/  new-interval  !<((unit @dr) vase)
  ?~  new-interval
    ~&  >>>  "%batcher inactive"
    `this(active %.n)
  ~&  >  "%batcher set at {<now.bowl>} with batching interval {<new-interval>}"
  =/  wait  (add now.bowl u.new-interval)
  :_  this(interval u.new-interval, active %.y)
  [%pass /batch-timer %arvo %b %wait wait]~
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?>  ?=([%batch-timer ~] wire)
  ?.  active  `this
  =/  wait  (add now.bowl interval)
  =/  tid  `@ta`(cat 3 'make-batch' (scot %uv (sham eny.bowl)))
  :_  this
  :~  [%pass /batch-timer %arvo %b %wait wait]
      :*  %pass   /make-batch/(scot %da now.bowl)
          %agent  [our.bowl %spider]
          %poke   %spider-start
          !>  :^  ~  `(scot %uv (sham eny.bowl))
                byk.bowl(r da+now.bowl)
              batch+!>(~)
      ==
  ==
::
++  on-init   `this(state [%0 %.n ~m1])
++  on-save   !>(state)
++  on-load
  |=  =old=vase
  `this(state !<(state-0 old-vase))
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
