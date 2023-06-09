::
::  tests for lib/zig/sys/engine.hoon
::
/+  *test, smart=zig-sys-smart, *zig-sys-engine, merk
/*  smart-lib-noun          %noun  /lib/zig/sys/smart-lib/noun
/*  nft-contract            %jam   /con/compiled/nft/jam
/*  fung-contract           %jam   /con/compiled/fungible/jam
/*  zigs-contract           %jam   /con/compiled/zigs/jam
/*  aa-contract             %jam   /con/compiled/account/jam
/*  engine-tester-contract  %jam   /con/compiled/engine-tester/jam
=>
|%
::
::  constants / dummy info for mill
::
++  big  (bi:merk id:smart item:smart)  ::  merkle engine for granary
++  pig  (bi:merk id:smart @ud)         ::                for populace
++  town-id   0x0
++  fake-sig  [0 0 0]
++  eng
  %~  engine  engine
  :+  !<(vase [-:!>(*vase) (cue q.q.smart-lib-noun)])  ::  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  jets:zink  %.n  ::  sigs off
::
::  fake data
::
::  separate addresses necessary to avoid circular definitions in zigs
++  sequencer-address  0x24c.23b9.8535.cd5a.0645.5486.69fb.afbf.095e.fcc0
++  address-1          0xd387.95ec.b77f.b88e.c577.6c20.d470.d13c.8d53.2169
++  address-2          0x75f.da09.d4aa.19f2.2cad.929c.aa3c.aa7c.dca9.5902
++  address-3          0xa2f8.28f2.75a3.28e1.3ba1.25b6.0066.c4ea.399d.88c7
++  uethereum          0xeeee.eeee.eeee.eeee.eeee.eeee.eeee.eeee.eeee.eeee
++  bridge-pact        0x7abb.3cfe.50ef.afec.95b7.aa21.4962.e859.87a0.b22b.ec9b.3812.69d3.296b.24e1.d72a
++  nft-bridge-pact    0xc7ac.2b08.6748.221b.8628.3813.5875.3579.01d9.2bbe.e6e8.d385.f8c3.b801.84fc.00ae
++  caller-1   `caller:smart`[address-1 1 id.p:account-1:zigs]
++  caller-2   `caller:smart`[address-2 1 id.p:account-2:zigs]
++  caller-3   `caller:smart`[address-3 6 id.p:account-3:zigs]
++  sequencer  `caller:smart`[sequencer-address 1 id.p:sequencer-account:zigs]
::
++  zigs
  |%
  ++  pact
    ^-  item:smart
    :*  %|
        zigs-contract-id:smart  ::  id
        zigs-contract-id:smart  ::  source
        zigs-contract-id:smart  ::  holder
        town-id
        [- +]:(cue zigs-contract)
        ~
    ==
  ++  sequencer-account
    ^-  item:smart
    :*  %&
        (hash-data zigs-contract-id:smart sequencer-address town-id `@`'zigs')
        zigs-contract-id:smart
        sequencer-address
        town-id
        `@`'zigs'
        %account
        [1.000.000 ~ `@ux`'zigs-metadata' ~]
    ==
  ++  zig-account
    |=  [holder=id:smart amt=@ud]
    ^-  item:smart
    :*  %&
        (hash-data zigs-contract-id:smart holder town-id `@`'zigs')
        zigs-contract-id:smart
        holder
        town-id
        `@`'zigs'  %account
        [amt ~ `@ux`'zigs-metadata' ~]
    ==
  ++  account-1
    ^-  item:smart
    :*  %&
        (hash-data zigs-contract-id:smart address-1 town-id `@`'zigs')
        zigs-contract-id:smart
        address-1
        town-id
        `@`'zigs'
        %account
        [300.000.000 ~ `@ux`'zigs-metadata' ~]
    ==
  ++  account-2
    ^-  item:smart
    :*  %&
        (hash-data zigs-contract-id:smart address-2 town-id `@`'zigs')
        zigs-contract-id:smart
        address-2
        town-id
        `@`'zigs'
        %account
        [200.000 ~ `@ux`'zigs-metadata' ~]
    ==
  ++  account-3
    ^-  item:smart
    :*  %&
        (hash-data zigs-contract-id:smart address-3 town-id `@`'zigs')
        zigs-contract-id:smart
        address-3
        town-id
        `@`'zigs'
        %account
        [100.000 ~ `@ux`'zigs-metadata' ~]
    ==
  --
::
++  ueth :: can be any token bridged from L1
  |%
  ++  pact
    ^-  item:smart
    :*  %|
        bridge-pact  ::  id
        bridge-pact  ::  source
        bridge-pact  ::  holder
        town-id
        [- +]:(cue fung-contract)
        ~
    ==
  ++  account-1
    ^-  item:smart
    :*  %&
        (hash-data bridge-pact address-1 town-id uethereum)
        bridge-pact
        address-1
        town-id
        uethereum
        %account
        [300.000.000 ~ `@ux`'bridge-metadata' ~]
    ==
  --
::
++  nft
  |%
  ++  l1-address
    0xbbbb.bbbb.bbbb.bbbb.bbbb.bbbb.bbbb.bbbb.bbbb.bbbb
  ++  pact
    ^-  item:smart
    :*  %|
        nft-bridge-pact  ::  id
        nft-bridge-pact  ::  source
        nft-bridge-pact  ::  holder
        town-id
        [- +]:(cue nft-contract)
        ~
    ==
  ++  metadata
    ^-  item:smart
    :*  %&
        (hash-data nft-bridge-pact nft-bridge-pact town-id l1-address)
        nft-bridge-pact
        nft-bridge-pact
        town-id
        l1-address
        %metadata
        ['name' 'symbol' ~ 4 ~ %.y ~ *address:smart l1-address]
    ==
  --
::
++  engine-tester
  |%
  ++  pact
    ^-  item:smart
    =/  code  (cue engine-tester-contract)
    :*  %|
        (hash-pact 0x0 0x0 town-id code)  ::  id
        0x0  ::  source
        0x0  ::  holder
        town-id
        [-.code +.code]
        ~
    ==
  ++  dummy-data
    ^-  item:smart
    :*  %&
        (hash-data id.p:pact id.p:pact town-id 'salt')
        id.p:pact
        id.p:pact
        town-id
        'salt'
        %dummy
        'my-noun'
    ==
  --
::
++  abstract-account
  |%
  ++  pact
    ^-  item:smart
    =/  code  (cue aa-contract)
    :*  %|
        (hash-pact 0x0 0x0 town-id code)  ::  id
        0x0  ::  source
        0x0  ::  holder
        town-id
        [-.code +.code]
        ~
    ==
  ++  zigs  ^-  id:smart
    (hash-data zigs-contract-id:smart id.p:pact town-id `@`'zigs')
  ++  caller
    [id.p:pact 0 zigs]
  --
::
++  burnable
  ^-  item:smart
  :*  %&
      0x1111.2222.3333
      0xcafe.cafe
      address:caller-1
      town-id
      `@`'loach'
      %account
      [300.000.000 ~ `@ux`'custom-token']
  ==
::
++  fake-state
  ^-  state
  %+  gas:big  *(merk:merk id:smart item:smart)
  :~  [id.p:pact pact]:zigs
      [id.p:account-1 account-1]:zigs
      [id.p:account-2 account-2]:zigs
      [id.p:sequencer-account sequencer-account]:zigs
  ::
      [id.p:burnable burnable]
      [id.p:pact pact]:engine-tester
      [id.p:dummy-data dummy-data]:engine-tester
  ::
      [id.p:pact pact]:ueth
      [id.p:account-1 account-1]:ueth
  ::
      [id.p:pact pact]:nft
      [id.p:metadata metadata]:nft
  ::
      [id.p:pact pact]:abstract-account
  ==
++  fake-nonces
  ^-  nonces
  %+  gas:pig  *(merk:merk address:smart @ud)
  :~  [address-3 5]
  ==
++  fake-chain
  ^-  chain
  [fake-state fake-nonces]
::
:: ++  make-modified
::   |=  [=address:smart spend=@ud]
::   =+  (zig-account:zigs address (sub 300.000.000 spend))
::   (gas:big *(merk:merk id:smart item:smart) ~[id.p.-^-])
--
|%
::
::  begin single-transaction tests
::  calls +intake in eng core, examines single-transaction *output*
::  alphabet chars at beginning of test name are to make order
::  of execution match order in file, and to specific groups of
::  tests by name to only do a partial run-through
::
::
::  tests for zigs contract interactions
::
++  test-zz-engine-zigs-give
  =/  tx=transaction:smart
    :+  fake-sig
      [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
    [caller-1 ~ id.p:pact:zigs [1 1.000.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call went through
  (expect-eq !>(%0) !>(errorcode.output))
::
::  TODO here: zigs give with budget+amount > balance,
::             zigs give to sequencer,
::             zigs give *from* sequencer,
::             zigs take to/from sequencer,
::             ?
::
::
::  tests for burning data
::
++  test-zy-burn-gas-account
  ::               id of grain to burn, destination town id
  =/  =calldata:smart       [%burn id.p:account-1:zigs 0x2]
  =/  =shell:smart          [caller-1 ~ 0x0 [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed
  ;:  weld
    (expect-eq !>(%9) !>(errorcode.output))
  ::
    (expect-eq !>(%.n) !>((has:big burned.output id.p:account-1:zigs)))
  ==
::
++  test-zx-simple-burn
  ::               id of grain to burn, destination town id
  =/  =calldata:smart       [%burn id.p:burnable 0x2]
  =/  =shell:smart          [caller-1 ~ 0x0 [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call went through
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
  ::
    (expect-eq !>(%.y) !>((has:big burned.output id.p:burnable)))
  ==
::
++  test-zw-burn-not-ours
  =/  =calldata:smart       [%burn id.p:account-2:zigs 0x2]
  =/  =shell:smart  [caller-1 ~ 0x0 [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%9) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests of validation logic (using engine-tester-contract)
::
++  test-yz-change-nonexistent
  =/  =calldata:smart       [%change-nonexistent ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-yy-change-type
  =/  =calldata:smart       [%change-type id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-yx-change-id
  =/  =calldata:smart       [%change-type id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-yw-change-salt
  =/  =calldata:smart       [%change-salt id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-yv-change-source
  =/  =calldata:smart       [%change-source id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-yu-changed-issued-overlap
  =/  =calldata:smart       [%change-salt id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-yt-change-without-provenance
  =/  =calldata:smart       [%change-salt zigs:caller-1]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-xz-issue-non-matching-id
  =/  =calldata:smart       [%issue-non-matching-id ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-xy-issue-bad-data-id
  =/  =calldata:smart       [%issue-bad-data-id ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-xx-issue-bad-pact-id
  =/  =calldata:smart       [%issue-bad-pact-id ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-xw-issue-without-provenance
  =/  =calldata:smart       [%issue-without-provenance ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-xv-issue-already-existing
  =/  =calldata:smart       [%issue-already-existing id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-wz-burn-nonexistent
  =/  =calldata:smart       [%burn-nonexistent ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-wy-burn-non-matching-id
  =/  =calldata:smart       [%burn-non-matching-id id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-wx-burn-changed-overlap
  =/  =calldata:smart       [%burn-changed-overlap id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-ww-burn-issued-overlap
  =/  =calldata:smart       [%burn-issued-overlap ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-wv-burn-without-provenance
  =/  =calldata:smart       [%burn-without-provenance zigs:caller-2]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-wu-burn-change-source
  =/  =calldata:smart       [%burn-change-source id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed validation
  ;:  weld
    (expect-eq !>(%7) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests for continuation calls
::  assert that contracts can issue arbitrary calls to other
::  contracts, which will happen serially in order, "depth-first",
::  such that those calls can issue calls of their own, and state/
::  gas/events/modified/burned are properly updated at each step
::
++  test-vz-simple-self-call
  =/  =calldata:smart       [%simple-self-call ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
  ::
    %+  expect-eq
      !>
      :~  [id.p:pact:engine-tester [%entry-event ~]]
          [id.p:pact:engine-tester [%exit-event ~]]
      ==
    !>(events.output)
  ==
::
++  test-vy-triple-self-call
  =/  =calldata:smart       [%triple-self-call ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
  ::
    %+  expect-eq
      !>
      :~  [id.p:pact:engine-tester [%triple-event ~]]
          [id.p:pact:engine-tester [%entry-event ~]]
          [id.p:pact:engine-tester [%exit-event ~]]
          [id.p:pact:engine-tester [%entry-event ~]]
          [id.p:pact:engine-tester [%exit-event ~]]
          [id.p:pact:engine-tester [%entry-event ~]]
          [id.p:pact:engine-tester [%exit-event ~]]
      ==
    !>(events.output)
  ==
::
++  test-vx-modify-and-call
  =/  =calldata:smart  [%modify-and-call id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(burned.output))
  ::
    %+  expect-eq
      =/  dd=data:smart  ;;(data:smart p:dummy-data:engine-tester)
      !>  %+  uni:big
            ~
          %+  gas:big  *(merk:merk id:smart item:smart)
          ~[[id.dd %&^dd(noun 'my new noun!')]]
    !>(modified.output)
  ::
    %+  expect-eq
      !>
      ~[[id.p:pact:engine-tester [%i-read s+'my new noun!']]]
    !>(events.output)
  ==
::
++  test-vw-modify-and-read-separately
  =/  =calldata:smart  [%modify-and-read-separately id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(burned.output))
  ::
    %+  expect-eq
      =/  dd=data:smart  ;;(data:smart p:dummy-data:engine-tester)
      !>  %+  uni:big
            ~
          %+  gas:big  *(merk:merk id:smart item:smart)
          ~[[id.dd %&^dd(noun 'my new noun!')]]
    !>(modified.output)
  ::
    %+  expect-eq
      !>(~[[id.p:pact:engine-tester [%i-read s+'my new noun!']]])
    !>(events.output)
  ==
::
++  test-vv-fail-on-continuation
  =/  =calldata:smart  [%call-crash ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%6) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests for transaction nonces
::
++  test-uz-nonce-too-high
  =/  =calldata:smart  [%just-modify id.p:dummy-data:engine-tester]
  =/  caller  caller-1
  =/  =shell:smart  [caller(nonce 2) ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%2) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-uy-nonce-too-low
  =/  =calldata:smart  [%just-modify id.p:dummy-data:engine-tester]
  =/  caller  caller-3
  =/  =shell:smart  [caller(nonce 5) ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%2) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests for gas audit
::
++  test-tz-gas-too-high
  =/  =calldata:smart  [%just-modify id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 500.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%3) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-ty-gas-account-missing
  =/  =calldata:smart  [%just-modify id.p:dummy-data:engine-tester]
  =/  caller  caller-1
  =/  =shell:smart  [caller(zigs 0xabcd) ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%3) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-tx-gas-account-not-mine
  =/  =calldata:smart  [%just-modify id.p:dummy-data:engine-tester]
  =/  caller  caller-1
  =/  =shell:smart  [caller(zigs id.p:account-2:zigs) ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%3) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests for call to data / missing contract
::
++  test-sz-call-missing-pact
  =/  =calldata:smart  [%some-call ~]
  =/  =shell:smart  [caller-1 ~ 0xdead.beef [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%4) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-sy-call-data-not-pact
  =/  =calldata:smart  [%some-call ~]
  =/  =shell:smart  [caller-1 ~ id.p:account-2:zigs [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%5) !>(errorcode.output))
    (expect-eq !>(0) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests for running out of gas
::
++  test-rz-out-of-gas
  ::  this call takes about 16k gas, make sure to update
  ::  here if the gas calculation changes
  =/  =calldata:smart
    [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
  =/  =shell:smart  [caller-1 ~ id.p:pact:zigs [1 1.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%8) !>(errorcode.output))
    (expect-eq !>(1.000) !>(gas.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
::  tests for contract scries
::
++  test-qz-basic-scry
  =/  =calldata:smart  [%do-scry ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-qy-paid-scry
  =/  =calldata:smart  [%do-paid-scry ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-qx-scry-bad-fee
  =/  =calldata:smart  [%do-scry-bad-fee ~]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    (expect-eq !>(~) !>(events.output))
  ==
::
++  test-qw-scry-with-event
  =/  =calldata:smart  [%do-paid-scry-2 id.p:dummy-data:engine-tester]
  =/  =shell:smart  [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
  =/  tx=transaction:smart  [fake-sig calldata shell]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=1 eth-block-height=0]
    [fake-chain tx]
  ;:  weld
    (expect-eq !>(%0) !>(errorcode.output))
    (expect-eq !>(~) !>(modified.output))
    (expect-eq !>(~) !>(burned.output))
    %+  expect-eq
      !>([id.p:pact:engine-tester %read-event 'my-noun']^~)
    !>(events.output)
  ==
::
++  test-qu-scry-full
  ::  make sure contract is paid
  =/  =memlist
    :~  :+  0x0
          :+  fake-sig
            [%do-paid-scry ~]
          [caller-1 ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
        ~
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      memlist
    ~
  =/  paid=item:smart
    :*  %&
        (hash-data id.p:pact:zigs id.p:pact:engine-tester town-id `@`'zigs')
        id.p:pact:zigs
        id.p:pact:engine-tester
        town-id
        `@`'zigs'
        %account
        [1.007 0 `@ux`'zigs-metadata' 0]
    ==
  ;:  weld
    (expect-eq !>(1) !>((lent processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 0 processed.st)))
    (expect-eq !>(~) !>(burned.st))
    ::  3 modified: paid sequencer, paid contract, payer account
    (expect-eq !>(3) !>(~(wyt by modified.st)))
    (expect-eq !>(`paid) !>((get:big modified.st id.p.paid)))
  ==
::
++  test-qt-scry-many
  ::  make sure contract is paid
  =/  caller  caller-1
  =/  =memlist
    :~  :+  0x0
          :+  fake-sig
            [%do-paid-scry ~]
          [caller ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%do-paid-scry ~]
          [caller(nonce 2) ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%do-paid-scry-2 id.p:dummy-data:engine-tester]
          [caller(nonce 3) ~ id.p:pact:engine-tester [1 1.000.000] town-id 0]
        ~
    ==
  =/  paid=item:smart
    :*  %&
        (hash-data id.p:pact:zigs id.p:pact:engine-tester town-id `@`'zigs')
        id.p:pact:zigs
        id.p:pact:engine-tester
        town-id
        `@`'zigs'
        %account
        [3.716 0 `@ux`'zigs-metadata' 0]
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      memlist
    ~
  ;:  weld
    (expect-eq !>(3) !>((lent processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 0 processed.st)))
    (expect-eq !>(~) !>(burned.st))
    ::  3 modified: paid sequencer, paid contract, payer account
    (expect-eq !>(3) !>(~(wyt by modified.st)))
    (expect-eq !>(`paid) !>((get:big modified.st id.p.paid)))
  ==
::
::  tests for execution of malformed contract nock
::
::  XX TODO
::
::  tests for full engine +run, with multiple transactions in mempool
::  assert that transactions are ordered properly by rate and nonce,
::  and that serial exeuction is performed correctly with proper final state
::
++  test-pz-run
  =/  =memlist
    :~  :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller-1 ~ id.p:pact:zigs [1 100.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%give address:caller-1:zigs 1.000 id.p:account-2:zigs]
          [caller-2 ~ id.p:pact:zigs [1 100.000] town-id 0]
        ~
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      memlist
    ~
  ;:  weld
    (expect-eq !>(2) !>((lent processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 0 processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 1 processed.st)))
    (expect-eq !>(~) !>(burned.st))
    (expect-eq !>(3) !>(~(wyt by modified.st)))
  ==
::
++  test-py-run-same-caller
  =/  caller  caller-1
  =/  =memlist
    :~  :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller ~ id.p:pact:zigs [1 100.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller(nonce 2) ~ id.p:pact:zigs [1 100.000] town-id 0]
        ~
    ==
  =/  st=state-transition
    %^   %~  run  eng
        [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      memlist
    ~
  ;:  weld
    (expect-eq !>(2) !>((lent processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 0 processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 1 processed.st)))
    (expect-eq !>(~) !>(burned.st))
    (expect-eq !>(3) !>(~(wyt by modified.st)))
  ==
::
++  test-py-run-same-caller-different-rates
  =/  caller  caller-1
  =/  =memlist
    :~  :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller ~ id.p:pact:zigs [4 100.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller(nonce 2) ~ id.p:pact:zigs [3 100.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller(nonce 3) ~ id.p:pact:zigs [2 100.000] town-id 0]
        ~
        :+  0x0
          :+  fake-sig
            [%give address:caller-2:zigs 1.000 id.p:account-1:zigs]
          [caller(nonce 4) ~ id.p:pact:zigs [1 100.000] town-id 0]
        ~
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      memlist
    ~
  ;:  weld
    (expect-eq !>(4) !>((lent processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 0 processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 1 processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 2 processed.st)))
    (expect-eq !>(%0) !>(status.tx:(snag 3 processed.st)))
    (expect-eq !>(~) !>(burned.st))
    (expect-eq !>(3) !>(~(wyt by modified.st)))
  ==
::
::  deposit tests
::
++  test-oz-deposit-fungible
  =/  d1=deposit
    :*  town-id=0x0
        token-contract=uethereum
        token-id=0
        destination-address=address-1
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%eth decimals=18]
    ==
  =/  d2=deposit
    :*  town-id=0x0
        token-contract=uethereum
        token-id=0
        destination-address=address-1
        amount=1.000.000.000
        block-number=764
        previous-deposit-root=0x1
        [%eth decimals=18]
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[d1 d2]
  =/  new-acc=item:smart  (got:big modified.st id.p:account-1:ueth)
  ?>  ?=(%& -.new-acc)
  (expect-eq !>(2.300.000.000) !>(-.noun.p.new-acc))
::
++  test-oy-deposit-fungible-create-account
  =/  d1=deposit
    :*  town-id=0x0
        token-contract=uethereum
        token-id=0
        destination-address=address-2
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%eth decimals=18]
    ==
  =/  d2=deposit
    :*  town-id=0x0
        token-contract=uethereum
        token-id=0
        destination-address=address-3
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%eth decimals=18]
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[d1 d2]
  =/  new-acc-1=item:smart
    %+  got:big  modified.st
    (hash-data bridge-pact address-2 town-id uethereum)
  =/  new-acc-2=item:smart
    %+  got:big  modified.st
    (hash-data bridge-pact address-3 town-id uethereum)
  ?>  ?=(%& -.new-acc-1)
  ?>  ?=(%& -.new-acc-2)
  ;:  weld
    (expect-eq !>(1.000.000.000) !>(-.noun.p.new-acc-1))
    (expect-eq !>(1.000.000.000) !>(-.noun.p.new-acc-2))
  ==
::
++  test-ox-deposit-fungible-create-token-and-account
  =/  l1-token-address
    0xffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff
  =/  d1=deposit
    :*  town-id=0x0
        token-contract=l1-token-address
        token-id=0
        destination-address=address-2
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%erc20 name='asdf' symbol='asdf' decimals=18]
    ==
  =/  d2=deposit
    :*  town-id=0x0
        token-contract=l1-token-address
        token-id=0
        destination-address=address-2
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%erc20 name='asdf' symbol='asdf' decimals=18]
    ==
  =/  d3=deposit
    :*  town-id=0x0
        token-contract=l1-token-address
        token-id=0
        destination-address=address-3
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%erc20 name='asdf' symbol='asdf' decimals=18]
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[d1 d2 d3]
  =/  new-acc-1=item:smart
    %+  got:big  modified.st
    (hash-data bridge-pact address-2 town-id l1-token-address)
  =/  new-acc-2=item:smart
    %+  got:big  modified.st
    (hash-data bridge-pact address-3 town-id l1-token-address)
  =/  new-meta=item:smart
    %+  got:big  modified.st
    (hash-data bridge-pact bridge-pact town-id l1-token-address)
  ?>  ?=(%& -.new-meta)
  ?>  ?=(%& -.new-acc-1)
  ?>  ?=(%& -.new-acc-2)
  ;:  weld
    (expect-eq !>(2.000.000.000) !>(-.noun.p.new-acc-1))
    (expect-eq !>(1.000.000.000) !>(-.noun.p.new-acc-2))
    (expect-eq !>(3.000.000.000) !>(-:|3:noun.p.new-meta))
  ==
::
++  test-ow-deposit-and-send-tokens
  ::  make sure there is no bad interaction between %give and %deposit
  =/  =memlist
    :~  :+  0x0
          :+  fake-sig
            [%give address-2 100.000.000 id.p:account-1:ueth]
          [caller-1 ~ id.p:pact:ueth [1 100.000] town-id 0]
        ~
    ==
  =/  =deposit
    :*  town-id=0x0
        token-contract=uethereum
        token-id=0
        destination-address=address-1
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%eth decimals=18]
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      memlist
    ~[deposit]
  =/  new-acc=item:smart  (got:big modified.st id.p:account-1:ueth)
  ?>  ?=(%& -.new-acc)
  (expect-eq !>(1.200.000.000) !>(-.noun.p.new-acc))
::
++  test-ov-deposit-fungible-mint-fail
  =/  eng  eng
  =/  l1-token-address
    0xffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff
  =/  =deposit
    :*  town-id=0x0
        token-contract=l1-token-address
        token-id=0
        destination-address=address-2
        amount=1.000.000.000
        block-number=763
        previous-deposit-root=0x0
        [%erc20 name='asdf' symbol='asdf' decimals=18]
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[deposit]
  =/  meta-id=id:smart
    (hash-data bridge-pact bridge-pact town-id l1-token-address)
  =/  tx=transaction:smart
    :+  fake-sig
      [%mint meta-id [address-1 100]~]
    [caller-1 ~ id.p:pact:nft [1 100.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [chain.st tx]
  (expect-eq !>(%6) !>(errorcode.output))
::
::  nft-tests
::
++  test-nz-deposit-nft
  =/  d1=deposit
    :*  town-id=0x0
        token-contract=l1-address:nft
        token-id=1
        destination-address=address-1
        amount=0
        block-number=763
        previous-deposit-root=0x0
        [%erc721 name='asdf' symbol='asdf' token-uri='']
    ==
  =/  d2=deposit
    :*  town-id=0x0
        token-contract=l1-address:nft
        token-id=2
        destination-address=address-1
        amount=0
        block-number=763
        previous-deposit-root=0x0
        [%erc721 name='asdf' symbol='asdf' token-uri='']
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[d1 d2]
  =/  new-nft-1=item:smart
    %+  got:big  modified.st
    (hash-data nft-bridge-pact address-1 town-id (cat 3 l1-address:nft 1))
  =/  new-nft-2=item:smart
    %+  got:big  modified.st
    (hash-data nft-bridge-pact address-1 town-id (cat 3 l1-address:nft 2))
  =/  new-meta=item:smart  (got:big modified.st id.p:metadata:nft)
  ?>  ?=(%& -.new-meta)
  ?>  ?=(%& -.new-nft-1)
  ?>  ?=(%& -.new-nft-2)
  ;:  weld
    (expect-eq !>(1) !>(-.noun.p.new-nft-1))
    (expect-eq !>(2) !>(-.noun.p.new-nft-2))
    (expect-eq !>(6) !>(-:|3:noun.p.new-meta))
  ==
::
++  test-ny-deposit-nft-create-metadata
  =/  l1-address
    0xcccc.cccc.cccc.cccc.cccc.cccc.cccc.cccc.cccc.cccc
  =/  d1=deposit
    :*  town-id=0x0
        token-contract=l1-address
        token-id=2
        destination-address=address-1
        amount=0
        block-number=763
        previous-deposit-root=0x0
        [%erc721 name='asdf' symbol='asdf' token-uri='']
    ==
  =/  d2=deposit
    :*  town-id=0x0
        token-contract=l1-address
        token-id=3
        destination-address=address-1
        amount=0
        block-number=763
        previous-deposit-root=0x0
        [%erc721 name='asdf' symbol='asdf' token-uri='']
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[d1 d2]
  =/  new-nft-1=item:smart
    %+  got:big  modified.st
    (hash-data nft-bridge-pact address-1 town-id (cat 3 l1-address 2))
  =/  new-nft-2=item:smart
    %+  got:big  modified.st
    (hash-data nft-bridge-pact address-1 town-id (cat 3 l1-address 3))
  =/  new-meta=item:smart
    %+  got:big  modified.st
    (hash-data nft-bridge-pact nft-bridge-pact town-id l1-address)
  ?>  ?=(%& -.new-meta)
  ?>  ?=(%& -.new-nft-1)
  ?>  ?=(%& -.new-nft-2)
  ;:  weld
    (expect-eq !>(2) !>(-.noun.p.new-nft-1))
    (expect-eq !>(3) !>(-.noun.p.new-nft-2))
    (expect-eq !>(2) !>(-:|3:noun.p.new-meta))
  ==
::
++  test-nx-deposit-nft-mint-fail
  =/  eng  eng
  =/  l1-address
    0xcccc.cccc.cccc.cccc.cccc.cccc.cccc.cccc.cccc.cccc
  =/  =deposit
    :*  town-id=0x0
        token-contract=l1-address
        token-id=2
        destination-address=address-1
        amount=0
        block-number=763
        previous-deposit-root=0x0
        [%erc721 name='asdf' symbol='asdf' token-uri='']
    ==
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      ~ :: memlist
    ~[deposit]
  =/  tx=transaction:smart
    :+  fake-sig
      [%mint id.p:metadata:nft [address-1 'uri' ~ %.y]~]
    [caller-1 ~ id.p:pact:nft [1 100.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [chain.st tx]
  (expect-eq !>(%6) !>(errorcode.output))
::
::  tests for account abstraction
::
++  test-mz-abstract-call
  =/  eng  eng
  ::  first, fund the contract account
  =/  tx=transaction:smart
    :+  fake-sig
      [%give id.p:pact:abstract-account 100.000 id.p:account-1:zigs]
    [caller-1 ~ id.p:pact:zigs [1 1.000.000] town-id 0]
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      [`@ux`(sham +.tx) tx ~]^~
    ~
  ::  then make a %validate call to it
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=7 call=[id.p:pact:zigs town-id -]]
      [%give address:caller-2:zigs 7.777 zigs:abstract-account]
    [caller:abstract-account ~ id.p:pact:abstract-account [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [chain.st tx]
  ::  assert that our call went through
  (expect-eq !>(%0) !>(errorcode.output))
::
++  test-my-abstract-call-fail
  =/  eng  eng
  ::  first, fund the contract account
  =/  tx=transaction:smart
    :+  fake-sig
      [%give id.p:pact:abstract-account 100.000 id.p:account-1:zigs]
    [caller-1 ~ id.p:pact:zigs [1 1.000.000] town-id 0]
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      [`@ux`(sham +.tx) tx ~]^~
    ~
  ::  then make a %validate call to it
  ::  creating bad calldata
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=7 call=[id.p:pact:zigs town-id -]]
      [%give ~]
    [caller:abstract-account ~ id.p:pact:abstract-account [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [chain.st tx]
  ::
  (expect-eq !>(%6) !>(errorcode.output))
::
++  test-mx-abstract-call-gas-fail
  =/  eng  eng
  ::  first, fund the contract account
  =/  tx=transaction:smart
    :+  fake-sig
      [%give id.p:pact:abstract-account 100.000 id.p:account-1:zigs]
    [caller-1 ~ id.p:pact:zigs [1 1.000.000] town-id 0]
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      [`@ux`(sham +.tx) tx ~]^~
    ~
  ::  then make a %validate call to it
  ::  trying to send more zigs than we have (after gas)
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=7 call=[id.p:pact:zigs town-id -]]
      [%give address:caller-2:zigs 96.000 zigs:abstract-account]
    [caller:abstract-account ~ id.p:pact:abstract-account [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [chain.st tx]
  ::  assert that our call failed
  (expect-eq !>(%6) !>(errorcode.output))
::
++  test-mw-abstract-call-missing-contract
  ::  make a %validate call to the wrong contract
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=7 call=[id.p:pact:zigs town-id -]]
      [%give address:caller-2:zigs 96.000 zigs:abstract-account]
    [[0x1234.5678.1234.5678 0 0x0] ~ 0x1234.5678.1234.5678 [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed
  (expect-eq !>(%1) !>(errorcode.output))
::
++  test-mv-abstract-call-to-data-item
  ::  make a %validate call to a data item id
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=7 call=[id.p:pact:zigs town-id -]]
      [%give address:caller-2:zigs 96.000 zigs:abstract-account]
    [caller:abstract-account ~ zigs:abstract-account [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call failed
  (expect-eq !>(%1) !>(errorcode.output))
::
++  test-mu-abstract-call-no-gas-in-contract
  ::  make legit call, but before funding contract account
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=7 call=[id.p:pact:zigs town-id -]]
      [%give address:caller-2:zigs 7.777 zigs:abstract-account]
    [caller:abstract-account ~ id.p:pact:abstract-account [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [fake-chain tx]
  ::  assert that our call fails gas audit
  (expect-eq !>(%3) !>(errorcode.output))
::
++  test-mt-abstract-call-burn-free-gas
  =/  eng  eng
  ::  first, fund the contract account
  =/  tx=transaction:smart
    :+  fake-sig
      [%give id.p:pact:abstract-account 100.000 id.p:account-1:zigs]
    [caller-1 ~ id.p:pact:zigs [1 1.000.000] town-id 0]
  =/  st=state-transition
    %^    %~  run  eng
          [sequencer town-id batch=1 eth-block-height=0]
        fake-chain
      [`@ux`(sham +.tx) tx ~]^~
    ~
  ::  then make a %validate call to it: using num=5 tells
  ::  account.hoon to burn through all gas
  =/  tx=transaction:smart
    :+  fake-sig
      =-  [%validate num=5 call=[id.p:pact:zigs town-id -]]
      [%give address:caller-2:zigs 7.777 zigs:abstract-account]
    [caller:abstract-account ~ id.p:pact:abstract-account [1 50.000] town-id 0]
  =/  =output  =<  -
    %~  intake  %~  eng  eng
      [sequencer town-id batch=2 eth-block-height=0]
    [chain.st tx]
  ::  assert that our call failed
  (expect-eq !>(%1) !>(errorcode.output))
--