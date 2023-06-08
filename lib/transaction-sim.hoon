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
  ++  addr-1  0xc2b5.5ddf.1ca6.c126.6a62.f178.39d9.5c0a.1ffd.fa9f
  ++  addr-2  0xabdc.3d01.ca62.692d.cd20.dfde.b93e.8891.ef69.43a1
  ++  addr-3  0x525c.8ddc.0707.4917.dd3b.492a.5a24.cccf.96a6.8b54
  ++  addr-4  0x2c9a.d6fc.4e14.5199.c64b.0d6d.0d48.41f8.4d45.55fe
  ::
  ::  private-keys for these addresses, only for testing
  ::
  ++  priv-1  0x4989.cbf4.1d0e.9e42.f945.705d.ad15.1d54.36be.944c.8caa.3acf.3578.26f7.9fa3.ec98
  ++  priv-2  0x90c7.a2b9.50ac.a8c9.c178.2eac.41ed.1345.47b4.0bcd.314d.1a2e.d9d6.a2e9.4ec4.b5dc
  ++  priv-3  0x30ce.cf28.4ae5.0175.eb32.707f.fcfc.b098.3492.567f.a0cd.a27f.d32b.1967.4701.663e
  ++  priv-4  0x49c7.d462.0a04.849c.8f8f.d875.a446.c3fe.dd6d.4b19.3c45.ecc8.b16a.c955.ca97.1074
  ::
  ::  seed: 
  ::  must meat cinnamon borrow candy immense slush adapt repair aware evidence item make order cry twenext library index forget
  ::
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