::  sequencer [UQ| DAO]
::
::  Agent for managing a single UQ| town. Publishes diffs to rollup.hoon
::  Accepts transactions and batches them periodically as moves to town.
::
::  sequencer.hoon is designed to run with a sidecar:
::  https://github.com/uqbar-dao/poa-rollup
::
::  the flow works as such:
::  :sequencer &sidecar-action [%trigger-batch deposits=~]
::  (sequencer produces batch, posts at /pending-batch scry path)
::  :sequencer &sidecar-action [%batch-posted town-root=0x0 block-at=0]
::
::  to use this agent locally, for testing, one can use the -zig!batch
::  thread included in this repo, which will automatically fetch a recent
::  ETH block height, but spoof the town-root.
::
/-  uqbar=zig-uqbar
/+  default-agent, dbug, agentio, verb,
    *zig-sequencer, zink=zink-zink, sig=zig-sig,
    engine=zig-sys-engine
::  Choose which library smart contracts are executed against here
::
/*  smart-lib-noun  %noun  /lib/zig/sys/smart-lib/noun
|%
+$  card  $+(card card:agent:gall)
::
+$  state-4
  $:  %4
      last-batch-time=@da      ::  saved to compare against indexer acks
      last-batch-block=@ud     ::  most recent L1 block we can commit to
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
+$  inflated-state-4  [state-4 =eng smart-lib-vase=vase]
::  sigs on, hints off
+$  eng  $_  ~(engine engine !>(0) jets:zink %.y)
--
::
=|  inflated-state-4
=*  state  -
%-  agent:dbug
%+  verb  &
^-  agent:gall
|_  =bowl:gall
+*  this  .
    io    ~(. agentio bowl)
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =/  smart-lib=vase
    ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng  ~(engine engine smart-lib jets:zink %.y)
  `this(state [*state-4 eng smart-lib])
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  smart-lib=vase
    ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng  ~(engine engine smart-lib jets:zink %.y)
  ?+    -.q.old-vase
    `this(state [*state-4 eng smart-lib])
      %4
    `this(state [!<(state-4 old-vase) eng smart-lib])
      %3
    =/  old  !<(state-3 old-vase)
    =-  %-  on-load
        !>  ^-  state-4
        [%4 -.+.old 0 +.+.old(town -, working-batch ~, pending-batch ~)]
    ?~  town.old  ~
    :-  ~
    ^-  ^town
    :-  chain.u.town.old
    [- -.+ +>- -.+>+ +>+>- -.+>+>+]:old-hall.u.town.old
      %2
    =/  old  !<(state-2 old-vase)
    =+  [pending.old memlist.old ~ ~ |10:old]
    (on-load !>(`state-3`[%3 +.old(rollup `0x0, |5 -)]))
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
      ::  and clears pending-batch, then shares the batch
      ::  with indexers
      ?~  town  !!
      ?~  pending-batch
        ~|("received batch approval without pending batch" !!)
      ~&  >>  "%sequencer: batch approved by rollup"
      =/  new-town=^town
        (transition-state u.town u.pending-batch)
      ::  inject received town-root into state of town
      =.  chain.new-town
        (inject-town-root chain.new-town town-root.act)
      =/  root=@ux
        ->-.p.chain.new-town
      ::  poke all watching indexers with update and
      ::  remove indexers who have not ack'd recently enough.
      =.  indexers
        %-  malt
        %+  skim  ~(tap by indexers)
        |=  [dock last-ack=@da]
        (gte last-ack last-batch-time)
      :_  %=  this
            pending-batch     ~
            town              `new-town
            last-batch-time   now.bowl
            last-batch-block  block-at.act
          ==
      ::  remote scry: only poke indexers with the hash of new batch.
      ::  they will scry for the actual batch contents. NOTE:
      ::  replace with sticky-scry / subscription once available.
      ::  pin the actual batch to a path of its hash.
      :-  :*  %pass  /pin-batch
              %grow  :~  %batch
                         (scot %ux town-id.hall.new-town)
                         (scot %ux root)
                     ==
              ^-  page
              :-  %sequencer-indexer-update
              ^-  indexer-update
              :^  %update  root
                processed-txs.u.pending-batch
              new-town
          ==
      ~&  >>  [%notify town-id.hall.new-town root]
      %+  turn   ~(tap by indexers)
      |=  [=dock @da]
      %+  ~(poke pass:io /indexer-updates)
        dock
      :-  %sequencer-indexer-update
      !>  ^-  indexer-update
      ?.  =(p.dock our.bowl)
        [%notify town-id.hall.new-town root]
      :^  %update  root
        processed-txs.u.pending-batch
      new-town
    ::
        %batch-rejected
      ::  handle pending-batch being invalid
      ::  (working-batch also becomes invalid!)
      ::  TODO reinstantiate mempool from rejected batch..
      ~&  >>>  "%sequencer: pending batch REJECTED"
      `this(pending-batch ~, working-batch ~)
    ::
        %trigger-batch
      ?.  =(%available status)
        ~|("%sequencer: got poke while not active" !!)
      ?~  town
        ~|("%sequencer: no state" !!)
      ::  ?~  rollup
      ::    ~|("%sequencer: no known rollup contract" !!)
      ~&  %sequencer-perform-batch
      ~>  %bout
      ?>  ?=(%full-publish -.mode.hall.u.town)
      =/  addr  p.sequencer.hall.u.town
      =/  our-caller
        (get-our-caller addr town-id.hall.u.town [our now]:bowl)
      ::  process deposits from L1:
      ::  convert deposit bytes into mold, feed into engine
      =/  deposits=(list deposit)
        (turn deposits.act deposit-from-tape)
      ::  if we've already performed a batch, the trigger is
      ::  meant to add further deposits to this batch. this must
      ::  clear outputs in our working-batch, optimistic
      ::  computation of which must be discarded.
      ::  also, deposits will be checked against list of those
      ::  already processed, and only new ones will be computed
      =/  new=state-transition
        %-  %~  run  eng
            :^    our-caller
                town-id.hall.u.town
              batch-num.hall.u.town
            last-batch-block
        ?~  pending-batch
          ::  batch is being triggered fresh
          ::  produce diff and new state with engine
          ::
          [chain.u.town memlist deposits]
        ::  batch is being re-triggered with new deposits:
        ::  add pre-processed txns back in, and run again
        =-  [chain.u.town - deposits]
        %+  turn  processed-txs.u.pending-batch
        |=  [a=@ux b=transaction:smart c=output]
        [a b `c]
      =/  batch=proposed-batch
        :*  +(batch-num.hall.u.town)
            processed.new
            chain.new
            `@ux`(sham ~[modified.new])
            root=->-.p.chain.new  ::  top level merkle root
        ==
      `this(memlist ~, working-batch ~, pending-batch `batch)
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
        ^-  hall
        :*  town-id.act
            batch-num=0
            [address.act our.bowl]
            mode.act
            0x0
            ~[new-root]
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
        private-key    `private-key.act
        town           `town
        status          %available
        working-batch  `[0 ~ chain.town 0x0 new-root]
      ==
    ::
    ::  used in get-eth-block threads -- mostly deprecated
    ::
        %set-block-height-api-key
      ?>  =(src our):bowl
      `state(block-height-api-key `key.act)
    ::
        %del-block-height-api-key
      ?>  =(src our):bowl
      `state(block-height-api-key ~)
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
      ::  only build out next batch in advance if we don't
      ::  have one pending already
      ?^  pending-batch  ~
      :_  ~
      %-  ~(poke-self pass:io /run-single)
      sequencer-town-action+!>([%run-pending ~])
    ::
        %run-pending
      ?>  =(src.bowl our.bowl)
      ?^  pending-batch
        ~&  >>>  "sequencer: waiting for last batch confirmation"
        `state
      ?:  =(~ pending)
        ~&  >  "%sequencer: no pending txns to run"
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
              last-batch-block
            ?~  working-batch
              chain.u.town
            chain.u.working-batch
          (sort-mempool:eng pending)
        ~  ::  only process deposits at batching-time
      =/  processed
        %+  turn  processed.new
        |=  [a=@ux b=transaction:smart c=output]
        [a b `c]
      =/  memlist-lent  (lent memlist)
      :_  %=  state
            pending        ~
            memlist        (weld memlist `^memlist`processed)
            working-batch  `[0 ~ chain.new 0x0 0x0]
          ==
      ::  give out receipts for all transactions just processed
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
