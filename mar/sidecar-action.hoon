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
      :~  [%trigger-batch (ot ~[[%deposits (ar parse-deposit)]])]
          [%batch-rejected (ot ~[[%town-root (su ;~(pfix (jest '0x') hex))]])]
          :-  %batch-posted
          %-  ot
          :~  [%town-root (su ;~(pfix (jest '0x') hex))]
              [%state-root (su ;~(pfix (jest '0x') hex))]
              [%block-at (su dem)]
          ==
      ==
    ++  parse-deposit
      %-  ot
      :~  [%bytes sa]
          :-  %metadata
          %-  of
          :~  [%eth (ot ~[[%decimals ni]])]
              [%erc20 (ot ~[[%name so] [%symbol so] [%decimals ni]])]
              [%erc721 (ot ~[[%name so] [%symbol so] [%'tokenURI' so]])]
      ==  ==
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
