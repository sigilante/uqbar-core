/-  *zig-sequencer, w=zig-wallet
|%
++  parse-deposit-bytes
  |=  =byts
  ^-  deposit
  =+  (rev 3 byts)
  :*  town-id=(rev 3 32 (end [3 32] -))
      deposit-index=(rev 3 32 (cut 3 [32 32] -))
      token=(rev 3 32 (cut 3 [64 32] -))
      destination-address=(rev 3 32 (cut 3 [96 32] -))
      amount=(rev 3 32 (cut 3 [128 32] -))
      block-number=(rev 3 32 (cut 3 [160 32] -))
  ==
::
++  transition-state
  |=  $:  old=town
          proposed=proposed-batch
      ==
  ^-  town
  %=  old
    batch-num.hall         num.proposed
    chain                  chain.proposed
    latest-diff-hash.hall  diff-hash.proposed
    roots.hall             (snoc roots.hall.old root.proposed)
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
--
