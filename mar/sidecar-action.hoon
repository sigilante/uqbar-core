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
      :~  [%batch-posted (ot ~[[%town-root (se %ux)]])]
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
