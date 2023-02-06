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
    ;;(action:lib n)
  ++  json
    ^-  ^json
    ?+    label  !!
        %deploy
      =+  ;;(action:lib n)
      ?>  ?=(%deploy -.-)
      %+  frond:enjs:format  'deploy'
      %-  pairs:enjs:format
      :~  ['mutable' b+mutable.-]
          ::  we don't JSONify the actual nock
          ['interface' s+(spat (pout interface.-))]
      ==
    ::
        %deploy-and-init
      =+  ;;(action:lib n)
      ?>  ?=(%deploy-and-init -.-)
      %+  frond:enjs:format  'deploy-and-init'
      %-  pairs:enjs:format
      :~  ['mutable' b+mutable.-]
          ::  we don't JSONify the actual nock
          ['interface' s+(spat (pout interface.-))]
          ['init' s+(scot %tas -.init.-)]
      ==
    ::
        %upgrade
      =+  ;;(action:lib n)
      ?>  ?=(%upgrade -.-)
      %+  frond:enjs:format  'upgrade'
      %-  pairs:enjs:format
      :~  ['to_upgrade' s+(scot %ux to-upgrade.-)]
          ['new_interface' s+(spat (pout new-interface.-))]
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
  ++  noun  ;;(event-type n)
  ++  json
    ^-  ^json
    ?+    label  !!
        %deploy
      =+  ;;(event-type n)
      ?>  ?=(%deploy -.-)
      %+  frond:enjs:format  'deploy'
      %-  pairs:enjs:format
      :~  ['contract' s+(scot %ux contract.-)]
          ['deployer' s+(scot %ux deployer.-)]
          ['mutable' b+mutable.-]
      ==
    ::
        %upgrade
      =+  ;;(event-type n)
      ?>  ?=(%upgrade -.-)
      %+  frond:enjs:format  'upgrade'
      %-  pairs:enjs:format
      :~  ['contract' s+(scot %ux contract.-)]
      ==
    ==
  --
--