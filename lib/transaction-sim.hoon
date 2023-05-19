/-  spider
/+  strandio, smart=zig-sys-smart, *zig-sys-engine, merk
/*  zigs-contract  %jam  /con/compiled/zigs/jam
=,  strand=strand:spider
|%
+$  test      [=path txn=test-txn]
+$  test-arm  [name=term txn=test-txn]
+$  engine-data
  [sequencer=caller:smart town-id=@ux batch-num=@ud eth-block-height=@ud]
+$  test-txn
  $:  =chain
      =engine-data
      =transaction:smart
      expected=unit-output
  ==
+$  unit-output
  $:  gas=(unit @ud)
      errorcode=(unit errorcode:smart)
      modified=(unit state)
      burned=(unit state)
      events=(unit (list contract-event))
  ==
::
++  tx-fail  [~ `%6 `~ `~ `~]
::
::  constants / dummy info for engine
::
++  big  (bi:merk id:smart item:smart)  ::  merkle engine for granary
++  pig  (bi:merk id:smart @ud)         ::                for populace
++  default-town-id   0x0
++  fake-sig  [0 0 0]
::
::  test data generators for zigs gas token
::
++  zigs
  |%
  ++  addr-1  0xd387.95ec.b77f.b88e.c577.6c20.d470.d13c.8d53.2169
  ++  addr-2  0x75f.da09.d4aa.19f2.2cad.929c.aa3c.aa7c.dca9.5902
  ++  addr-3  0xa2f8.28f2.75a3.28e1.3ba1.25b6.0066.c4ea.399d.88c7
  ++  addr-4  0xface.face.face.face.face.face.face.face.face.face
  ++  id
    |=  holder=id:smart
    %:  hash-data:smart
        zigs-contract-id:smart
        holder
        default-town-id
        `@`'zigs'
    ==
  ++  account
    |=  [holder=id:smart amt=@ud allowances=(list [@ux @ud])]
    ^-  item:smart
    :*  %&  (id holder)
        zigs-contract-id:smart
        holder
        default-town-id
        `@`'zigs'
        %account
        [amt (make-pmap:smart allowances) `@ux`'zigs-metadata' ~]
    ==
  ++  pact
    ^-  item:smart
    =/  code  (cue zigs-contract)
    :*  %|
        zigs-contract-id:smart  ::  id
        zigs-contract-id:smart  ::  source
        zigs-contract-id:smart  ::  holder
        default-town-id
        [-.code +.code]
        ~
    ==
  --
::  produce chain state tree
::
++  make-chain-state
  |=  a=(list item:smart)
  ^-  state:engine
  %+  gas:big  *(merk:merk id:smart item:smart)
  %+  turn  a
  |=  =item:smart
  [id.p.item item]
::
++  check-output
  |=  [res=output exp=unit-output]
  ^-  ?
  ::  for each non-unit aspect in expected, compare to result
  ::
  ~&  "gas paid: {<gas.res>}"
  ?&  ?~  gas.exp  &
        ?:  =(gas.res u.gas.exp)
          ~&  "OK gas"  &
        ~&  >>>  "expected gas {<u.gas.exp>}, got {<gas.res>}"  |
      ?~  errorcode.exp  &
        ?:  =(errorcode.res u.errorcode.exp)
          ~&  "OK errorcode: {<errorcode.res>}"  &
        ~&  >>>  "expected errorcode {<u.errorcode.exp>}, got {<errorcode.res>}"  |
      ?~  modified.exp  &
        ?:  =(modified.res u.modified.exp)
          ~&  "OK modified"  &
        ~&  >>>  "expected modified:"
        ~&  >>>  u.modified.exp
        ~&  >>  "got modified:"
        ~&  >>  modified.res  |
      ?~  burned.exp  &
        ?:  =(burned.res u.burned.exp)
          ~&  "OK burned"  &
        ~&  >>>  "expected burned:"
        ~&  >>>  u.burned.exp
        ~&  >>  "got burned:"
        ~&  >>  burned.res  |
      ?~  events.exp  &
        ?:  =(events.res u.events.exp)
          ~&  "OK events"  &
        ~&  >>>  "expected events:"
        ~&  >>>  u.events.exp
        ~&  >>  "got events:"
        ~&  >>  events.res  |
  ==
::  +resolve-test-paths: add test names to file paths to form full identifiers
::
++  resolve-test-paths
  |=  paths-to-tests=(map path (list test-arm))
  ^-  (list test)
  %-  sort  :_  |=([a=test b=test] !(aor path.a path.b))
  ^-  (list test)
  %-  zing
  %+  turn  ~(tap by paths-to-tests)
  |=  [=path test-arms=(list test-arm)]
  ^-  (list test)
  ::  for each test, add the test's name to :path
  ::
  %+  turn  test-arms
  |=  =test-arm
  ^-  test
  [(weld path /[name.test-arm]) txn.test-arm]
::  +get-test-arms: convert test arms to functions and produce them
::
++  get-test-arms
  |=  [typ=type cor=*]
  ^-  (list test-arm)
  =/  arms=(list @tas)  (sloe typ)
  %+  turn  (skim arms has-test-prefix)
  |=  name=term
  ^-  test-arm
  ::
  =/  fire-arm=nock
    ~|  [%failed-to-compile-test-arm name]
    q:(~(mint ut typ) p:!>(*test-txn) [%limb name])
  [name ;;(test-txn .*(cor fire-arm))]
::  +has-test-prefix: does the arm define a test we should run?
::
++  has-test-prefix
  |=  a=term  ^-  ?
  =((end [3 5] a) 'test-')
::
++  find-test-files
  =|  fiz=(set [=beam test=(unit term)])
  =/  m  (strand ,_fiz)
  |=  bez=(list beam)
  ^-  form:m
  =*  loop  $
  ?~  bez
    (pure:m fiz)
  ;<  hav=?  bind:m  (check-for-file:strandio -.i.bez (snoc s.i.bez %hoon))
  ?:  hav
    loop(bez t.bez, fiz (~(put in fiz) [i.bez(s (snoc s.i.bez %hoon)) ~]))
  ;<  fez=(list path)  bind:m  (list-tree:strandio i.bez)
  ?.  =(~ fez)
    =/  foz
      %+  murn  fez
      |=  p=path
      ?.  =(%hoon (rear p))  ~
      (some [[-.i.bez p] ~])
    loop(bez t.bez, fiz (~(gas in fiz) foz))
  ::
  ::  XX this logic appears to be vestigial
  ::
  =/  tex=term
    ~|  bad-test-beam+i.bez
    =-(?>(((sane %tas) -) -) (rear s.i.bez))
  =/  xup=path  (snip s.i.bez)
  ;<  hov=?  bind:m  (check-for-file:strandio i.bez(s (snoc xup %hoon)))
  ?.  hov
    ~|(no-tests-at-path+i.bez !!)
  loop(bez t.bez, fiz (~(put in fiz) [[-.i.bez (snoc xup %hoon)] `tex]))
--