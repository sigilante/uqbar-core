/=  zigs  /con/lib/zigs
|_  [label=@tas n=noun]
++  data
  |%
  ++  noun
    ?+  label  !!
      %account   ;;(account:sur:zigs n)
      %metadata  ;;(token-metadata:sur:zigs n)
    ==
  ++  json
    ^-  ^json
    ?+    label  !!
        %account
      =+  ;;(account:sur:zigs n)
      %-  pairs:enjs:format
      :~  ['balance' s+(scot %ud balance.-)]
          ['metadata' s+(scot %ux metadata.-)]
      ==
    ::
        %metadata
      =/  m  ;;(token-metadata:sur:zigs n)
      %-  pairs:enjs:format
      :~  ['name' s+name.m]
          ['symbol' s+symbol.m]
          ['supply' s+(scot %ud supply.m)]
          ['mintable' b+mintable.m]
          ['deployer' s+(scot %ux deployer.m)]
          ['salt' s+(scot %ud salt.m)]
      ==
    ==
  --
::
++  action
  |%
  ++  noun
    ;;(action:sur:zigs n)
  ++  json  !!
  --
::
++  event
  |%
  ++  noun  !!
  ++  json  !!
  --
--