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
          [%batch-posted (ot ~[[%town-root (se %ux)] [%block-at (se %ud)]])]
          [%batch-rejected (ot ~[[%town-root (se %ux)]])]
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
