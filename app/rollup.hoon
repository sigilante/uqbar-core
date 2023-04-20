::  rollup [UQ| DAO]
::
::  Agent that simulates a rollup contract on another chain.
::  Receives state transitions (moves) for towns, verifies them,
::  and allows sequencer ships to continue processing batches.
::
/+  default-agent, dbug, verb, io=agentio, ethereum,
    *zig-sequencer, *zig-rollup, eng=zig-sys-engine
|%
+$  card  card:agent:gall
+$  state-1
  $:  %1
      =capitol
      status=?(%available %off)
  ==
::
+$  state-2
  $:  %2
      last-update-time=@da     ::  saved to compare against tracker acks
      trackers=(map dock @da)  ::  indexers and sequencers receiving updates
      =capitol
      status=?(%available %off)
  ==
--
::
=|  state-2
=*  state  -
::
%-  agent:dbug
::  %+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this(state *state-2)
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ?+    -.q.old-vase  on-init
      %2
    `this(state !<(state-2 old-vase))
      %1
    `this(state [%2 *@da *(map dock @da) +:!<(state-1 old-vase)])
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  ~|("%rollup: error: got erroneous %poke" !!)
      %tracker-request
    ::  TODO use app-src here instead of putting it inside poke
    `this(trackers (~(put by trackers) [src.bowl !<(@tas vase)] now.bowl))
  ::
      %tracker-stop
    ::  TODO use app-src here instead of putting it inside poke
    `this(trackers (~(del by trackers) [src.bowl !<(@tas vase)]))
  ::
      %rollup-action
    ::  whitelist: only designated sequencers can interact
    ?>  (allowed-participant [src our now]:bowl)
    =^  cards  state
      (handle-poke !<(action vase))
    [cards this]
  ==
  ::
  ++  handle-poke
    |=  act=action
    ^-  (quip card _state)
    ?-    -.act
        %activate
      `state(status %available)
    ::
        %launch-town
      ::  create new hall
      ?<  (~(has by capitol) town-id.hall.act)
      ::  TODO remove starting-state from init and populate new towns via
      ::  assets from other towns
      =/  first-root  `@ux`(sham chain.act)
      ::  assert signature matches
      =/  recovered
        %-  address-from-pub:key:ethereum
        %-  serialize-point:secp256k1:secp:crypto
        %+  ecdsa-raw-recover:secp256k1:secp:crypto
        first-root  sig.act
      ?.  =(from.act recovered)
        ~|("%rollup: rejecting new town; sequencer signature not valid" !!)
      ::  remove trackers that haven't acked since last update
      =.  trackers
        %-  malt
        %+  skim  ~(tap by trackers)
        |=  [dock last-ack=@da]
        (gth last-ack last-update-time)
      =+  (~(put by capitol) town-id.hall.act hall.act(roots ~[first-root]))
      :_  state(capitol -)
      (give-rollup-updates - town-id.hall.act first-root now.bowl)
    ::
        %bridge-assets
      ::  for simulation purposes
      ?~  hall=(~(get by capitol.state) town-id.act)  !!
      :_  state
      =+  [%town-action !>([%receive-assets assets.act])]
      [%pass /bridge %agent [q.sequencer.u.hall %sequencer] %poke -]~
    ::
        %receive-batch
      ?~  hall=(~(get by capitol.state) town-id.act)
        ~|("%rollup: rejecting batch; town not found" !!)
      ?.  =([from.act src.bowl] sequencer.u.hall)
        ~|("%rollup: rejecting batch; sequencer doesn't match town" !!)
      =/  recovered
        %-  address-from-pub:key:ethereum
        %-  serialize-point:secp256k1:secp:crypto
        %+  ecdsa-raw-recover:secp256k1:secp:crypto
        new-root.act  sig.act
      ?.  =(from.act recovered)
        ~|("%rollup: rejecting batch; sequencer signature not valid" !!)
      ?.  =(diff-hash.act (sham state-diffs.act))
        ~|("%rollup: rejecting batch; diff hash not valid" !!)
      ::  check that other town state roots are up-to-date
      ::  recent-enough is a variable here that can be adjusted
      =/  recent-enough  2
      ?.  %+  levy
            %+  turn  ~(tap by peer-roots.act)
            |=  [=id:smart root=@ux]
            ?~  hall=(~(get by capitol.state) id)  %.n
            =+  ?:  (lte (lent roots.u.hall) recent-enough)
                  roots.u.hall
                (slag recent-enough roots.u.hall)
            ?~  (find [root]~ -)
              %.n
            %.y
          |=(a=? a)
        ~|("%rollup: rejecting batch; peer roots not recent enough" !!)
      ?:  ?=(%committee -.mode.act)
        ::  handle DAC, TODO
        ::
        !!
      ::  handle full-publish mode
      ::
      =+  %=  u.hall
            latest-diff-hash  diff-hash.act
            roots  (snoc roots.u.hall new-root.act)
          ==
      ::  remove trackers that haven't acked since last update
      =.  trackers
        %-  malt
        %+  skim  ~(tap by trackers)
        |=  [dock last-ack=@da]
        (gth last-ack last-update-time)
      =+  (~(put by capitol) town-id.act -)
      :_  state(capitol -)
      (give-rollup-updates [- town-id.act new-root.act now.bowl])
    ==
  ::
  ++  give-rollup-updates
    |=  [=^capitol town=@ux root=@ux now=@da]
    ^-  (list card)
    =/  trackers  ~(tap by trackers)
    %+  weld
      %+  turn  trackers
      |=  [=dock @da]
      %+  ~(poke pass:io /rollup-updates/[q.dock])
        dock
      :-  %rollup-update
      !>(`rollup-update`[%new-peer-root town root now])
    %+  turn  trackers
    |=  [=dock @da]
    %+  ~(poke pass:io /rollup-updates/[q.dock])
      dock
    :-  %rollup-update
    !>(`rollup-update`[%new-capitol capitol])
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%status ~]
    ``noun+!>(status.state)
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%rollup-updates @ ~]
    ::  catalog poke-acks from trackers
    ::  TODO get app from bowl
    =/  app  `@tas`i.t.wire
    ?.  ?=(%poke-ack -.sign)  `this
    ?^  p.sign
      ::  tracker failed on poke, remove them from trackers
      `this(trackers (~(del by trackers) [src.bowl app]))
    ::  put ack-time in tracker map
    `this(trackers (~(put by trackers) [src.bowl app] now.bowl))
  ==
::
++  on-watch  on-watch:def
++  on-arvo   on-arvo:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
