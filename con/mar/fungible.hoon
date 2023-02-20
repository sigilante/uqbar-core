/+  *zig-sys-smart
/=  fungible  /con/lib/fungible
|_  [label=@tas n=noun]
++  data
  |%
  ++  noun
    ?+  label  !!
      %account   ;;(account:sur:fungible n)
      %metadata  ;;(token-metadata:sur:fungible n)
    ==
  ++  json
    ^-  ^json
    ?+    label  !!
        %account
      =+  ;;(account:sur:fungible n)
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
      =/  m  ;;(token-metadata:sur:fungible n)
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
    ;;(action:sur:fungible [label n])
  ++  json
    =/  act  ;;(action:sur:fungible [label n])
    ?-    -.act
        %give
      %+  frond:enjs:format  'give'
      %-  pairs:enjs:format
      :~  ['to' s+(scot %ux to.act)]
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
        %mint
      %+  frond:enjs:format  'mint'
      %-  pairs:enjs:format
      :~  ['token-metadata' s+(scot %ux token-metadata.act)]
          :-  'mints'
          %-  pairs:enjs:format
          %+  turn  mints.act
          |=  [to=address amount=@ud]
          [(scot %ux to) s+(scot %ud amount)]
      ==
    ::
        %deploy
      %+  frond:enjs:format  'deploy'
      %-  pairs:enjs:format
      :~  ['name' s+name.act]
          ['symbol' s+symbol.act]
          ['salt' s+(scot %ud salt.act)]
          ['cap' ?~(cap.act ~ s+(scot %ud u.cap.act))]
          :-  'minters'
          :-  %a
          (turn ~(tap pn minters.act) |=(a=@ux s+(scot %ux a)))
          :-  'initial-distribution'
          %-  pairs:enjs:format
          %+  turn  initial-distribution.act
          |=  [to=address amount=@ud]
          [(scot %ux to) s+(scot %ud amount)]
      ==
    ==
  --
::
::  ++  event
::    |%
::    ++  noun  !!
::    ++  json  !!
::    --
--