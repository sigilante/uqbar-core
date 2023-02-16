/-  *zig-sequencer, w=zig-wallet
|%
++  parse-deposit-bytes
  |=  bytes=@
  ^-  deposit
  :*  token=(cut 3 [160 32] bytes)
      destination-address=(cut 3 [128 32] bytes)
      amount=(cut 3 [96 32] bytes)
      deposit-index=(cut 3 [64 32] bytes)
      block-number=(cut 3 [32 32] bytes)
      message-hash=(end [3 32] bytes)
  ==
::
++  transition-state
  |=  [old=(unit town) proposed=[num=@ud =processed-txs =chain diff-hash=@ux root=@ux]]
  ^-  (unit town)
  ?~  old  old
  :-  ~
  %=  u.old
    batch-num.hall         num.proposed
    chain                  chain.proposed
    latest-diff-hash.hall  diff-hash.proposed
    roots.hall             (snoc roots.hall.u.old root.proposed)
  ==
::
++  get-our-caller
  |=  [addr=@ux town=@ux our=@p now=@da]
  ^-  caller:smart
  =/  =wallet-update:w
    .^  wallet-update:w  %gx
        %+  weld  /(scot %p our)/wallet/(scot %da now)
        /account/(scot %ux addr)/(scot %ux town)/noun
    ==
  ?>  ?=(%account -.wallet-update)
  caller.wallet-update
::
++  read-item
  |=  [=path =state]
  ^-  (unit (unit cage))
  ?>  ?=([%grain @ ~] path)
  =/  id  (slav %ux i.t.path)
  ``noun+!>((get:big state id))
--
