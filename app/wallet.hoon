::  wallet [UQ| DAO]
::
::  UQ| wallet agent. Stores private key and facilitates signing
::  transactions, holding nonce values, and keeping track of owned data.
::
/-  *zig-wallet, ui=zig-indexer
/+  default-agent, dbug, verb, io=agentio,
    ethereum, bip32, bip39, engine=zig-sys-engine,
    ui-lib=zig-indexer, zink=zink-zink,
    *zig-wallet, smart=zig-sys-smart
/*  smart-lib  %noun  /lib/zig/sys/smart-lib/noun
|%
+$  card  card:agent:gall
+$  state-2
  $:  %2
      ::  wallet holds a single seed at once
      ::  address-index notes where we are in derivation path
      seed=[mnem=@t pass=@t address-index=@ud]
      ::  many keys can be derived or imported
      ::  if the private key is ~, that means it's a hardware wallet import
      keys=(map address:smart [priv=(unit @ux) nick=@t])
      ::  we track the nonce of each address we're handling
      ::  TODO: introduce a poke to check nonce from chain and re-align
      nonces=(map address:smart (map town=@ux nonce=@ud))
      ::  signatures tracks any signed calls we've made
      =signed-message-store
      ::  tokens tracked for each address we're handling
      tokens=(map address:smart =book)
      ::  metadata for tokens we track
      =metadata-store
      ::  origins we automatically sign and approve txns from
      approved-origins=(map (pair term wire) [rate=@ud bud=@ud])
      ::  transactions we've sent that haven't been finalized by sequencer
      =unfinished-transaction-store
      ::  finished transactions we've sent
      =transaction-store
      ::  transactions we've been asked to sign, keyed by hash
      =pending-store
  ==
+$  state-3
  $:  %3
      ::  wallet holds a single seed at once
      ::  address-index notes where we are in derivation path
      seed=[mnem=@t pass=@t address-index=@ud]
      ::  many keys can be derived or imported
      ::  if the private key is ~, that means it's a hardware wallet import
      keys=(map address:smart [priv=(unit @ux) nick=@t])
      =share-prefs
      ::  we track the nonce of each address we're handling
      ::  TODO: introduce a poke to check nonce from chain and re-align
      nonces=(map address:smart (map town=@ux nonce=@ud))
      ::  signatures tracks any signed calls we've made
      =signed-message-store
      ::  tokens tracked for each address we're handling
      tokens=(map address:smart =book)
      ::  metadata for tokens we track
      =metadata-store
      ::  origins we automatically sign and approve txns from
      approved-origins=(map (pair term wire) [rate=@ud bud=@ud])
      ::  transactions we've sent that haven't been finalized by sequencer
      =unfinished-transaction-store
      ::  finished transactions we've sent
      =transaction-store
      ::  transactions we've been asked to sign, keyed by hash
      =pending-store
  ==
--
::
=|  state-3
=*  state  -
::
%-  agent:dbug
::  %+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this(state *state-3)
  ::  auto-populate %wallet with a random seed on install
  :_  ~
  :*  %pass  /self-poke
      %agent  [our.bowl %wallet]
      %poke  %wallet-poke
      !>([%generate-hot-wallet '' 'wallet'])
  ==
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ?+    -.q.old-vase  on-init
      %3
    `this(state !<(state-3 old-vase))
      %2
    =+  old=!<(state-2 old-vase)
    =+  new=[%3 -.+.old -.+.+.old *^share-prefs +.+.+.old]
    `this(state `state-3`new)
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+    path  !!
      [%book-updates ~]
    ::  send frontend updates along this path
    :_  this
    =-  ~[[%give %fact ~ %wallet-frontend-update -]]
    !>(`wallet-frontend-update`[%new-book tokens.state])
  ::
      [%metadata-updates ~]
    ::  send frontend updates along this path
    :_  this
    =-  ~[[%give %fact ~ %wallet-frontend-update -]]
    !>(`wallet-frontend-update`[%new-metadata metadata-store.state])
  ::
      [%tx-updates ~]
    ::  provide updates about submitted transactions
    ::  any local app can watch this to send things through
    `this
  ::
      [%token-send-updates ~]
    ::  for a thread
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %wallet-poke
    =^  cards  state
      (poke-wallet !<(wallet-poke vase))
    [cards this]
  ::
      %uqbar-share-address
    ::  share an address with another ship, depending on preferences
    ::
    =/  action=share-address:uqbar  !<(share-address:uqbar vase)
    :_  this  :_  ~
    ?.  ?=(%request -.action)
      ::  give to thread
      %+  fact:io
        wallet-thread-update+!>([src.bowl action])
      ~[/token-send-updates]
    %+  ~(poke pass:io /share-address-reply)
      [src.bowl app.action]
    :-  %uqbar-share-address
    !>  ^-  share-address:uqbar
    ?-    -.share-prefs
      %none  [%deny ~]
      %one   [%share +.share-prefs]
      %any   ?~(keys [%deny ~] [%share p.n.keys])
    ==
  ::
      %uqbar-write-result
    ?>  =(src our):bowl
    =/  result  !<(write-result:uqbar vase)
    =/  tx-hash  p.result
    ?~  found=(~(get by unfinished-transaction-store) tx-hash)
      ::  this is a receipt forwarded to us: use it to update our token
      ::  store. the receipt was validated in %uqbar and sent to %wallet
      ?.  ?=(%receipt -.q.result)  `this
      =+  (integrate-output tokens output.q.result)
      :_  this(tokens -)
      (fact:io wallet-frontend-update+!>([%new-book -]) ~[/book-updates])^~
    =*  tx  u.found
    =^  cards  tx
      ?-    -.q.result
          %sent
        ~&  "%wallet: tx sent"
        ::  status code 101
        `tx(status.transaction %101)
          %delivered
        ~&  "%wallet: tx delivered"
        ::  status code 102
        `tx(status.transaction %102)
          %rejected
        ~&  "%wallet: tx rejected"
        ::  status code 103
        `tx(status.transaction %103)
          %receipt
        :_  tx(status.transaction (add 200 status.transaction.+.q.result))
        ?~  origin.u.found  ~
        :_  ~
        %+  ~(poke pass:io /receipt)
          [our.bowl p.u.origin.u.found]
        :-  %wallet-update
        !>(`wallet-update`[%sequencer-receipt origin.u.found p.result +.q.result])
      ==
    =^  cards  tokens
      ?.  ?=(%receipt -.q.result)  [cards tokens]
      ::  update our assets based on output of transaction
      =+  (integrate-output tokens output.q.result)
      :_  -
      (fact:io wallet-frontend-update+!>([%new-book -]) ~[/book-updates])^cards
    :-  (tx-update-card tx-hash transaction.tx action.tx)^cards
    %=    this
        unfinished-transaction-store
      %+  ~(put by unfinished-transaction-store)
        tx-hash
      ?.  ?=(%receipt -.q.result)  tx
      tx(output `output.q.result)
    ::
        nonces
      ?.  =(status.transaction.tx %103)  nonces
      ::  dec nonce on this town, tx was rejected
      %+  ~(put by nonces)  address.caller.transaction.tx
      %+  ~(jab by (~(got by nonces) address.caller.transaction.tx))
        town.transaction.tx
      |=(n=@ud (dec n))
    ==
  ==
  ::
  ++  poke-wallet
    |=  act=wallet-poke
    ^-  (quip card _state)
    ?>  =(src our):bowl
    ?-    -.act
        %import-seed
      ::  will lose seed in current wallet, should warn on frontend!
      ::  stores the default keypair in map
      ::  import takes in a seed phrase and password to encrypt with
      =+  seed=(to-seed:bip39 (trip mnemonic.act) (trip password.act))
      =+  core=(from-seed:bip32 [64 seed])
      =+  addr=(address-from-prv:key:ethereum private-key:core)
      ::  get transaction history for this new address
      =/  sent  (get-sent-history addr %.n [our now]:bowl)
      =/  tokens  (make-tokens ~[addr] [our now]:bowl)
      ::  sub to batch updates
      :-  (watch-for-batches our.bowl 0x0)  ::  TODO remove town-id hardcode
      ::  clear all existing state, except for
      ::  public keys imported from HW wallets
      ::  treat this as a nuke of the wallet
      %=  state
        pending-store         ~
        signed-message-store  ~
        tokens                tokens
        seed                  [mnemonic.act password.act 0]
        nonces                [[addr [[0x0 ~(wyt by sent)] ~ ~]] ~ ~]
        metadata-store        (update-metadata-store tokens ~ [our now]:bowl)
        unfinished-transaction-store  ~
        transaction-store  [[addr sent] ~ ~]
        keys  %+  ~(put by *(map address:smart [(unit @ux) @t]))
              addr  [`private-key:core nick.act]
      ==
    ::
        %generate-hot-wallet
      ::  will lose seed in current wallet, should warn on frontend!
      ::  creates a new wallet from entropy derived on-urbit
      =+  mnem=(from-entropy:bip39 [32 eny.bowl])
      =+  core=(from-seed:bip32 [64 (to-seed:bip39 mnem (trip password.act))])
      =+  addr=(address-from-prv:key:ethereum private-key:core)
      ::  get transaction history for this new address
      =/  sent  (get-sent-history addr %.n [our now]:bowl)
      =/  tokens  (make-tokens ~[addr] [our now]:bowl)
      ::  sub to batch updates
      :-  (watch-for-batches our.bowl 0x0)  ::  TODO remove town-id hardcode
      ::  clear all existing state, except for
      ::  public keys imported from HW wallets
      ::  treat this as a nuke of the wallet
      %=  state
        pending-store         ~
        signed-message-store  ~
        tokens                tokens
        seed                  [(crip mnem) password.act 0]
        nonces                [[addr [[0x0 ~(wyt by sent)] ~ ~]] ~ ~]
        metadata-store        (update-metadata-store tokens ~ [our now]:bowl)
        unfinished-transaction-store  ~
        transaction-store  [[addr sent] ~ ~]
        keys  %+  ~(put by *(map address:smart [(unit @ux) @t]))
              addr  [`private-key:core nick.act]
      ==
    ::
        %derive-new-address
      ::  if hdpath input is empty, use address-index+1 to get next
      =/  new-seed
        (to-seed:bip39 (trip mnem.seed.state) (trip pass.seed.state))
      =/  core
        %-  derive-path:(from-seed:bip32 [64 new-seed])
        ?:  !=("" hdpath.act)  hdpath.act
        (weld "m/44'/60'/0'/0/" (scow %ud address-index.seed.state))
      =+  addr=(address-from-prv:key:ethereum prv:core)
      ::  get transaction history for this new address
      =/  sent    (get-sent-history addr %.n [our now]:bowl)
      =/  tokens  (make-tokens [addr ~(tap in ~(key by keys))] [our now]:bowl)
      :-  ~
      %=  state
        tokens  tokens
        nonces  (~(put by nonces) addr [[0x0 ~(wyt by sent)] ~ ~])
        seed    seed(address-index +(address-index.seed))
        keys    (~(put by keys) addr [`prv:core nick.act])
        transaction-store  (~(put by transaction-store) addr sent)
      ==
    ::
        %add-tracked-address
      ::  get transaction history for this new address
      =/  sent  (get-sent-history address.act %.n [our now]:bowl)
      =/  tokens
        (make-tokens [address.act ~(tap in ~(key by keys))] [our now]:bowl)
      :-  ~
      %=  state
        tokens  tokens
        nonces  (~(put by nonces) address.act [[0x0 ~(wyt by sent)] ~ ~])
        keys    (~(put by keys) address.act [~ nick.act])
        transaction-store  (~(put by transaction-store) address.act sent)
      ==
    ::
        %set-share-prefs
      `state(share-prefs share-prefs.act)
    ::
        %delete-address
      ::  can recover by re-deriving same path
      :: :-  (clear-id-sub address.act our.bowl)
      :-  ~
      %=  state
        keys    (~(del by keys) address.act)
        nonces  (~(del by nonces) address.act)
        tokens  (~(del by tokens) address.act)
        transaction-store  (~(del by transaction-store) address.act)
      ==
    ::
        %edit-nickname
      =+  -:(~(got by keys.state) address.act)
      `state(keys (~(put by keys) address.act [- nick.act]))
    ::
        %sign-typed-message
      ::  TODO display something to the user using the contract interface
      =/  keypair  (~(got by keys.state) from.act)
      =/  =typed-message:smart  [domain.act `@ux`(sham type.act) msg.act]
      =/  hash  (sham typed-message)
      =/  signature
        ?~  priv.keypair
          ::  put it into some temporary thing for cold storage. Make it pending
          !!
        %+  ecdsa-raw-sign:secp256k1:secp:crypto
        hash  u.priv.keypair
      :-  ~
      %=    state
          signed-message-store
        %+  ~(put by signed-message-store.state)
        `@ux`hash  [typed-message signature]
      ==
    ::
        %set-nonce  ::  for testing/debugging
      =-  `state(nonces (~(put by nonces) address.act -))
      (~(put by (~(gut by nonces.state) address.act ~)) [town new]:act)
    ::
        %approve-origin
      `state(approved-origins (~(put by approved-origins) +.act))
    ::
        %remove-origin
      `state(approved-origins (~(del by approved-origins) +.act))
    ::
        %submit-signed
      ::  sign a pending transaction from an attached hardware wallet
      ~|  "%wallet: no pending transactions from that address"
      =/  my-pending  (~(got by pending-store) from.act)
      ?~  found=(~(get by my-pending) hash.act)
        ~|("%wallet: can't find pending transaction with that hash" !!)
      =*  tx  transaction.u.found
      ::  get our nonce
      =/  our-nonces  (~(gut by nonces.state) from.act ~)
      =/  nonce=@ud   (~(gut by our-nonces) town.tx 0)
      ::  update tx with sig, nonce, and gas
      =:  sig.tx           sig.act
          nonce.caller.tx  +(nonce)
          rate.gas.tx      rate.gas.act
          bud.gas.tx       bud.gas.act
          eth-hash.tx      `eth-hash.act
          status.tx        %101
      ==
      ::  update hash of tx with new values
      =/  hash  (hash-transaction +.tx)
      ~&  >>  "%wallet: submitting externally-signed transaction"
      ~&  >>  "with signature {<v.sig.act^r.sig.act^s.sig.act>}"
      ::  update stores
      :_  %=    state
              pending-store
            (~(put by pending-store) from.act (~(del by my-pending) hash.act))
          ::
              unfinished-transaction-store
            %+  ~(put by unfinished-transaction-store)
              hash
            [origin.u.found tx action.u.found ~]
          ::
              nonces
            (~(put by nonces) from.act (~(put by our-nonces) town.tx +(nonce)))
          ==
      :~  (tx-update-card hash tx action.u.found)
          :*  %pass  /submit-tx/(scot %ux hash)
              %agent  [our.bowl %uqbar]
              %poke  %uqbar-write
              !>(`write:uqbar`[%submit tx])
          ==
      ==
    ::
        %submit
      ::  sign a pending transaction from this hot wallet
      ~|  "%wallet: no pending transactions from that address"
      =/  my-pending  (~(got by pending-store) from.act)
      ?~  found=(~(get by my-pending) hash.act)
        ~|("%wallet: can't find pending transaction with that hash" !!)
      ?~  keypair=(~(get by keys.state) from.act)
        ~|("%wallet: don't have knowledge of that address" !!)
      =*  tx  transaction.u.found
      ::  get our nonce
      =/  our-nonces  (~(gut by nonces.state) from.act ~)
      =/  nonce=@ud   (~(gut by our-nonces) town.tx 0)
      ::  update tx with sig, nonce, and gas
      =:  rate.gas.tx      rate.gas.act
          nonce.caller.tx  +(nonce)
          bud.gas.tx       bud.gas.act
          status.tx        %101
      ==
      ::  update hash of tx with new values
      =/  hash  (hash-transaction +.tx)
      ::  produce our signature
      =.  sig.tx
        ?~  priv.u.keypair
          ~|("%wallet: don't have private key for that address" !!)
        %+  ecdsa-raw-sign:secp256k1:secp:crypto
        `@uvI`hash  u.priv.u.keypair
      ::  ~&  >>  "%wallet: submitting signed transaction"
      ::  ~&  >>  "with signature {<v.sig.tx^r.sig.tx^s.sig.tx>}"
      ::  update stores
      :_  %=    state
              pending-store
            (~(put by pending-store) from.act (~(del by my-pending) hash.act))
          ::
              unfinished-transaction-store
            %+  ~(put by unfinished-transaction-store)
              hash
            [origin.u.found tx action.u.found ~]
          ::
              nonces
            (~(put by nonces) from.act (~(put by our-nonces) town.tx +(nonce)))
          ==
      :~  (tx-update-card hash tx action.u.found)
          :*  %pass  /submit-tx/(scot %ux hash)
              %agent  [our.bowl %uqbar]
              %poke  %uqbar-write
              !>(`write:uqbar`[%submit tx])
          ==
      ==
    ::
        %delete-pending
      ~|  "%wallet: no pending transactions from that address"
      =/  my-pending  (~(got by pending-store) from.act)
      ?.  (~(has by my-pending) hash.act)
        ~|("%wallet: can't find pending transaction with that hash" !!)
      ::  remove without signing
      :-  ~
      %=    state
          pending-store
        (~(put by pending-store) from.act (~(del by my-pending) hash.act))
      ==
    ::
        %transaction
      ::  take in a new pending transaction
      =/  =caller:smart
        :+  from.act
          ::  this is an ephemeral nonce used to differentiate between
          ::  pending transactions. the real on-chain nonce is assigned
          ::  upon signing.
          `@ud`(cut 3 [0 3] eny.bowl)
        ::  generate our zigs token account ID
        (hash-data:engine zigs-contract-id:smart from.act town.act `@`'zigs')
      ::  build calldata of transaction, depending on argument type
      =/  =calldata:smart
        ?-    -.action.act
            %give
          ::  Standard fungible token %give
          =/  from=asset
            (~(got by `book`(~(got by tokens.state) from.act)) item.action.act)
          ?>  ?=(%token -.from)
          [%give to.action.act amount.action.act item.action.act]
        ::
            %give-nft
          ::  Standard NFT %give
          [%give to.action.act item.action.act]
        ::
            %text
          =/  smart-lib-vase
            .^  ^vase  %gx
              /(scot %p our.bowl)/sequencer/(scot %da now.bowl)/smart-lib/noun
            ==
          ~|  "wallet: failed to compile custom action!"
          =/  data-hoon  (ream ;;(@t +.action.act))
          =/  res
            (slap smart-lib-vase data-hoon)
          !<([@tas *] res)
        ::
            %noun
          ;;(calldata:smart +.action.act)
        ==
      ::  build *incomplete* shell of transaction
      =/  =shell:smart
        :*  caller
            eth-hash=~
            to=contract.act
            gas=[rate=0 bud=0]
            town.act
            status=%100
        ==
      ::  generate hash
      =/  hash  (hash-transaction [calldata shell])
      =/  =transaction:smart  [[0 0 0] calldata shell]
      ~&  >>  "%wallet: transaction pending with hash {<hash>}"
      ::  add to our pending-store with empty signature
      ::  define origin as source desk + their wire
      =/  my-pending
        %+  ~(put by (~(gut by pending-store) from.act ~))
        hash  [origin.act transaction action.act]
      :-  :-  (tx-update-card hash transaction action.act)
          ?~  origin.act  ~
          ?~  gas=(~(get by approved-origins) u.origin.act)  ~
          :_  ~
          :*  %pass  /self-submit
              %agent  [our.bowl %wallet]
              %poke  %wallet-poke
              !>  ^-  wallet-poke
              [%submit from.act hash u.gas]
          ==
      %=  state
        pending-store  (~(put by pending-store) from.act my-pending)
      ==
    ::
        %transaction-to-ship
      ::  instead of making transaction, poke thread that will ask ship
      ::  for an address, then re-poke wallet with filled in info
      =/  tid  `@ta`(cat 3 'address-get_' (scot %uv (sham eny.bowl)))
      =/  ta-now  `@ta`(scot %da now.bowl)
      =/  start-args
        :^  ~  `tid  byk.bowl(r da+now.bowl)
        get-address-from-ship+!>(act)
      :_  state  :_  ~
      %+  ~(poke pass:io /thread/[ta-now])
        [our.bowl %spider]
      spider-start+!>(start-args)
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%new-batch ~]
    ?:  ?=(%kick -.sign)
      :_  this  ::  attempt to re-sub
      (watch-for-batches our.bowl 0x0)
    ?.  ?=(%fact -.sign)  (on-agent:def wire sign)
    =/  upd  !<(update:ui q.cage.sign)
    ?.  ?=(%batch-order -.upd)  `this
    ?~  batch-order.upd         `this
    =/  batch-hash=@ux  (rear batch-order.upd)
    ::  get latest tokens and nfts held
    =/  addrs=(list address:smart)  ~(tap in ~(key by keys))
    =/  new-tokens
      (make-tokens addrs [our now]:bowl)
    =/  new-metadata
      (update-metadata-store new-tokens metadata-store [our now]:bowl)
    =.  transaction-store
      %-  %-  ~(uno by transaction-store)
          (scan-transactions new-tokens [our now]:bowl)
      |=  $:  k=@ux
              v=(map @ux finished-transaction)
              w=(map @ux finished-transaction)
          ==
      (~(uni by v) w)
    ::  for each of unfinished, scry uqbar for status
    ::  update status, then insert in tx-store mapping
    ::  and build an update card with its new status.
    =|  cards=(list card)
    =|  still-looking=(list [@ux unfinished-transaction])
    =/  unfinished=(list [hash=@ux unfinished-transaction])
      ~(tap by unfinished-transaction-store)
    |-
    ?~  unfinished
      :_  %=  this
            tokens  new-tokens
            metadata-store  new-metadata
            unfinished-transaction-store  (malt still-looking)
          ==
      :+  :^  %give  %fact  ~[/book-updates]
          :-  %wallet-frontend-update
          !>(`wallet-frontend-update`[%new-book new-tokens])
        :^  %give  %fact  ~[/metadata-updates]
        :-  %wallet-frontend-update
        !>(`wallet-frontend-update`[%new-metadata new-metadata])
      cards
    =/  tx-latest=update:ui
      .^  update:ui
          %gx
          %+  weld  /(scot %p our.bowl)/uqbar/(scot %da now.bowl)
          /indexer/transaction/(scot %ux hash.i.unfinished)/noun
      ==
    ?.  ?&  ?=(^ tx-latest)
            ?=(%transaction -.tx-latest)
        ==
      ~&  >>>  "%wallet: couldn't find transaction hash for update!"
      $(unfinished t.unfinished, still-looking [i.unfinished still-looking])
    ::  put latest version of tx into transaction-store
    =/  updated=[@ux finished-transaction]
      =+  found=(~(got by transactions.tx-latest) hash.i.unfinished)
      ::  if the output of the transaction included in batch does not match
      ::  what we received as a receipt, this is VERY VERY BAD. we can
      ::  use this as proof of fraud against the sequencer, potentially,
      ::  but most importantly we must inform the user that the sequencer
      ::  is actively behaving in a byzantine manner.
      ::
      =.  status.transaction.found
        ?.  ?|  ?=(~ output.i.unfinished)
                =(output.found u.output.i.unfinished)
            ==
          ::  FREAK TF OUT!!!
          ~&  >>>  "%wallet: WARNING: BYZANTINE SEQUENCER"
          ~&  >>  "expected:"
          ~&  >>  output.i.unfinished
          ~&  >>  "got:"
          ~&  >>  output.found
          `@ud`'BYZANTINE'
        ::  add 300 to finished status code to get wallet status equivalent
        (add 300 status.transaction.found)
      :*  hash.i.unfinished
          origin.i.unfinished
          batch-hash
          transaction.found
          action.i.unfinished
          output.found
      ==
    ::  when we have a finished transaction, use transaction origin to
    ::  notify an app about their completed transaction.
    %=  $
      unfinished  t.unfinished
        cards
      :-  (finished-tx-update-card updated)
      ?~  origin.updated  cards
      [(notify-origin-card our.bowl updated) cards]
        transaction-store
      %+  ~(jab by transaction-store)  address.caller.transaction.i.unfinished
      |=  m=(map @ux finished-transaction)
      (~(put by m) updated)
    ==
  ==
::
++  on-arvo  on-arvo:def
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  =,  format
  ?+    +.path  (on-peek:def path)
  ::
  ::  noun scries, for other apps
  ::
      [%addresses ~]
    ``wallet-update+!>(`wallet-update`[%addresses ~(key by keys.state)])
  ::
      [%account @ @ ~]
    ::  returns our account for the pubkey and town ID given
    ::  for validator & sequencer use, to run mill
    =/  pub  (slav %ux i.t.t.path)
    =/  town  (slav %ux i.t.t.t.path)
    =/  nonce  (~(gut by (~(gut by nonces.state) pub ~)) town 0)
    =+  (hash-data:engine `@ux`'zigs-contract' pub town `@`'zigs')
    ``wallet-update+!>(`wallet-update`[%account `caller:smart`[pub nonce -]])
  ::
      [%signed-message @ ~]
    :^  ~  ~  %wallet-update
    !>  ^-  wallet-update
    ?~  message=(~(get by signed-message-store) (slav %ux i.t.t.path))
      ~
    [%signed-message u.message]
  ::
      [%metadata @ ~]
    ::  return specific metadata from our store
    :^  ~  ~  %wallet-update
    !>  ^-  wallet-update
    ?~  found=(~(get by metadata-store) (slav %ux i.t.t.path))
      ~
    [%metadata u.found]
  ::
      [%asset @ @ ~]
    ::  return specific asset from our store
    ::  held by specific address
    :^  ~  ~  %wallet-update
    !>  ^-  wallet-update
    ?~  where=(~(get by tokens) (slav %ux i.t.t.path))
      ~
    ?~  found=(~(get by `book`u.where) (slav %ux i.t.t.t.path))
      ~
    [%asset u.found]
  ::
      [%transaction @ @ ~]
    ::  find transaction from address by hash
    ::  look in all stores: pending, unfinished, finished
    :^  ~  ~  %wallet-update
    !>  ^-  wallet-update
    =/  address  (slav %ux i.t.t.path)
    =/  tx-hash  (slav %ux i.t.t.t.path)
    =/  finished  (~(gut by transaction-store) address ~)
    ?^  f1=(~(get by finished) tx-hash)
      [%finished-transaction u.f1]
    =/  pending  (~(gut by pending-store) address ~)
    ?^  f2=(~(get by pending) tx-hash)
      [%unfinished-transaction u.f2]
    ?^  f3=(~(get by unfinished-transaction-store) tx-hash)
      [%unfinished-transaction [- -.+ -.+>]:u.f3]
    ~
  ::
  ::  internal / non-standard noun scries
  ::
      [%pending-store @ ~]
    ::  return pending store for given pubkey, noun format
    =/  pub  (slav %ux i.t.t.path)
    =/  our=(map @ux [origin transaction:smart supported-actions])
      (~(gut by pending-store) pub ~)
    ``noun+!>(`(map @ux [origin transaction:smart supported-actions])`our)
  ::
  ::  JSON scries, for frontend
  ::
      [%seed ~]
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    :~  ['mnemonic' [%s mnem.seed.state]]
        ['password' [%s pass.seed.state]]
    ==
  ::
      [%accounts ~]
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    %+  turn  ~(tap by keys.state)
    |=  [pub=@ux [priv=(unit @ux) nick=@t]]
    :-  (scot %ux pub)
    %-  pairs:enjs
    :~  ['pubkey' [%s (scot %ux pub)]]
        ['privkey' ?~(priv [%s ''] [%s (scot %ux u.priv)])]
        ['nick' [%s nick]]
        :-  'nonces'
        %-  pairs:enjs
        %+  turn  ~(tap by (~(gut by nonces.state) pub ~))
        |=  [town=@ux nonce=@ud]
        [(scot %ux town) (numb:enjs nonce)]
    ==
  ::
      [%book ~]
    =;  =json  ``json+!>(json)
    ::  return entire book map for wallet frontend
    %-  pairs:enjs
    %+  turn  ~(tap by tokens.state)
    |=  [pub=@ux =book]
    :-  (scot %ux pub)
    %-  pairs:enjs
    %+  turn  ~(tap by book)
    |=  [=id:smart =asset]
    (asset:parsing id asset)
  ::
      [%token-metadata ~]
    =;  =json  ``json+!>(json)
    ::  return entire metadata-store
    %-  pairs:enjs
    %+  turn  ~(tap by metadata-store.state)
    |=  [=id:smart d=asset-metadata]
    (metadata:parsing id d)
  ::
      [%transactions ~]
    ::  return transaction store for given pubkey (includes unfinished)
    ::  =/  our-txs=(map @ux [transaction:smart supported-actions output:eng])
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    :~  :-  'unfinished'
        %-  pairs:enjs
        %+  turn  ~(tap by unfinished-transaction-store.state)
        |=  [hash=@ux uf=unfinished-transaction]
        ?~  output.uf
          (transaction-no-output:parsing hash [- -.+ -.+>]:uf)
        %-  transaction-with-output:parsing
        [hash -.uf 0x0 -.+.uf -.+>.uf u.output.uf]
        :-  'finished'
        %-  pairs:enjs
        %+  turn  ~(tap by transaction-store.state)
        |=  [a=@ux m=(map @ux finished-transaction)]
        :-  (scot %ux a)
        %-  pairs:enjs
        (turn ~(tap by m) transaction-with-output:parsing)
    ==
  ::
      [%pending @ ~]
    ::  return pending store for given pubkey
    =/  pub  (slav %ux i.t.t.path)
    =/  our=(map @ux [origin transaction:smart supported-actions])
      (~(gut by pending-store) pub ~)
    ::
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    %+  turn  ~(tap by our)
    transaction-no-output:parsing
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
