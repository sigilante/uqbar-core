/+  *zig-sys-smart
/=  lib  /con/lib/publish
|_  [label=@tas n=noun]
++  data
  ::  publish contract does not produce any data
  !!
::
++  action
  |%
  ++  noun
    ;;(action:lib [label n])
  ++  json
    ^-  ^json
    =/  act  ;;(action:lib [label n])
    ?-    -.act
        %deploy
      %+  frond:enjs:format  'deploy'
      %-  pairs:enjs:format
      :~  ['mutable' b+mutable.act]
          ::  we don't JSONify the actual nock
          ['interface' s+(spat (pout interface.act))]
      ==
    ::
        %deploy-and-init
      %+  frond:enjs:format  'deploy-and-init'
      %-  pairs:enjs:format
      :~  ['mutable' b+mutable.act]
          ::  we don't JSONify the actual nock
          ['interface' s+(spat (pout interface.act))]
          ['init' s+(scot %tas -.init.act)]
      ==
    ::
        %upgrade
      %+  frond:enjs:format  'upgrade'
      %-  pairs:enjs:format
      :~  ['to_upgrade' s+(scot %ux to-upgrade.act)]
          ['new_interface' s+(spat (pout new-interface.act))]
      ==
    ==
  --
::
++  event
  |%
  +$  event-type
    $%  [%deploy contract=id deployer=address mutable=?]
        [%upgrade contract=id]
    ==
  ++  noun  ;;(event-type [label n])
  ++  json
    ^-  ^json
    ?+    label  !!
        %deploy
      =+  ;;(event-type [label n])
      ?>  ?=(%deploy -.-)
      %+  frond:enjs:format  'deploy'
      %-  pairs:enjs:format
      :~  ['contract' s+(scot %ux contract.-)]
          ['deployer' s+(scot %ux deployer.-)]
          ['mutable' b+mutable.-]
      ==
    ::
        %upgrade
      =+  ;;(event-type [label n])
      ?>  ?=(%upgrade -.-)
      %+  frond:enjs:format  'upgrade'
      %-  pairs:enjs:format
      :~  ['contract' s+(scot %ux contract.-)]
      ==
    ==
  --
--