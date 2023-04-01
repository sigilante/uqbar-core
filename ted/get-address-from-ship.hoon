/-  spider, wallet=zig-wallet, uqbar=zig-uqbar
/+  *strandio
=,  strand=strand:spider
=>
|%
++  take-update
  =/  m  (strand ,@ux)
  ^-  form:m
  ;<  =cage  bind:m  (take-fact /thread-watch)
  =/  share=share-address:uqbar  !<(share-address:uqbar q.cage)
  ?.  ?=(%share -.share)
    ::  failed  ! surface this somehow
    !!
  (pure:m address.share)
--
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
=/  act  !<(wallet-poke:wallet arg)
?.  ?=(%transaction-to-ship -.act)  (pure:m !>(~))
^-  form:m
::  first, watch updates from wallet
::
;<  ~  bind:m  (watch-our /thread-watch %wallet /address-get-updates)
::  next, poke wallet of ship we want address for
::
;<  ~  bind:m
  %-  send-raw-card
  :*  %pass   /uqbar-address-from-ship
      %agent  [ship.act %wallet]
      %poke   uqbar-share-address+!>([%request %wallet])
  ==
::  take fact from wallet with result of poke
::
;<  address=@ux  bind:m  take-update
;<  our=@p       bind:m  get-our
::  poke wallet with transaction
::
;<  ~  bind:m
  %-  send-raw-card
  :*  %pass   /uqbar-address-from-ship
      %agent  [our %wallet]
      %poke   %wallet-poke
      !>  ^-  wallet-poke:wallet
      %=  act
        ship  ~
          action
        ?+  -.action.act  action.act
          %give      action.act(to address)
          %give-nft  action.act(to address)
        ==
      ==
  ==
::
(pure:m !>(~))