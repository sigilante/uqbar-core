/-  spider, wallet=zig-wallet, uqbar=zig-uqbar
/+  *strandio
=,  strand=strand:spider
=>
|%
++  take-update
  |=  to=@p
  =/  m  (strand ,(unit @ux))
  ^-  form:m
  ;<  =cage  bind:m  (take-fact /thread-watch)
  =/  [from=@p share=share-address:uqbar]
    !<([@p share-address:uqbar] q.cage)
  ?.  ?&  ?=(%share -.share)
          =(to from)
      ==
    ::  failed  ! surface this somehow
    (pure:m ~)
  (pure:m `address.share)
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
;<  ~  bind:m  (watch-our /thread-watch %wallet /token-send-updates)
::  next, poke wallet of ship we want address for
::
;<  ~  bind:m
  %-  send-raw-card
  :*  %pass   /uqbar-address-from-ship
      %agent  [ship.act %wallet]
      %poke   uqbar-share-address+!>([%request %wallet])
  ==
::  set timer so that if we don't hear back from ship in 2 minutes,
::  we cancel the token send
;<  now=@da  bind:m  get-time
::  take fact from wallet with result of poke
::
;<  address=(unit @ux)  bind:m  (take-update ship.act)
?~  address  !!
::  if it's too late, don't send anymore
;<  later=@da  bind:m  get-time
?:  (gth (sub later now) ~m5)  !!
;<  our=@p  bind:m  get-our
::  poke wallet with transaction
::
;<  ~  bind:m
  %-  send-raw-card
  :*  %pass   /uqbar-address-from-ship
      %agent  [our %wallet]
      %poke   %wallet-poke
      !>  ^-  wallet-poke:wallet
      :*  %transaction  origin.act
          from.act  contract.act  town.act
          ?+  -.action.act  action.act
            %give      action.act(to u.address)
            %give-nft  action.act(to u.address)
      ==  ==
  ==
::
(pure:m !>(~))