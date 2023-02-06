/+  *zig-sys-smart
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
          :-  'allowances'
          %-  pairs:enjs:format
          %+  turn  ~(tap py allowances.-)
          |=  [=address amt=@ud]
          [(scot %ux address) s+(scot %ud amt)]
          :-  'nonces'
          %-  pairs:enjs:format
          %+  turn  ~(tap py nonces.-)
          |=  [=address nonce=@ud]
          [(scot %ux address) s+(scot %ud nonce)]
      ==
    ::
        %metadata
      =/  m  ;;(token-metadata:sur:zigs n)
      %-  pairs:enjs:format
      :~  ['name' s+name.m]
          ['symbol' s+symbol.m]
          ['decimals' s+(scot %ud decimals.m)]
          ['supply' s+(scot %ud supply.m)]
          ['cap' ~]
          ['mintable' b+mintable.m]
          ['minters' ~]
          ['deployer' s+(scot %ux deployer.m)]
          ['salt' s+(scot %ud salt.m)]
      ==
    ==
  --
::
++  action
  |%
  ++  noun
    ;;(action:sur:zigs [label n])
  ++  json
    =/  act  ;;(action:sur:zigs [label n])
    ?-    -.act
        %give
      %+  frond:enjs:format  'give'
      %-  pairs:enjs:format
      :~  ['budget' s+(scot %ud budget.act)]
          ['to' s+(scot %ux to.act)]
          ['amount' s+(scot %ud amount.act)]
          ['from-account' s+(scot %ux from-account.act)]
      ==
    ::
        %take
      %+  frond:enjs:format  'take'
      %-  pairs:enjs:format
      :~  ['to' s+(scot %ux to.act)]
          ['amount' s+(scot %ud amount.act)]
          ['from-account' s+(scot %ux from-account.act)]
      ==
    ::
        %push
      %+  frond:enjs:format  'push'
      %-  pairs:enjs:format
      :~  ['to' s+(scot %ux to.act)]
          ['amount' s+(scot %ud amount.act)]
          ['from-account' s+(scot %ux from-account.act)]
          ['calldata' s+(crip (text !>(calldata.act)))]
      ==
    ::
        %pull
      %+  frond:enjs:format  'pull'
      %-  pairs:enjs:format
      :~  ['from' s+(scot %ux from.act)]
          ['to' s+(scot %ux to.act)]
          ['amount' s+(scot %ud amount.act)]
          ['from-account' s+(scot %ux from-account.act)]
          ['nonce' s+(scot %ud nonce.act)]
          ['deadline' s+(scot %ud deadline.act)]
          ['sig' s+(crip (text !>(sig.act)))]
      ==
    ::
        %set-allowance
      %+  frond:enjs:format  'set-allowance'
      %-  pairs:enjs:format
      :~  ['who' s+(scot %ux who.act)]
          ['amount' s+(scot %ud amount.act)]
          ['account' s+(scot %ux account.act)]
      ==
    ::
    ==
  --
::
::  ++  event
::    |%
::    ++  noun  !!
::    ++  json  !!
::    --
--