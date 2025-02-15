/-  *zig-wallet
=,  dejs:format
|_  act=wallet-poke
++  grab
  |%
  ++  noun  wallet-poke
  ++  json
    |=  jon=^json
    ^-  wallet-poke
    %-  wallet-poke
    |^
    =/  procd  (process jon)
    ?.  ?=(?(%transaction %unsigned-transaction) -.procd)  procd
    [-.procd origin=~ +.procd]
    ++  process
      %-  of
      :~  [%import-seed (ot ~[[%mnemonic so] [%password so] [%nick so]])]
          [%generate-hot-wallet (ot ~[[%password so] [%nick so]])]
          [%store-hot-wallet (ot ~[[%nick so] [%address (se %ux)] [%priv so] [%seed so]])]
          [%derive-new-address (ot ~[[%hdpath sa] [%nick so]])]
          [%delete-address (ot ~[[%address (se %ux)]])]
          [%edit-nickname (ot ~[[%address (se %ux)] [%nick so]])]
          [%realign-nonce (ot ~[[%address (se %ux)] [%town (se %ux)]])]
          [%add-tracked-address (ot ~[[%address (se %ux)] [%nick so]])]
          ::
          [%submit-signed parse-signed]
          [%submit parse-submit]
          [%delete-pending parse-delete]
          [%transaction parse-transaction]
          [%unsigned-transaction parse-unsigned]
          [%submit-typed-message parse-typed]
          [%delete-typed-message (ot ~[[%hash (se %ux)]])]
      ==
    ++  parse-signed
      %-  ot
      :~  [%from (se %ux)]
          [%hash (se %ux)]
          [%eth-hash (se %ux)]
          [%sig (ot ~[[%v ni] [%r (se %ux)] [%s (se %ux)]])]
          [%gas (ot ~[[%rate ni] [%bud ni]])]
      ==
    ++  parse-submit
      %-  ot
      :~  [%from (se %ux)]
          [%hash (se %ux)]
          [%gas (ot ~[[%rate ni] [%bud ni]])]
      ==
    ++  parse-delete
      %-  ot
      :~  [%from (se %ux)]
          [%hash (se %ux)]
      ==
    ++  parse-unsigned
      %-  ot
      :~  [%contract (se %ux)]
          [%town (se %ux)]
          [%action (of ~[[%text so]])]
      ==
    ++  parse-typed
      %-  ot
      :~  [%hash (se %ux)]
          [%from (se %ux)]
          [%sig (ot ~[[%v ni] [%r (se %ux)] [%s (se %ux)]])]
      ==
    ++  parse-transaction
      %-  ot
      :~  [%from (se %ux)]
          [%contract (se %ux)]
          [%town (se %ux)]
          [%action parse-action]
      ==
    ++  parse-action
      %-  of
      :~  [%give parse-give]
          [%give-nft parse-nft]
          [%text so]
      ==
    ++  parse-give
      %-  ot
      :~  [%to (se %ux)]
          [%amount ni]
          [%item (se %ux)]
      ==
    ++  parse-nft
      %-  ot
      :~  [%to (se %ux)]
          [%item (se %ux)]
      ==
    ++  se-soft
      |=  aur=@tas
      |=  jon=^json
      ?>(?=([%s *] jon) (slaw aur p.jon))
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
