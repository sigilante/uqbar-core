/-  seq=zig-sequencer
=,  dejs:format
|_  =sidecar-action:seq
++  grab
  |%
  ++  noun  sidecar-action:seq
  ++  json
    |=  jon=^json
    ^-  sidecar-action:seq
    =<  (process jon)
    |%
    ++  process
      %-  of
      :~  [%trigger-batch (ot ~[[%deposits (ar sa)]])]
          [%batch-posted (ot ~[[%town-root (su ;~(pfix (jest '0x') hex))] [%block-at (su dem)]])]
          [%batch-rejected (ot ~[[%town-root (su ;~(pfix (jest '0x') hex))]])]
      ==
    --
  --
::
++  grow
  |%
  ++  noun  sidecar-action
  --
::
++  grad  %noun
::
--
