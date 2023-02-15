/-  seq=zig-sequencer
=,  dejs:format
|_  =town-action:seq
++  grab
  |%
  ++  noun  town-action:seq
  ++  json
    |=  jon=^json
    ^-  town-action:seq
    =<  (process jon)
    |%
    ++  process  ::  ONLY HANDLING %deposit POKES!!
      %-  of
      :~  [%deposit (ot ~[[%hash (se %ux)] [%deposit-bytes (se %ux)]])]
      ==
    --
  --
::
++  grow
  |%
  ++  noun  town-action
  --
::
++  grad  %noun
::
--
