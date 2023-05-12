::  sequencer [UQ| DAO]
::
::  Agent for managing a single UQ| town. Publishes diffs to rollup.hoon
::  Accepts transactions and batches them periodically as moves to town.
::
/-  uqbar=zig-uqbar
/+  default-agent, dbug, io=agentio, verb,
    *zig-sequencer, zink=zink-zink, sig=zig-sig,
    engine=zig-sys-engine
::  Choose which library smart contracts are executed against here
::
/*  smart-lib-noun  %noun  /lib/zig/sys/smart-lib/noun
|%
+$  card  card:agent:gall
::
+$  state-3
  $:  %3
      last-batch-time=@da      ::  saved to compare against indexer acks
      indexers=(map dock @da)  ::  indexers receiving batch updates
      rollup=(unit @ux)        ::  rollup contract address
      private-key=(unit @ux)   ::  our signing key
      town=(unit town)         ::  chain-state
      pending=mempool          ::  unexecuted transactions
      =memlist                 ::  executed transactions in working state
      working-batch=(unit proposed-batch)  ::  stores working state
      pending-batch=(unit proposed-batch)
      status=?(%available %off)
      block-height-api-key=(unit @t)
  ==
+$  inflated-state-3  [state-3 =eng smart-lib-vase=vase]
::  sigs on, hints off
+$  eng  $_  ~(engine engine !>(0) *(map * @) jets:zink %.y %.n)
--
::
=|  inflated-state-3
=*  state  -
%-  agent:dbug
::  %+  verb  &
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng  ~(engine engine smart-lib *(map * @) jets:zink %.y %.n)
  `this(state [*state-3 eng smart-lib])
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng  ~(engine engine smart-lib *(map * @) jets:zink %.y %.n)
  ?+    -.q.old-vase
    `this(state [*state-3 eng smart-lib])
      %3
    `this(state [!<(state-3 old-vase) eng smart-lib])
      %2
    =/  old  !<(state-2 old-vase)
    =+  [pending.old memlist.old ~ ~ |10:old]
    `this(state [`state-3`[%3 +.old(rollup `0x0, |5 -)] eng smart-lib])
      %1
    =/  old  !<(state-1 old-vase)
    (on-load !>(`state-2`[%2 *@da *(map dock @da) +.old]))
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  ~|("%sequencer: error: got erroneous %poke" !!)
      %tracker-request
    ::  can insert logic here in future around restricting
    ::  access to indexers -- for now, open to all
    `this(indexers (~(put by indexers) [src.bowl %indexer] now.bowl))
  ::
      %tracker-stop
    `this(indexers (~(del by indexers) [src.bowl %indexer]))
  ::
      %sequencer-town-action
    =^  cards  state
      (handle-poke !<(town-action vase))
    [cards this]
  ::
      %sidecar-action
    ?>  =(src our):bowl
    =/  act  !<(sidecar-action vase)
    ?-    -.act
        %batch-posted
      ::  converts pending-batch into current town state
      ::  and clears pending-batch
      ?~  town  !!
      ~&  >>  "%sequencer: batch approved by rollup"
      ?~  pending-batch
        ~|("received batch approval without pending batch" !!)
      =/  new-town=^town
        (transition-state u.town u.pending-batch)
      ::  inject received town-root into state of town
      =.  chain.new-town
        (inject-town-root chain.new-town town-root.act)
      `this(pending-batch ~, town `new-town)
      ::
          %batch-rejected
        ::  handle pending-batch being invalid
        ::  (working-batch also becomes invalid!)
        ~&  >>>  "%sequencer: pending batch REJECTED"
        `this(pending-batch ~, working-batch ~)
      ==
  ==
  ::
  ++  handle-poke
    |=  act=town-action
    ^-  (quip card _state)
    ?-    -.act
    ::
    ::  town administration
    ::
        %init
      ?>  =(src our):bowl
      ?.  =(%off status)
        ~|("%sequencer: already active" !!)
      =/  =chain  ?~(starting-state.act [~ ~] u.starting-state.act)
      =/  new-root  ->-.p.chain
      =/  =^town
        :-  chain
        :*  town-id.act
            batch-num=0
            [address.act our.bowl]
            mode.act
            0x0
            ~[new-root]
            ~
        ==
      =/  sig
        (ecdsa-raw-sign:secp256k1:secp:crypto `@uvI`new-root private-key.act)
      :-  %+  turn   ~(tap by indexers)
          |=  [=dock @da]
          %+  ~(poke pass:io /indexer-updates)
            dock
          :-  %sequencer-indexer-update
          !>  ^-  indexer-update
          [%update new-root ~ town]
      %=  state
        private-key  `private-key.act
        town         `town
        status        %available
        working-batch  `[0 ~ chain.town 0x0 new-root ~]
      ==
    ::
        %set-block-height-api-key
      ?>  =(src our):bowl
      `state(block-height-api-key `key.act)
    ::
        %del-block-height-api-key
      ?>  =(src our):bowl
      `state(block-height-api-key ~)
    ::
        %clear-state
      ?>  =(src our):bowl
      ~&  >>>  "sequencer: wiping state"
      `[*state-3 eng smart-lib-vase]
    ::
    ::  handle bridged assets from rollup
    ::
        %deposit
      ::  handle a transaction generated by rollup contract to bridge ETH
      ::  assets onto the town we're running. (TODO)
      ?>  =(src our):bowl
      ?:  ?|  !=(%available status)
              ?=(~ town)
          ==
        ~|("%sequencer: error: got asset while not active" !!)
      =/  deposit-bytes=@ux
        `@ux`(scan `tape`(slag 2 deposit-bytes.act) hex)
      ::  assert we haven't used this transaction hash as a deposit before
      =/  working-deposits
        %-  ~(uni in deposits.hall.u.town)
        ?~  working-batch  ~
        deposits.u.working-batch
      ::  assert this deposit has never been used historically
      ?<  (~(has in deposits.hall.u.town) deposit-bytes)
      ::  assert this deposit is not already in the working-batch
      ?<  %.  deposit-bytes
          ~(has in ?~(working-batch ~ deposits.u.working-batch))
      ~&  >>  "%sequencer: received asset from rollup: {<deposit>}"
      =.  working-batch
        ?^  working-batch
          =.  deposits.u.working-batch
            (~(put in deposits.u.working-batch) deposit-bytes)
          working-batch
        =|  pob=proposed-batch
        =.     chain.pob  chain.u.town
        =.  deposits.pob  (~(put in deposits.pob) deposit-bytes)
        `pob
      `state
    ::
    ::  transactions
    ::
        %receive
      ?.  =(%available status)
        ~|("%sequencer: error: got transaction while not active" !!)
      ::  configurable rate minimum
      ?.  (gte rate.gas.transaction.act 1)
        ~|("%sequencer: rejected transaction, gas rate too low" !!)
      ::  fetch latest ETH block height and perform batch
      ::  TODO inline thread
      =/  tid  `@ta`(cat 3 'run-single_' (scot %uv (sham eny.bowl)))
      =/  ta-now  `@ta`(scot %da now.bowl)
      =+  [`@ux`(sham +.transaction.act) src.bowl transaction.act]
      :_  state(pending (~(put by pending) -))
      :~  %+  ~(watch pass:io /run-single/[ta-now])
            [our.bowl %spider]
          /thread-result/[tid]
        ::
          %+  ~(poke pass:io /run-single/[ta-now])
            [our.bowl %spider]
          :-  %spider-start
          !>  :^  ~  `tid
                byk.bowl(r da+now.bowl)
              sequencer-get-block-height-etherscan+!>(block-height-api-key)
      ==
    ::
        %run-pending
      ?>  =(src.bowl our.bowl)
      ?:  =(~ pending)
        ::  ~&  >  "%sequencer: no pending txns to run"
        `state
      ?~  town  ~|("%sequencer: error: no state" !!)
      =/  addr  p.sequencer.hall.u.town
      =/  our-caller
        (get-our-caller addr town-id.hall.u.town [our now]:bowl)
      =/  new=state-transition
        %^    %~  run  eng
              :^    our-caller
                  town-id.hall.u.town
                batch-num.hall.u.town
              eth-block-height.act
            ?~  working-batch
              chain.u.town
            chain.u.working-batch
          (sort-mempool:eng pending)
        ?~  working-batch  ~
        ~(tap in deposits.u.working-batch)
      =/  processed
        %+  turn  processed.new
        |=  [a=@ux b=transaction:smart c=output]
        [a b `c]
      =/  memlist-lent  (lent memlist)
      :_  %=  state
            pending        ~
            memlist        (weld memlist `^memlist`processed)
              working-batch
            =-  `[0 ~ chain.new 0x0 0x0 -]
            ?~(working-batch ~ deposits.u.working-batch)
          ==
      ^-  (list card)
      =<  p
      %^  spin  processed.new  0
      |=  [[=hash:smart t=transaction:smart op=output] i=@]
      :_  +(i)
      =/  signed-stuff  `@ux`(sham [t op])
      =/  usig
        %+  ecdsa-raw-sign:secp256k1:secp:crypto
          `@uvI`signed-stuff
        (need private-key)
      %+  ~(poke pass:io /receipt)
        [from:(~(got by pending) hash) %uqbar]
      :-  %uqbar-write
      !>  ^-  write:uqbar
      :+  %receipt  hash
      :+  (sign:sig our.bowl now.bowl signed-stuff)
        usig
      [(add memlist-lent i) t op]
    ::
    ::  batching
    ::
        %trigger-batch
      ?>  =(src our):bowl
      ::  fetch latest ETH block height and perform batch
      ::  TODO inline thread
      =/  tid  `@ta`(cat 3 'make-batch_' (scot %uv (sham eny.bowl)))
      =/  ta-now  `@ta`(scot %da now.bowl)
      :_  state
      :~  %+  ~(watch pass:io /make-batch/[ta-now])
            [our.bowl %spider]
          /thread-result/[tid]
        ::
          %+  ~(poke pass:io /make-batch/[ta-now])
            [our.bowl %spider]
          :-  %spider-start
          !>  :^  ~  `tid
                byk.bowl(r da+now.bowl)
              sequencer-get-block-height-etherscan+!>(block-height-api-key)
      ==
    ::
        %perform-batch
      ?>  =(src.bowl our.bowl)
      ?.  =(%available status)
        ~|("%sequencer: got poke while not active" !!)
      ?~  town
        ~|("%sequencer: no state" !!)
      ::  ?~  rollup
      ::    ~|("%sequencer: no known rollup contract" !!)
      ?^  pending-batch
        ~|("%sequencer: cannot batch, last one still pending" !!)
      ?:  =(~ memlist)  `state
      ~&  %perform-batch
      ~>  %bout
      ?>  ?=(%full-publish -.mode.hall.u.town)
      ::  publish full diff data
      ::
      ::  produce diff and new state with engine
      ::
      =/  addr  p.sequencer.hall.u.town
      =/  our-caller
        (get-our-caller addr town-id.hall.u.town [our now]:bowl)
      =/  new=state-transition
        %^    %~  run  eng
              :^    our-caller
                  town-id.hall.u.town
                batch-num.hall.u.town
              eth-block-height.act
            chain.u.town
          memlist
        ?~  working-batch  ~
        ~(tap in deposits.u.working-batch)
      =/  batch=proposed-batch
        :*  +(batch-num.hall.u.town)
            processed.new
            chain.new
            `@ux`(sham ~[modified.new])
            root=->-.p.chain.new  ::  top level merkle root
            ::  deposits
            ?~  working-batch  ~
            deposits.u.working-batch
        ==
      ::  poke all watching indexers with update and
      ::  remove indexers who have not ack'd recently enough.
      =.  indexers
        %-  malt
        %+  skim  ~(tap by indexers)
        |=  [dock last-ack=@da]
        (gte last-ack last-batch-time)
      :_  %=  state
            memlist          ~
            last-batch-time  now.bowl
            working-batch    `batch
            pending-batch    `batch
          ==
      ::  remote scry: only poke indexers with the hash of new batch.
      ::  they will scry for the actual batch contents. NOTE:
      ::  replace with sticky-scry / subscription once available.
      ::  pin the actual batch to a path of its hash.
      :-  :*  %pass  /pin-batch
              %grow  /batch/(scot %ux town-id.hall.u.town)/(scot %ux root.batch)
              ^-  page
              :-  %sequencer-indexer-update
              ^-  indexer-update
              :^  %update  root.batch
                processed-txs.batch
              (transition-state u.town batch)
          ==
      %+  turn   ~(tap by indexers)
      |=  [=dock @da]
      %+  ~(poke pass:io /indexer-updates)
        dock
      :-  %sequencer-indexer-update
      ?.  =(p.dock our.bowl)
        !>(`indexer-update`[%notify town-id.hall.u.town root.batch])
      !>  ^-  indexer-update
      :^  %update  root.batch
        processed-txs.batch
      (transition-state u.town batch)
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%indexer-updates ~]
    ::  catalog poke-acks from indexers tracking us
    ?.  ?=(%poke-ack -.sign)  `this
    ?^  p.sign
      ::  indexer failed on poke, remove them from trackers
      ::  TODO use app-source in bowl to remove %indexer hardcode!
      `this(indexers (~(del by indexers) [src.bowl %indexer]))
    ::  put ack-time in tracker map
    `this(indexers (~(put by indexers) [src.bowl %indexer] now.bowl))
  ::
      [%make-batch @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %thread-fail
        =/  err  !<  (pair term tang)  q.cage.sign
        %-  %+  slog
              leaf+"%sequencer: get-eth-block thread failed: {(trip p.err)}"
            q.err
        `this
          %thread-done
        =/  height=@ud  !<(@ud q.cage.sign)
        ~&  >  "eth-block-height: {<height>}"
        :_  this
        ::  get any last pending transactions, then make a batch.
        :~  %+  ~(poke pass:io /perform)
              [our.bowl %sequencer]
            sequencer-town-action+!>(`town-action`[%run-pending height])
            %+  ~(poke pass:io /perform)
              [our.bowl %sequencer]
            sequencer-town-action+!>(`town-action`[%perform-batch height])
        ==
      ==
    ==
  ::
      [%run-single @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %thread-fail
        =/  err  !<  (pair term tang)  q.cage.sign
        %-  %+  slog
              leaf+"%sequencer: get-eth-block thread failed: {(trip p.err)}"
            q.err
        ::  NOW TRY AGAIN
        =/  tid  `@ta`(cat 3 'run-single_' (scot %uv (sham eny.bowl)))
        =/  ta-now  `@ta`(scot %da now.bowl)
        :_  this
        :~  %+  ~(watch pass:io /run-single/[ta-now])
              [our.bowl %spider]
            /thread-result/[tid]
          ::
            %+  ~(poke pass:io /run-single/[ta-now])
              [our.bowl %spider]
            :-  %spider-start
            !>  :^  ~  `tid
                  byk.bowl(r da+now.bowl)
                sequencer-get-block-height-etherscan+!>(block-height-api-key)
        ==
          %thread-done
        =/  height=@ud  !<(@ud q.cage.sign)
        ~&  >  "eth-block-height: {<height>}"
        :_  this  :_  ~
        %+  ~(poke pass:io /perform)
          [our.bowl %sequencer]
        sequencer-town-action+!>(`town-action`[%run-pending height])
      ==
    ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%status ~]
    ``noun+!>(status)
  ::
      [%town-id ~]
    ?~  town  ``noun+!>(~)
    ``noun+!>(`town-id.hall.u.town)
  ::
      [%smart-lib ~]
    ::  grab the smart-lib-vase that's prebuilt here for usage elsewhere
    ``noun+!>(smart-lib-vase)
  ::
      [%pending-batch ~]
    ::  if none, returns ~
    ?~  town  ``json+!>(~)
    ?~  pend=pending-batch  ``json+!>(~)
    =/  txs-without-outputs
      %+  turn  processed-txs.u.pend
      |=  [hash=@ux tx=transaction:smart *]
      [hash tx]
    =/  txs-hash=@ux  `@`(shag:merk txs-without-outputs)
    =/  txs-jam=@ux   (jam txs-without-outputs)
    =-  ``json+!>(-)
    =,  enjs:format
    %-  pairs
    :~  ['town' s+(crip (a-co:co `@`town-id.hall.u.town))]
        ['txs' s+(crip (z-co:co txs-jam))]
        ['txRoot' s+(crip (z-co:co txs-hash))]
        ['stateRoot' s+(crip (z-co:co root.u.pend))]
        ['hasDeposits' b+?=(^ deposits.u.pend)]
        ['prevEndDeposit' s+(crip (a-co:co ~(wyt in deposits.hall.u.town)))]
        ['newEndDeposit' s+(crip (a-co:co ~(wyt in deposits.u.pend)))]
        ['prevStateRoot' s+(crip (z-co:co (rear roots.hall.u.town)))]
    ==
  ::
  ::  state reads fail if sequencer not active
  ::
      [%has @ ~]
    ::  see if grain exists in state
    =/  id  (slav %ux i.t.t.path)
    ?~  town  [~ ~]
    ``noun+!>((~(has by p.chain.u.town) id))
  ::
      [%state-tree ~]
    ::  return working state merkle tree
    ?~  town  [~ ~]
    =/  working-chain=chain
      ?~  working-batch
        chain.u.town
      chain.u.working-batch
    ``noun+!>(p.working-chain)
  ::
      [%all-data ~]
    ?~  town  [~ ~]
    =-  ``noun+!>(-)
    %+  murn  ~(tap in p.chain.u.town)
    |=  [=id:smart @ =item:smart]
    ?.  ?=(%& -.item)  ~
    `item
  ::
      [%item @ ~]
    ?~  town  [~ ~]
     =/  working-chain=chain
      ?~  working-batch
        chain.u.town
      chain.u.working-batch
    ``noun+!>((get:big p.working-chain (slav %ux i.t.t.path)))
  ==
::
++  on-arvo   on-arvo:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
