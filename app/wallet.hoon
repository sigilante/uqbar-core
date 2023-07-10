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
+$  state-5
  $:  %5
      ::  wallet holds a single seed at once
      ::  address-index notes where we are in derivation path
      seed=[mnem=@t pass=@t address-index=@ud]
      ::  many keys can be derived or imported
      ::  if the private key is ~, that means it's a hardware wallet import
      keys=(map address:smart key)
      =share-prefs
      ::  we track the nonce of each address we're handling
      nonces=(map address:smart (map town=@ux nonce=@ud))
      ::  pending typed-messages to sign
      =pending-message-store
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
=|  state-5
=*  state  -
::
%-  agent:dbug
::  %+  verb  &
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  `this(state *state-5)
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ?+    -.q.old-vase  on-init
      %5
    `this(state !<(state-5 old-vase))
      %4
    =+  old=!<(state-4 old-vase)
    =/  newkeys  (merge-keys keys.old encrypted-keys.old)
    =+  new=[%5 seed.old newkeys share-prefs.old nonces.old ~ |6:old]
    (on-load !>(`state-5`new))
      %3
    =+  old=!<(state-3 old-vase)
    (on-load !>(`state-4`[%4 seed.old keys.old ~ |3:old]))
      %2
    =+  old=!<(state-2 old-vase)
    =+  new=[%3 -.+.old -.+.+.old *^share-prefs +.+.+.old]
    (on-load !>(`state-3`new))
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
      ?.  ?|  =(status.transaction.tx %202)
              =(status.transaction.tx %103)
          ==
        nonces
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
      =/  sent   (get-sent-history addr %.n [our now]:bowl)
      =/  nonce  (get-nonce addr %.n [our now]:bowl)
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
        nonces                [[addr [[0x0 nonce] ~ ~]] ~ ~]
        metadata-store        (update-metadata-store tokens ~ [our now]:bowl)
        unfinished-transaction-store  ~
        transaction-store  [[addr sent] ~ ~]
        keys  %+  ~(put by *(map address:smart key))
              addr  [%legacy [nick.act private-key:core]]
      ==
    ::
        %generate-hot-wallet
      ::  will lose seed in current wallet, should warn on frontend!
      ::  creates a new wallet from entropy derived on-urbit
      =+  mnem=(from-entropy:bip39 [32 eny.bowl])
      =+  core=(from-seed:bip32 [64 (to-seed:bip39 mnem (trip password.act))])
      =+  addr=(address-from-prv:key:ethereum private-key:core)
      ::  get transaction history for this new address
      =/  sent    (get-sent-history addr %.n [our now]:bowl)
      =/  nonce   (get-nonce addr %.n [our now]:bowl)
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
        nonces                [[addr [[0x0 nonce] ~ ~]] ~ ~]
        metadata-store        (update-metadata-store tokens ~ [our now]:bowl)
        unfinished-transaction-store  ~
        transaction-store  [[addr sent] ~ ~]
        keys  %+  ~(put by *(map address:smart key))
              addr  [%legacy [nick.act private-key:core]]
      ==
    ::
        %store-hot-wallet
      ::  get transaction history for this new address
      =/  sent   (get-sent-history address.act %.n [our now]:bowl)
      =/  nonce  (get-nonce address.act %.n [our now]:bowl)
      =/  tokens
        (make-tokens [address.act ~(tap in ~(key by keys))] [our now]:bowl)
      :-  (watch-for-batches our.bowl 0x0)
      %=  state
        tokens  tokens
        nonces  (~(put by nonces) address.act [[0x0 nonce] ~ ~])
        keys    (~(put by keys) address.act [%encrypted [nick priv seed]:act])
        transaction-store  (~(put by transaction-store) address.act sent)
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
      =/  nonce   (get-nonce addr %.n [our now]:bowl)
      =/  tokens  (make-tokens [addr ~(tap in ~(key by keys))] [our now]:bowl)
      :-  ~
      %=  state
        tokens  tokens
        nonces  (~(put by nonces) addr [[0x0 nonce] ~ ~])
        seed    seed(address-index +(address-index.seed))
        keys    (~(put by keys) addr [%legacy [nick.act prv:core]])
        transaction-store  (~(put by transaction-store) addr sent)
      ==
    ::
        %add-tracked-address
      ::  get transaction history for this new address
      =/  sent   (get-sent-history address.act %.n [our now]:bowl)
      =/  nonce  (get-nonce address.act %.n [our now]:bowl)
      =/  tokens
        (make-tokens [address.act ~(tap in ~(key by keys))] [our now]:bowl)
      :-  ~
      %=  state
        tokens  tokens
        nonces  (~(put by nonces) address.act [[0x0 nonce] ~ ~])
        keys    (~(put by keys) address.act [%imported nick.act])
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
        keys               (~(del by keys) address.act)
        nonces             (~(del by nonces) address.act)
        tokens             (~(del by tokens) address.act)
        transaction-store  (~(del by transaction-store) address.act)
      ==
    ::
        %edit-nickname
      =/  =key  (~(got by keys) address.act)
      ::  weird find-fork type refinement error, have to ?-
      =.  key  
        ?-    -.key
            %imported
          key(nick nick.act)
        ::
            %legacy
          key(nick nick.act)
        ::
            %encrypted
          key(nick nick.act)
        ==
      `state(keys (~(put by keys) address.act key))
    ::
       %submit-typed-message
      ::  sign a pending typed-message from an attached hardware wallet
      ?~  pending=(~(get by pending-message-store) hash.act)
        ~|("%wallet: no pending signature to that address" !!)
      =/  =typed-message:smart
        :+  domain.u.pending
          `@ux`(sham type.u.pending)
        msg.u.pending
      =/  hash  (generate-eth-hash hash.act)
      ::  update stores
      :-   ?~  origin.u.pending  ~
      :_  ~
      :*   %pass   q.u.origin.u.pending
           %agent  [our.bowl p.u.origin.u.pending]
           %poke  %wallet-update
           !>  ^-  wallet-update
           :*  %signed-message
               origin.u.pending
               typed-message
               sig.act
      ==   ==
      %=    state
        pending-message-store
        (~(del by pending-message-store) hash.act)
        ::
        signed-message-store
        %+  ~(put by signed-message-store)
          hash
          [typed-message sig.act]
      ==
    ::
        %sign-typed-message
      =/  keypair  (~(got by keys.state) from.act)
      =/  =typed-message:smart  [domain.act `@ux`(sham type.act) msg.act]
      ::  we might want to make signatures default to eth_personal_sign
      ::  eth_sign would work with this, but "unsafe"
      =/  typedhash  (shag:smart typed-message)
      ?-    -.keypair
          ?(%imported %encrypted)
        ::  put in pending and wait for signature from outside
        :-  :_  ~
          :*  %give  %fact
              ~[/tx-updates]  %wallet-frontend-update 
              !>  ^-  wallet-frontend-update
              :*    %new-sign-message
                    `@ux`typedhash  origin.act
                    from.act   domain.act  
                    type.act
          ==  ==
          %=    state
              pending-message-store
            (~(put by pending-message-store) `@ux`typedhash +.act)
          ==
      ::
          %legacy
        =/  hash       (generate-eth-hash typedhash)
        =/  signature
          %+  ecdsa-raw-sign:secp256k1:secp:crypto
          `@uvI`hash  priv.keypair
        :-   ?~  origin.act  ~
        :_  ~
        :*   %pass   q.u.origin.act
             %agent  [our.bowl p.u.origin.act]
             %poke  %wallet-update
             !>  ^-  wallet-update
             :*  %signed-message
                 origin.act
                 typed-message
                 signature
        ==   ==
        %=    state
            signed-message-store
          %+  ~(put by signed-message-store.state)
          hash  [typed-message signature]
        ==
      ==
    ::
        %delete-typed-message
      ~|  "%wallet: no pending message with that hash"
      =/  my-pending  (~(got by pending-message-store) hash.act)
      ::  remove without signing
      :-  ~
      %=    state
          pending-message-store
        (~(del by pending-message-store) hash.act)
      ==
    ::
        %set-nonce  ::  for testing/debugging
      =-  `state(nonces (~(put by nonces) address.act -))
      (~(put by (~(gut by nonces.state) address.act ~)) [town new]:act)
    ::
        %realign-nonce  :: try to realign based on local indexer
      =/  nonce  (get-nonce address.act %.n [our now]:bowl)
      =-  `state(nonces (~(put by nonces) address.act -))
      (~(put by (~(gut by nonces.state) address.act ~)) town.act nonce)
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
      ==  ==
    ::
        %submit
      ::  sign a pending transaction from this hot wallet
      ~|  "%wallet: no pending transactions from that address"
      =/  my-pending  (~(got by pending-store) from.act)
      ?~  found=(~(get by my-pending) hash.act)
        ~|("%wallet: can't find pending transaction with that hash" !!)
      ?:  =(0x0 from.act)
        ::  submit an unsigned message, account abstracted contract pays for gas
        =*  tx  transaction.u.found
        =:  rate.gas.tx      rate.gas.act
            bud.gas.tx       bud.gas.act
            status.tx        %101
        ==
        ::  update hash of tx with new values
        =/  hash  (hash-transaction +.tx)
        :_  %=    state
                pending-store
              (~(put by pending-store) from.act (~(del by my-pending) hash.act))
            ::
                unfinished-transaction-store
              %+  ~(put by unfinished-transaction-store)
                hash
              [origin.u.found tx action.u.found ~]
            ==
        :~  (tx-update-card hash tx action.u.found)
            :*  %pass  /submit-tx/(scot %ux hash)
                %agent  [our.bowl %uqbar]
                %poke  %uqbar-write
                !>(`write:uqbar`[%submit tx])
        ==  ==
      =/  =key  (~(got by keys.state) from.act)
      ?>  ?=(%legacy -.key)
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
        %+  ecdsa-raw-sign:secp256k1:secp:crypto
        `@uvI`hash  priv.key
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
      ==  ==
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
          ::  if there are several pending txs from the same address,
          ::  cannot sign them one after another [fix]
          =/  our-nonces  (~(gut by nonces.state) from.act ~)
          +((~(gut by our-nonces) town.act 0))
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
        %unsigned-transaction
      ::  build calldata of transaction, depending on argument type
      =/  =calldata:smart
        ?-    -.action.act
            %noun
          +.action.act
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
        ==
      =/  =shell:smart  [[0x0 0 0x0] ~ contract.act [0 0] town.act %100]
      ::  generate hash
      =/  hash  (hash-transaction [calldata shell])
      =/  =transaction:smart  [[0 0 0] calldata shell]
      ~&  >>  "%wallet: submitting unsigned tx with hash {<hash>}"
      ::  update stores
      =/  my-pending
        %+  ~(put by (~(gut by pending-store) 0x0 ~))
        hash  [origin.act transaction action.act]
      :-  :-  (tx-update-card hash transaction action.act)
          ?~  origin.act  ~
          ?~  gas=(~(get by approved-origins) u.origin.act)  ~
          :_  ~
          :*  %pass  /self-submit
              %agent  [our.bowl %wallet]
              %poke  %wallet-poke
              !>  ^-  wallet-poke
              [%submit 0x0 hash u.gas]
          ==
      %=  state
        pending-store  (~(put by pending-store) 0x0 my-pending)
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
    =/  addrs=(list address:smart)
      ~(tap in ~(key by keys))
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
    [%signed-message ~ u.message]
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
      [%encrypted-accounts ~]
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    %+  murn  ~(tap by keys.state)
    |=  [pub=@ux =key]
    ?.  ?=(%encrypted -.key)
      ~
    :-  ~
    :-  (scot %ux pub)
    %-  pairs:enjs
    :~  ['nick' s+nick.key]
        ['priv' s+priv.key]
        ['seed' s+seed.key]
    ==
  ::
      [%accounts ~]
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    %+  turn  ~(tap by keys.state)
    |=  [pub=@ux =key]
    :-  (scot %ux pub)
    %-  pairs:enjs
    ?-    -.key
        %legacy
      :~  ['pubkey' [%s (scot %ux pub)]]
          ['type' [%s 'legacy']]
          ['privkey' [%s (scot %ux priv.key)]]
          ['nick' [%s nick.key]]
          :-  'nonces'
          %-  pairs:enjs
          %+  turn  ~(tap by (~(gut by nonces.state) pub ~))
          |=  [town=@ux nonce=@ud]
          [(scot %ux town) (numb:enjs nonce)]
      ==
    ::
        %imported
      :~  ['pubkey' [%s (scot %ux pub)]]
          ['type' [%s 'imported']]
          ['nick' [%s nick.key]]
          :-  'nonces'
          %-  pairs:enjs
          %+  turn  ~(tap by (~(gut by nonces.state) pub ~))
          |=  [town=@ux nonce=@ud]
          [(scot %ux town) (numb:enjs nonce)]
      ==
    ::
        %encrypted
      :~  ['pubkey' [%s (scot %ux pub)]]
          ['type' [%s %encrypted]]
          ['privkey' [%s priv.key]]
          ['seed' [%s seed.key]]
          ['nick' [%s nick.key]]
          :-  'nonces'
          %-  pairs:enjs
          %+  turn  ~(tap by (~(gut by nonces.state) pub ~))
          |=  [town=@ux nonce=@ud]
          [(scot %ux town) (numb:enjs nonce)]
      ==
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
      [%pending-sign-messages ~]
    =;  =json  ``json+!>(json)
    %-  pairs:enjs
    %+  turn  ~(tap by pending-message-store.state)
    |=  [=hash:smart [=origin =address:smart domain=id:smart type=json msg=*]]
    :-  (scot %ux hash)
    %-  pairs:enjs
    :~  ['origin' [%s ?~(origin '' (scot %tas p.u.origin))]]
        ['address' s+(scot %ux address)]
        ['domain' s+(scot %ux domain)]
        ['type' type]
        ::  no msg=* parsed right now.
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
