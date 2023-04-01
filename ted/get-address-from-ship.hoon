/-  spider, wallet=zig-wallet, uqbar=zig-uqbar
/+  *strandio
=,  strand=strand:spider
=>
|%
++  take-update
  =/  m  (strand ,(unit @ux))
  ^-  form:m
  ;<  =cage  bind:m  (take-fact /thread-watch)
  =/  share=share-address:uqbar  !<(share-address:uqbar q.cage)
  ?.  ?=(%share -.share)
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
::  take fact from wallet with result of poke
::
;<  address=(unit @ux)  bind:m  take-update
?~  address
  (pure:m !>(~))
;<  our=@p              bind:m  get-our
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