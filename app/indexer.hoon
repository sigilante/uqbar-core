::  indexer [UQ| DAO]:
::
::  Index blocks
::
::    Receive new blocks, index them,
::    and update subscribers with full blocks
::    or with hashes of interest
::
::
::    ## Scry paths
::
::    Most scry paths accepts one or two @ux arguments.
::    A single argument is interpreted as the hash of the
::    queried item (e.g., for a /grain query, the grain-id).
::    For two arguments, the first is interpreted as the
::    town-id in which to query for the second, the item hash.
::    In other words, two arguments restricts the query to
::    a town, while one argument queries all indexed towns.
::
::
::    /x/batch/[batch-id=@ux]
::    /x/batch/[town-id=@ux]/[batch-id=@ux]:
::      An entire batch.
::    /x/batch-order/[town-id=@ux]
::    /x/batch-order/[town-id=@ux]/[nth-most-recent=@ud]/[how-many=@ud]:
::      The order of batches for a town, or a subset thereof.
::    /x/egg/[egg-id=@ux]:
::    /x/egg/[town-id=@ux]/[egg-id=@ux]:
::      Info about egg (transaction) with the given hash.
::    /x/from/[egg-id=@ux]:
::    /x/from/[town-id=@ux]/[from-id=@ux]:
::      History of sender with the given hash.
::    /x/grain/[grain-id=@ux]:
::    /x/grain/[town-id=@ux]/[grain-id=@ux]:
::      State of grain with given hash.
::    /x/hash/[hash=@ux]:
::    /x/hash/[town-id=@ux]/[hash=@ux]:
::      Info about hash (queries all indexes for hash).
::    /x/holder/[holder-id=@ux]:
::    /x/holder/[town-id=@ux]/[holder-id=@ux]:
::      Grains held by id with given hash.
::    /x/id/[id=@ux]:
::    /x/id/[town-id=@ux]/[id=@ux]:
::      History of id (queries `from`s and `to`s).
::    /x/lord/[lord-id=@ux]:
::    /x/lord/[town-id=@ux]/[lord-id=@ux]:
::      Grains ruled by lord with given hash.
::    /x/to/[to-id=@ux]:
::    /x/to/[town-id=@ux]/[to-id=@ux]:
::      History of receiver with the given hash.
::    /x/town/[town-id=@ux]:
::    /x/town/[town-id=@ux]/[town-id=@ux]:
::      History of town: all batches.
::
::
::    ## Subscription paths
::
::    /grain/[grain-id=@ux]
::    /grain/[town-id=@ux]/[grain-id=@ux]:
::      A stream of changes to given grain.
::      Reply on-watch is entire grain history.
::
::    :: /hash/[@ux]:  ::  TODO: implement
::    ::   A stream of new activity of given id.
::
::    /holder/[holder-id=@ux]
::    /holder/[town-id=@ux]/[holder-id=@ux]:
::      A stream of new activity of given holder.
::      Reply on-watch is entire history of held grains.
::
::    /id/[id=@ux]
::    /id/[town-id=@ux]/[id=@ux]:
::      A stream of new transactions of given id.
::      Reply on-watch is all historical
::      transactions `from` or `to` id.
::
::    /lord/[lord-id=@ux]
::    /lord/[town-id=@ux]/[lord-id=@ux]:
::      A stream of new activity of given lord.
::      Reply on-watch is entire history of ruled grains.
::
::    /town/[town-id=@ux]
::    /town/[town-id=@ux]/[town-id=@ux]:
::      A stream of each new batch for town.
::      Reply on-watch is history of batches in town.
::
::
::    ##  Pokes
::
::    %set-chain-source:
::      Subscribe to source for new blocks.
::
::    :: %consume-indexer-update:  ::  TODO: implement
::    ::   Add a block or chunk to the index.
::
::    :: %serve-update:
::
::
/-  ui=indexer,
    seq=sequencer
/+  agentio,
    dbug,
    default-agent,
    verb,
    indexer-lib=indexer-bowl,
    smart=zig-sys-smart
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  :: $%  base-state-0  ::  TODO: make inflated state real
  $%  state-0
  ==
::
+$  base-state-0
  $:  %0
      =batches-by-town:ui
      =rollup-update-queue:ui
      =sequencer-update-queue:ui
  ==
+$  indices-0
  $:  egg-index=(map @ux (jar @ux egg-location:ui))
      from-index=(map @ux (jar @ux second-order-location:ui))
      grain-index=(map @ux (jar @ux batch-location:ui))
      holder-index=(map @ux (jar @ux second-order-location:ui))
      lord-index=(map @ux (jar @ux second-order-location:ui))
      to-index=(map @ux (jar @ux second-order-location:ui))
  ==
+$  state-0  [base-state-0 indices-0]
::
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this          .
      def           ~(. (default-agent this %|) bowl)
      io            ~(. agentio bowl)
      ui-lib        ~(. indexer-lib bowl)
      indexer-core  +>
      ic            ~(. indexer-core bowl)
  ::
  ++  on-init  `this
  :: ++  on-save  !>(-.state)  ::  TODO: make inflated state real
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    :: ?-  -.old
    ::   %0  `this(state [old *indices-0])  ::  TODO: index old -> indices-0  ::  TODO: make inflated state real
    ?-  -.-.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      ?+    mark  (on-poke:def mark vase)
          %set-sequencer
        %^    set-watch-target:ic
            sequencer-wire
          !<(dock vase)
        sequencer-path
      ::
          %set-rollup
        %^    set-watch-target:ic
            rollup-wire
          !<(dock vase)
        rollup-path
      ::
      ::  TODO: add %consume-update and %serve-update pokes
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L138
      ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
      ::   [%hash @ ~]
      :: :_  this
      :: =/  hash=@ux  (slav %ux i.t.path)
      :: ?~  update=(get-hashes hash)  ~
      :: :_  ~
      :: %-  fact:io
      :: :_  ~
      :: [%indexer-update !>(`update:ui`update)]
    ::
        [%id @ ~]
      :_  this
      =/  hash=@ux  (slav %ux i.t.path)
      ?~  update=(get-ids hash)  ~
      :_  ~
      %-  fact:io
      :_  ~
      [%indexer-update !>(`update:ui`update)]
    ::
        [%id @ @ ~]
      :_  this
      =/  payload=[@ux @ux]
        [(slav %ux i.t.path) (slav %ux i.t.t.path)]
      ?~  update=(get-ids payload)  ~
      :_  ~
      %-  fact:io
      :_  ~
      [%indexer-update !>(`update:ui`update)]
    ::
        ?([%grain @ ~] [%holder @ ~] [%lord @ ~] [%town @ ~])
      :_  this
      =/  query-type=?(%grain %holder %lord %town)  i.path
      =/  hash=@ux  (slav %ux i.t.path)
      ?~  update=(serve-update query-type hash)  ~
      :_  ~
      %-  fact:io
      :_  ~
      [%indexer-update !>(`update:ui`update)]
    ::
        ?([%grain @ @ ~] [%holder @ @ ~] [%lord @ @ ~] [%town @ @ ~])
      :_  this
      =/  query-type=?(%grain %holder %lord %town)  i.path
      =/  payload=[@ux @ux]
        [(slav %ux i.t.path) (slav %ux i.t.t.path)]
      ?~  update=(serve-update query-type payload)  ~
      :_  ~
      %-  fact:io
      :_  ~
      [%indexer-update !>(`update:ui`update)]
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-leave:def path)
        $?  [%grain *]
            :: [%hash @ ~]
            [%holder *]
            [%id *]
            [%lord *]
            [%town *]
        ==
      `this
    ==
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    =/  is-json=?  &(?=([@ @ *] path) =(%json i.t.path))
    |^
    ?+    path  (on-peek:def path)
        ?([%x %hash @ ~] [%x %json %hash @ ~])
      =/  hash=@ux  read-hash-from-path
      =/  =update:ui  (get-hashes hash)
      (make-peek-update update)
    ::
        ?([%x %hash @ @ ~] [%x %json %hash @ @ ~])
      =/  query-payload=[@ux @ux]  read-two-hashes-from-path
      =/  =update:ui  (get-hashes query-payload)
      (make-peek-update update)
    ::
        ?([%x %id @ ~] [%x %json %id @ ~])
      =/  hash=@ux  read-hash-from-path
      =/  =update:ui  (get-ids hash)
      (make-peek-update update)
    ::
        ?([%x %id @ @ ~] [%x %json %id @ @ ~])
      =/  query-payload=[@ux @ux]  read-two-hashes-from-path
      =/  =update:ui  (get-ids query-payload)
      (make-peek-update update)
    ::
        $?  [%x %batch @ ~]   [%x %json %batch @ ~]
            [%x %egg @ ~]     [%x %json %egg @ ~]
            [%x %from @ ~]    [%x %json %from @ ~]
            [%x %grain @ ~]   [%x %json %grain @ ~]
            [%x %holder @ ~]  [%x %json %holder @ ~]
            [%x %lord @ ~]    [%x %json %lord @ ~]
            [%x %to @ ~]      [%x %json %to @ ~]
            [%x %town @ ~]    [%x %json %town @ ~]
        ==
      =/  args=^path  ?.(is-json t.path t.t.path)
      ?.  ?=([@ @ ~] args)  (on-peek:def path)
      =/  =query-type:ui  ;;(query-type:ui i.args)
      =/  hash=@ux  (slav %ux i.t.args)
      =/  =update:ui  (serve-update query-type hash)
      (make-peek-update update)
    ::
        $?  [%x %batch @ @ ~]   [%x %json %batch @ @ ~]
            [%x %egg @ @ ~]     [%x %json %egg @ @ ~]
            [%x %from @ @ ~]    [%x %json %from @ @ ~]
            [%x %grain @ @ ~]   [%x %json %grain @ @ ~]
            [%x %holder @ @ ~]  [%x %json %holder @ @ ~]
            [%x %lord @ @ ~]    [%x %json %lord @ @ ~]
            [%x %to @ @ ~]      [%x %json %to @ @ ~]
            [%x %town @ @ ~]    [%x %json %town @ @ ~]
        ==
      =/  args=^path  ?.(is-json t.path t.t.path)
      ?.  ?=([@ @ @ ~] args)  (on-peek:def path)
      =/  =query-type:ui  ;;(query-type:ui i.args)
      =/  query-payload=[@ux @ux]  read-two-hashes-from-path
      =/  =update:ui  (serve-update query-type query-payload)
      (make-peek-update update)
    ::
        ?([%x %batch-order @ ~] [%x %json %batch-order @ ~])
      =/  town-id=@ux  read-hash-from-path
      :^  ~  ~  %indexer-batch-order
      ?~  bs=(~(get by batches-by-town) town-id)  !>(~)
      !>(`batch-order:ui`batch-order.u.bs)
    ::
        ?([%x %batch-order @ @ @ ~] [%x %json %batch-order @ @ @ ~])
      =/  [town-id=@ux nth-most-recent=@ud how-many=@ud]
        ?.  is-json
          :+  (slav %ux i.t.t.path)  (slav %ud i.t.t.t.path)
          (slav %ud i.t.t.t.t.path)
        ?.  ?=([@ @ @ @ @ @ ~] path)  (on-peek:def path)
        :+  (slav %ux i.t.t.t.path)  (slav %ud i.t.t.t.t.path)
        (slav %ud i.t.t.t.t.t.path)
      :^  ~  ~  %indexer-batch-order
      ?~  bs=(~(get by batches-by-town) town-id)  !>(~)
      !>  ^-  batch-order:ui
      (swag [nth-most-recent how-many] batch-order.u.bs)
    ==
    ::
    ++  make-peek-update
      |=  =update:ui
      ?.  is-json
        [~ ~ %indexer-update !>(`update:ui`update)]
      [~ ~ %json !>(`json`(update:enjs:ui-lib update))]
    ::
    ++  read-hash-from-path
      ^-  @ux
      ?.  is-json
        ?>  ?=([@ @ @ ~] path)
        (slav %ux i.t.t.path)
      ?>  ?=([@ @ @ @ ~] path)
      (slav %ux i.t.t.t.path)
    ::
    ++  read-two-hashes-from-path
      ^-  [@ux @ux]
      ?.  is-json
        ?>  ?=([@ @ @ @ ~] path)
        [(slav %ux i.t.t.path) (slav %ux i.t.t.t.path)]
      ?>  ?=([@ @ @ @ @ ~] path)
      [(slav %ux i.t.t.t.path) (slav %ux i.t.t.t.t.path)]
    --
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    |^  ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
        [%rollup-update ~]
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        =/  old-source=(unit dock)
          (get-wex-dock-by-wire:ic wire)
        ?~  old-source  ~
        :_  ~
        %^    watch-target:ic
            rollup-wire
          u.old-source
        rollup-path
      ::
          %fact
        =^  cards  state
          %-  consume-rollup-update
          !<(rollup-update:seq q.cage.sign)
        [cards this]
      ==
    ::
        [%sequencer-update ~]
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        =/  old-source=(unit dock)
          (get-wex-dock-by-wire:ic wire)
        ?~  old-source  ~
        :_  ~
        %^    watch-target:ic
            sequencer-wire
          u.old-source
        sequencer-path
      ::
          %fact
        =^  cards  state
          %-  consume-sequencer-update
          !<(indexer-update:seq q.cage.sign)
        [cards this]
      ==
    ::
    ::     [%epochs-catchup ~]
    ::   ?+    -.sign  (on-agent:def wire sign)
    ::   ::
    ::       %kick
    ::     `this
    ::   ::
    ::       %fact
    ::     =^  cards  state
    ::       %-  consume-ziggurat-update
    ::       !<(update:zig q.cage.sign)
    ::     [cards this]
    ::   ::
    ::   ==
    ==
    ::
    :: +consume-indexer-update:
    :: https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L697
    ::
    ++  consume-rollup-update
      |=  update=rollup-update:seq
      ^-  (quip card _state)
      ?-    -.update
          %new-peer-root
        =*  town-id  town-id.update
        ?~  town-q=(~(get by sequencer-update-queue) town-id)
          :-  ~
          %=  state
              rollup-update-queue
            %+  ~(put ju rollup-update-queue)  town-id
            root.update
          ==
        ?~  indexer-update=(~(get by u.town-q) root.update)
          :-  ~
          %=  state
              rollup-update-queue
            %+  ~(put ju rollup-update-queue)  town-id
            root.update
          ==
        =^  cards  state
          %^    consume-batch
              root.update
            eggs.u.indexer-update
          town.u.indexer-update
        :-  cards
        %=  state
            sequencer-update-queue
          %+  ~(jab by sequencer-update-queue)  town-id
          |=  town-queue=(map @ux [(list [@ux egg:smart]) town:seq])
          %-  ~(del by town-queue)  root.update
        ==
          %new-sequencer
        `state
      ==
    ::
    ++  consume-sequencer-update
      |=  update=indexer-update:seq
      ^-  (quip card _state)
      ?-    -.update
        :: ~|  "indexer: not consuming unexpected update {<-.update>}"
        :: !!
        ::   %epochs-catchup
        :: =/  =epochs:zig  epochs.update
        :: =|  cards=(list card)
        :: |-
        :: ?~  epochs  [cards state]
        :: =/  epoch  (pop:poc:zig epochs)
        :: =*  epoch-num         num.val.head.epoch
        :: =*  epoch-start-time  start-time.val.head.epoch
        :: =/  =slots:zig  slots.val.head.epoch
        :: =+  ^=  [new-cards new-state]
        ::     |-
        ::     ?~  slots  [cards state]
        ::     =/  slot  (pop:sot:zig slots)
        ::     =+  ^=  [new-cards new-state]
        ::         %^  consume-slot  epoch-num  epoch-start-time
        ::         val.head.slot
        ::     $(slots rest.slot, cards new-cards, state new-state)
        :: $(epochs rest.epoch, cards new-cards, state new-state)
      ::
          %update
        =*  town-id  id.hall.town.update
        ?:  %.  root.update
            %~  has  in
            (~(get ju rollup-update-queue) town-id)
          =^  cards  state
            %^    consume-batch
                root.update
              eggs.update
            town.update
          :-  cards
          %=  state
              rollup-update-queue
            %+  ~(del ju rollup-update-queue)  town-id
            root.update
          ==
        :-  ~
        %=  state
            sequencer-update-queue
          %+  ~(put by sequencer-update-queue)  town-id
          %+  %~  put  by
              ?~  town-q=(~(get by sequencer-update-queue) town-id)
                *(map @ux [(list [@ux egg:smart]) town:seq])
              u.town-q
            root.update
          [eggs.update town.update]
        ==
        :: (consume-batch root.update eggs.update town.update)
      ::
      ::  add %chunk handling? see e.g.
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L923
      ==
    ::
    :: ++  gas-ja
    ::   |=  $:  index=(map town-id=@ux (jar @ux location:ui))
    ::           new=(list [hash=@ux =location:ui])
    ::           town-id=id:smart
    ::       ==
    ::   %+  ~(put by index)  town-id
    ::   =/  town-index=(jar @ux location:ui)
    ::     ?~(ti=(~(get by index) town-id) ~ u.ti)
    ::   |-
    ::   ?~  new  town-index
    ::   %=  $
    ::       new  t.new
    ::       town-index
    ::     (~(add ja town-index) hash.i.new location.i.new)
    ::   ==
    ::
    ++  gas-ja-egg
      |=  $:  index=(map town-id=@ux (jar @ux egg-location:ui))
              new=(list [hash=@ux location=egg-location:ui])
              town-id=id:smart
          ==
      %+  ~(put by index)  town-id
      =/  town-index=(jar @ux egg-location:ui)
        ?~(ti=(~(get by index) town-id) ~ u.ti)
      |-
      ?~  new  town-index
      %=  $
          new  t.new
          town-index
        (~(add ja town-index) hash.i.new location.i.new)
      ==
    ::
    ++  gas-ja-batch
      |=  $:  index=(map town-id=@ux (jar @ux batch-location:ui))
              new=(list [hash=@ux location=batch-location:ui])
              town-id=id:smart
          ==
      %+  ~(put by index)  town-id
      =/  town-index=(jar @ux batch-location:ui)
        ?~(ti=(~(get by index) town-id) ~ u.ti)
      |-
      ?~  new  town-index
      %=  $
          new  t.new
          town-index
        (~(add ja town-index) hash.i.new location.i.new)
      ==
    ::
    ++  gas-ja-second-order
      |=  $:  index=(map town-id=@ux (jar @ux second-order-location:ui))
              new=(list [hash=@ux location=second-order-location:ui])
              town-id=id:smart
          ==
      %+  ~(put by index)  town-id
      =/  town-index=(jar @ux second-order-location:ui)
        ?~(ti=(~(get by index) town-id) ~ u.ti)
      |-
      ?~  new  town-index
      %=  $
          new  t.new
          town-index
        (~(add ja town-index) hash.i.new location.i.new)
      ==
    ::
    ++  consume-batch
      |=  [root=@ux eggs=(list [@ux egg:smart]) =town:seq]
      ^-  (quip card _state)
      =*  town-id  id.hall.town
      =+  ^=  [egg from grain holder lord to]
          (parse-batch root town-id eggs land.town)
      :: =:  egg-index     (gas-ja egg-index egg town-id)
      ::     from-index    (gas-ja from-index from town-id)
      ::     grain-index   (gas-ja grain-index grain town-id)
      ::     holder-index  (gas-ja holder-index holder town-id)
      ::     lord-index    (gas-ja lord-index lord town-id)
      ::     to-index      (gas-ja to-index to town-id)
      =:  egg-index     (gas-ja-egg egg-index egg town-id)
          from-index    (gas-ja-second-order from-index from town-id)
          grain-index   (gas-ja-batch grain-index grain town-id)
          holder-index  (gas-ja-second-order holder-index holder town-id)
          lord-index    (gas-ja-second-order lord-index lord town-id)
          to-index      (gas-ja-second-order to-index to town-id)
          batches-by-town
        %+  ~(put by batches-by-town)  town-id
        ?~  b=(~(get by batches-by-town) town-id)
          :_  ~[root]
          (malt ~[[root [now.bowl eggs town]]])  ::  TODO: improve timestamping
        :_  [root batch-order.u.b]
        (~(put by batches.u.b) root [now.bowl eggs town])
      ==
      |^
      [make-all-sub-cards state]
      ::
      ++  make-sub-paths
        ^-  (jug @tas @u)
        %-  ~(gas ju *(jug @tas @u))
        %+  turn  ~(val by sup.bowl)
        |=  [ship sub-path=path]
        ^-  [@tas @u]
        :-  `@tas`-.sub-path
        (slav %ux -.+.sub-path)
      ::
      ++  make-all-sub-cards
        ^-  (list card)
        =/  sub-paths=(jug @tas @u)  make-sub-paths
        |^
        %-  zing
        :~  :: (make-sub-cards %ux ~ %batch /batch)
            (make-sub-cards %from /id)
            (make-sub-cards %to /id)
            (make-sub-cards %grain /grain)
            (make-sub-cards %holder /holder)
            (make-sub-cards %lord /lord)
            (make-sub-cards %town /town)
        ==
        ::
        ++  make-sub-cards
          |=  [=query-type:ui path-prefix=path]
          ^-  (list card)
          ::  for id-based subscriptions, get cards from both from and to
          =/  path-type
            ?:(?=(?(%from %to) query-type) %id query-type)
          %+  murn  ~(tap in (~(get ju sub-paths) path-type))
          |=  payload=@u
          ::  TODO: can improve performance here by:
          ::  * call get-locations
          ::  * handle second-order-locations
          ::  * compare batch-root with first element of batch-order
          ::  * same -> got diff; different -> pass
          =/  =update:ui  (serve-update query-type payload)
          ?~  update  ~
          ::  is update timestamped now?
          ?:  ?=(?(%batch %egg) -.update)
            ?.  %-  %~  any  by
                    ?-  -.update
                      %batch  batches.update
                      %egg    eggs.update
                    ==
                |=  [timestamp=@da *]
                =(now.bowl timestamp)
              ~
            :-  ~
            %+  fact:io
              [%indexer-update !>(`update:ui`update)]
            ~[(snoc path-prefix (scot %ux payload))]
          ?.  ?=(%grain -.update)  ~
          =.  grains.update
            %-  ~(gas by *(jar id:smart [@da batch-location:ui grain:smart]))
            %+  murn  ~(tap by grains.update)
            |=  [=id:smart gs=(list [@da batch-location:ui grain:smart])]
            ?~(gs ~ `[id ~[i.gs]])
          =/  timestamp-index=(unit @ud)
            %+  find  [now.bowl]~
            %+  turn
              ^-  (list [@da batch-location:ui grain:smart])
              (zing ~(val by grains.update))
            |=  [timestamp=@da *]
            timestamp
          ?~  timestamp-index  ~
          :-  ~
          %+  fact:io
            [%indexer-update !>(`update:ui`update)]
          ~[(snoc path-prefix (scot %ux payload))]
        ::
        ++  are-updates-same
          ::  %.y if non-location portion of update is same
          ::  %.n if different
          |=  [p=update:ui q=update:ui]
          |^  ^-  ?
          ?~  p  ?=(~ q)
          ?~  q  %.n
          ?+    -.p  !!
              %batch
            ?.  ?=(%batch -.q)  %.n
            .=  (make-id-batch-set batches.p)
            (make-id-batch-set batches.q)
          ::
              %egg
            ?.  ?=(%egg -.q)  %.n
            .=  (make-id-egg-set eggs.p)
            (make-id-egg-set eggs.q)
          ::
              %grain
            ?.  ?=(%grain -.q)  %.n
            .=  (make-id-grain-set grains.p)
            (make-id-grain-set grains.q)
          ==
          ::
          ++  make-id-batch-set
            |=  batches=(map id:smart [@da town-location:ui batch:ui])
            ^-  (set [id:smart batch:ui])
            %-  silt
            %+  turn  ~(tap by batches)
            |=  [=id:smart @da town-location:ui =batch:ui]
            [id batch]
          ::
          ++  make-id-egg-set
            |=  eggs=(map id:smart [@da egg-location:ui egg:smart])
            ^-  (set [id:smart egg:smart])
            %-  silt
            %+  turn  ~(tap by eggs)
            |=  [=id:smart @da egg-location:ui =egg:smart]
            [id egg]
          ::
          ++  make-id-grain-set
            |=  grains=(jar id:smart [@da batch-location:ui grain:smart])
            ^-  (set [id:smart grain:smart])
            %-  ~(gas in *(set [id:smart grain:smart]))
            %-  zing
            %+  turn  ~(tap by grains)
            |=  [=id:smart gs=(list [@da batch-location:ui grain:smart])]
            %+  turn  gs
            |=  [@da batch-location:ui =grain:smart]
            [id grain]
          --
        --
      --
    ::
    ++  parse-batch
      |=  [root=@ux town-id=@ux eggs=(list [@ux egg:smart]) =land:seq]
      ^-  $:  (list [@ux egg-location:ui])
              (list [@ux second-order-location:ui])
              (list [@ux batch-location:ui])
              (list [@ux second-order-location:ui])
              (list [@ux second-order-location:ui])
              (list [@ux second-order-location:ui])
          ==
      =*  granary  p.land
      =+  [new-grain new-holder new-lord]=(parse-granary root town-id granary)
      =+  [new-egg new-from new-to]=(parse-transactions root town-id eggs)
      [new-egg new-from new-grain new-holder new-lord new-to]
    ::
    ++  parse-granary
      |=  [root=@ux town-id=@ux =granary:seq]
      ^-  $:  (list [@ux batch-location:ui])
              (list [@ux second-order-location:ui])
              (list [@ux second-order-location:ui])
          ==
      =|  parsed-grain=(list [@ux batch-location:ui])
      =|  parsed-holder=(list [@ux second-order-location:ui])
      =|  parsed-lord=(list [@ux second-order-location:ui])
      =/  grains=(list [@ux grain:smart])
        ~(tap by granary)
      |-
      ?~  grains  [parsed-grain parsed-holder parsed-lord]
      =*  grain-id   id.i.grains
      =*  holder-id  holder.i.grains
      =*  lord-id    lord.i.grains
      %=  $
          grains  t.grains
          parsed-grain
        :_  parsed-grain
        :-  grain-id
        [town-id root]
      ::
          parsed-holder
        [[holder-id grain-id] parsed-holder]
      ::
          parsed-lord
        [[lord-id grain-id] parsed-lord]
      ==
    ::
    ++  parse-transactions
      |=  [root=@ux town-id=@ux txs=(list [@ux egg:smart])]
      ^-  $:  (list [@ux egg-location:ui])
              (list [@ux second-order-location:ui])
              (list [@ux second-order-location:ui])
          ==
      =|  parsed-egg=(list [@ux egg-location:ui])
      =|  parsed-from=(list [@ux second-order-location:ui])
      =|  parsed-to=(list [@ux second-order-location:ui])
      =/  egg-num=@ud  0
      |-
      ?~  txs  [parsed-egg parsed-from parsed-to]
      =*  tx-hash  -.i.txs
      =*  egg      +.i.txs
      =*  to       to.p.egg
      =*  from
        ?:  ?=(@ux from.p.egg)  from.p.egg
        id.from.p.egg
      =/  =egg-location:ui  [town-id root egg-num]
      %=  $
          txs          t.txs
          parsed-egg   [[tx-hash egg-location] parsed-egg]
          parsed-from  [[from tx-hash] parsed-from]
          parsed-to    [[to tx-hash] parsed-to]
          egg-num      +(egg-num)
      ==
    --
  ::
  ++  on-arvo  on-arvo:def
  ++  on-fail  on-fail:def
  --
::
|_  =bowl:gall
+*  io  ~(. agentio bowl)
::
++  epochs-catchup-wire
  ^-  wire
  /epochs-catchup
::
++  rollup-wire
  ^-  wire
  /rollup-update
::
++  sequencer-wire
  ^-  wire
  /sequencer-update
::
++  rollup-path
  ^-  path
  /peer-root-updates
::
++  sequencer-path
  ^-  path
  /indexer/updates
::
++  get-epoch-catchup
  |=  d=dock
  ^-  card
  %+  ~(watch pass:io epochs-catchup-wire)
  d  /validator/epoch-catchup/0
::
++  watch-target
  |=  [w=wire d=dock p=path]
  ^-  card
  (~(watch pass:io w) d p)
::
++  leave-wire
  |=  w=wire
  ^-  (unit card)
  =/  old-source=(unit dock)
    (get-wex-dock-by-wire w)
  ?~  old-source  ~
  :-  ~
  %-  ~(leave pass:io w)
  u.old-source
::
++  set-watch-target
  |=  [w=wire d=dock p=path]
  ^-  (quip card _state)
  =/  watch-card=card  (watch-target w d p)
  :_  state
  =/  leave-card=(unit card)  (leave-wire w)
  ?~  leave-card
    :: ~[(get-epoch-catchup d) watch-card]
    ~[watch-card]
  ~[u.leave-card watch-card]
::
++  get-wex-dock-by-wire
  |=  w=wire
  ^-  (unit dock)
  ?:  =(0 ~(wyt by wex.bowl))  ~
  =/  wexs=(list [w=wire s=ship t=term])
    ~(tap in ~(key by wex.bowl))
  |-
  ?~  wexs  ~
  =*  wex  i.wexs
  ?.  =(w w.wex)
    $(wexs t.wexs)
  :-  ~
  [s.wex t.wex]
::
++  get-batch
  |=  [town-id=id:smart batch-root=id:smart]
  ^-  (unit [@da batch:ui])
  ?~  bs=(~(get by batches-by-town) town-id)  ~
  ?~  b=(~(get by batches.u.bs) batch-root)   ~
  `u.b
::
++  combine-egg-updates
  |=  updates=(list update:ui)
  ^-  update:ui
  ?~  update=(combine-egg-updates-to-map updates)  ~
  [%egg update]
::
++  get-ids
  |=  =query-payload:ui
  ^-  update:ui
  =/  from=update:ui  (serve-update %from query-payload)
  =/  to=update:ui    (serve-update %to query-payload)
  (combine-egg-updates ~[from to])
::
++  get-hashes
  |=  =query-payload:ui
  ^-  update:ui
  =/  batch=update:ui   (serve-update %batch query-payload)
  =/  egg=update:ui     (serve-update %egg query-payload)
  =/  from=update:ui    (serve-update %from query-payload)
  =/  grain=update:ui   (serve-update %grain query-payload)
  =/  holder=update:ui  (serve-update %holder query-payload)
  =/  lord=update:ui    (serve-update %lord query-payload)
  =/  to=update:ui      (serve-update %to query-payload)
  =/  town=update:ui    (serve-update %town query-payload)
  %^  combine-updates  ~[batch town]  ~[egg from to]
  ~[grain holder lord]
::
++  combine-batch-updates-to-map
  |=  updates=(list update:ui)
  ^-  (map id:smart [@da town-location:ui batch:ui])
  ?~  updates  ~
  %-  %~  gas  by
      *(map id:smart [@da town-location:ui batch:ui])
  %-  zing
  %+  turn  updates
  |=  =update:ui
  ?~  update               ~
  ?.  ?=(%batch -.update)  ~
  ~(tap by batches.update)
::
++  combine-egg-updates-to-map
  |=  updates=(list update:ui)
  ^-  (map id:smart [@da egg-location:ui egg:smart])
  ?~  updates  ~
  %-  %~  gas  by
      *(map id:smart [@da egg-location:ui egg:smart])
  %-  zing
  %+  turn  updates
  |=  =update:ui
  ?~  update             ~
  ?.  ?=(%egg -.update)  ~
  ~(tap by eggs.update)
::
++  combine-grain-updates-to-jar  ::  TODO: can this clobber?
  |=  updates=(list update:ui)
  ^-  (jar id:smart [@da batch-location:ui grain:smart])
  ?~  updates  ~
  %-  %~  gas  by
      *(jar id:smart [@da batch-location:ui grain:smart])
  %-  zing
  %+  turn  updates
  |=  =update:ui
  ?~  update               ~
  ?.  ?=(%grain -.update)  ~
  ~(tap by grains.update)
::
:: ++  combine-updates-to-map
::   |=  [updates=(list update:ui) type=?(%batch %egg %grain)]
::   =/  map-type
::     %+  map  id:smart
::     :-  @da
::     ?-  type
::       %batch  [town-location:ui batch:ui]
::       %egg    [egg-location:ui egg:smart]
::       %grain  [batch-location:ui grain:smart]
::     ==
::   ^-  map-type
::   ?~  updates  ~
::   =/  combined=map-type
::     %-  ~(gas by *map-type)
::     %-  zing
::     %+  turn  updates
::     |=  =update:ui
::     ?~  update            ~
::     ?.  =(type -.update)  ~  ::  TODO: works? if yes, get rid of +combine-*-updates-to-map
::     ~(tap by +.update)
::   combined
::
++  combine-updates
  |=  $:  batch-updates=(list update:ui)
          egg-updates=(list update:ui)
          grain-updates=(list update:ui)
      ==
  ^-  update:ui
  ?:  ?&  ?=(~ batch-updates)
          ?=(~ egg-updates)
          ?=(~ grain-updates)
      ==
    ~
  =/  combined-batch=(map id:smart [@da town-location:ui batch:ui])
    (combine-batch-updates-to-map batch-updates)
  =/  combined-egg=(map id:smart [@da egg-location:ui egg:smart])
    (combine-egg-updates-to-map egg-updates)
  =/  combined-grain=(jar id:smart [@da batch-location:ui grain:smart])
    (combine-grain-updates-to-jar grain-updates)
  :: =/  combined-batch=(map id:smart [@da town-location:ui batch:ui])
  ::   (combine-updates-to-map batch-updates %batch)
  :: =/  combined-egg=(map id:smart [@da egg-location:ui egg:smart])
  ::   (combine-updates-to-map egg-updates %egg)
  :: =/  combined-grain=(map id:smart [@da batch-location:ui grain:smart])
  ::   (combine-updates-to-map grain-updates %grain)
  ?:  ?&  ?=(~ combined-batch)
          ?=(~ combined-egg)
          ?=(~ combined-grain)
      ==
    ~
  [%hash combined-batch combined-egg combined-grain]
::
++  serve-update
  |=  [=query-type:ui =query-payload:ui]
  |^  ^-  update:ui
  ?+    query-type  !!
      %batch
    get-batch-update
  ::
      ?(%egg %from %grain %holder %lord %to)
    get-from-index
  ::
      %town
    get-town
  ==
  ::
  ++  get-town
    ?.  ?=(@ query-payload)  ~
    =*  town-id  query-payload
    ?~  bs=(~(get by batches-by-town) town-id)  ~
    :-  %batch
    %-  %~  gas  by
        *(map id:smart [@da town-location:ui batch:ui])
    %+  turn  ~(tap by batches.u.bs)
    |=  [batch-id=id:smart timestamp=@da =batch:ui]
    [batch-id [timestamp town-id batch]]
  ::
  ++  get-batch-update
    ?:  ?=([@ @] query-payload)
      =*  town-id   -.query-payload
      =*  batch-id  +.query-payload
      ?~  b=(get-batch town-id batch-id)  ~
      =*  timestamp  -.u.b
      =*  batch      +.u.b
      :-  %batch
      %+  %~  put  by
          *(map id:smart [@da town-location:ui batch:ui])
      batch-id  [timestamp town-id batch]
    ?.  ?=(@ query-payload)  ~
    =*  batch-id  query-payload
    =/  out=[%batch (map id:smart [@da town-location:ui batch:ui])]
      %+  roll  ~(tap by batches-by-town)
      |=  $:  [town-id=id:smart =batches:ui batch-order:ui]
              out=[%batch (map id:smart [@da town-location:ui batch:ui])]
          ==
      ?~  b=(~(get by batches) batch-id)  out
      =*  timestamp  -.u.b
      =*  batch      +.u.b
      :-  %batch
      (~(put by +.out) batch-id [timestamp town-id batch])
    ?~(+.out ~ out)
  ::
  ++  get-from-index
    ^-  update:ui
    ?.  ?=(?(@ [@ @]) query-payload)  ~
    =/  locations=(list location:ui)  get-locations
    |^
    ?+    query-type  !!
        %grain
      get-grain
    ::
        %egg
      get-egg
    ::
        ?(%from %holder %lord %to)
      get-second-order
    ==
    ::
    ++  get-grain
      =|  grains=(jar grain-id=id:smart [@da batch-location:ui grain:smart])
      =/  grain-id=id:smart
        ?:  ?=([@ @] query-payload)  +.query-payload
        ?>  ?=(@ query-payload)
        query-payload
      =.  locations  (flop locations)
      |-
      ?~  locations  ?~(grains ~ [%grain grains])
      =*  location  i.locations
      ?.  ?=(batch-location:ui location)
        $(locations t.locations)
      =*  town-id     town-id.location
      =*  batch-root  batch-root.location
      ?~  b=(get-batch town-id batch-root)
        $(locations t.locations)
      =*  timestamp  -.u.b
      =*  granary    p.land.+.u.b
      ?~  grain=(~(get by granary) grain-id)
        $(locations t.locations)
      %=  $
          locations  t.locations
          grains
        %+  ~(add ja grains)  grain-id
        [timestamp location u.grain]
      ==
    ::
    ++  get-egg
      =|  eggs=(map id:smart [@da egg-location:ui egg:smart])
      |-
      ?~  locations  ?~(eggs ~ [%egg eggs])
      =*  location  i.locations
      ?.  ?=(egg-location:ui location)
        $(locations t.locations)
      =*  town-id     town-id.location
      =*  batch-root  batch-root.location
      =*  egg-num     egg-num.location
      ?~  b=(get-batch town-id batch-root)
        $(locations t.locations)
      =*  timestamp  -.u.b
      =*  txs        transactions.+.u.b
      ?.  (lth egg-num (lent txs))  $(locations t.locations)
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      %=  $
          locations  t.locations
          eggs
        (~(put by eggs) hash [timestamp location egg])
      ==
    ::
    ++  get-second-order
      %+  roll  locations
      |=  $:  second-order-id=location:ui
              out=update:ui
          ==
      =/  next-update=update:ui
        %=  get-from-index
            query-payload  second-order-id
            query-type
          ?:  |(?=(%holder query-type) ?=(%lord query-type))
            %grain
          %egg
        ==
      ?~  next-update  out
      ?~  out          next-update
      ?+  -.out  ~|("indexer: get-second-order unexpected update type {<-.out>}" !!)
          %egg
        ?.  ?=(%egg -.next-update)  out
        %=  out
            eggs
          (~(uni by eggs.out) eggs.next-update)
        ==
      ::
          %grain
        ?.  ?=(%grain -.next-update)  out
        %=  out
            grains
          (~(uni by grains.out) grains.next-update)  ::  TODO: can this clobber?
        ==
      ==
    --
  ::
  ++  get-locations
    |^  ^-  (list location:ui)
    ?+    query-type  ~|("indexer: get-locations unexpected query-type {<query-type>}" !!)
        %egg
      (get-by-get-ja egg-index query-payload)
    ::
        %from
      (get-by-get-ja from-index query-payload)
    ::
        %grain
      (get-by-get-ja grain-index query-payload)
    ::
        %holder
      (get-by-get-ja holder-index query-payload)
    ::
        %lord
      (get-by-get-ja lord-index query-payload)
    ::
        %to
      (get-by-get-ja to-index query-payload)
    ==
    ::
    ++  get-by-get-ja
      |=  [index=(map @ux (jar @ux location:ui)) =query-payload:ui]
      ^-  (list location:ui)
      ?:  ?=([@ @] query-payload)
        =*  town-id    -.query-payload
        =*  item-hash  +.query-payload
        ?~  town-index=(~(get by index) town-id)  ~
        (~(get ja u.town-index) item-hash)
      ?.  ?=(@ query-payload)  ~
      =*  item-hash  query-payload
      %+  roll  ~(val by index)
      |=  [town-index=(jar @ux location:ui) out=(list location:ui)]
      (weld out (~(get ja town-index) item-hash))
    --
  --
--
