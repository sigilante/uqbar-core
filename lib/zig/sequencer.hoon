/-  *zig-sequencer, w=zig-wallet
/+  merk
|%
++  deposit-from-tape
  |=  [=tape =deposit-metadata]
  ^-  deposit
  ::  TODO this format will probably change
  =+  %+  rev  3
      [224 (scan `^tape`(slag 2 tape) hex)]
  :*  (rev 3 32 (end [3 32] -))      ::  town-id
      (rev 3 32 (cut 3 [32 32] -))   ::  token-contract
      (rev 3 32 (cut 3 [64 32] -))   ::  token-id (only for NFTs)
      (rev 3 32 (cut 3 [96 32] -))   ::  destination-address
      (rev 3 32 (cut 3 [128 32] -))  ::  amount
      (rev 3 32 (cut 3 [160 32] -))  ::  block-number
      (rev 3 32 (cut 3 [192 32] -))  ::  previous deposit root
      deposit-metadata
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
::
::  take a new town-root and insert into chain state
::
++  inject-town-root
  |=  [=chain new-root=@ux]
  ^+  chain
  ?~  item=(get:big p.chain `@ux`'town-roots')
    chain
  ?.  ?=(%& -.u.item)  chain
  =.  noun.p.u.item
    ?.  ?=([current=@ux past=@ux] noun.p.u.item)
      ::  this is the very first posting
      [new-root (shag:merk new-root)]
    [new-root (shag:merk current.noun.p.u.item^past.noun.p.u.item)]
  (put:big p.chain `@ux`'town-roots' u.item)^q.chain
--
