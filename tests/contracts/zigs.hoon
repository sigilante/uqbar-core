::
::  tests for con/zigs.hoon
::
/+  *test, *transaction-sim
|%
::
::  test data
::
++  sequencer  caller-1
++  caller-1  ^-  caller:smart  [addr-1 1 (id addr-1)]:zigs
++  caller-2  ^-  caller:smart  [addr-2 1 (id addr-2)]:zigs
++  caller-3  ^-  caller:smart  [addr-3 1 (id addr-3)]:zigs
++  caller-4  ^-  caller:smart  [addr-4 1 (id addr-4)]:zigs
::
++  my-shell  [caller-1 ~ id.p:pact:zigs [1 1.000.000] default-town-id 0]
::
++  state
  %-  make-chain-state
  :~  pact:zigs
      (account addr-1 300.000.000 [addr-2 1.000.000]^~):zigs
      (account addr-2 200.000.000 ~):zigs
      (account addr-3 100.000.000 [addr-1 50.000]^~):zigs
      (account addr-4 500.000 ~):zigs
  ==
++  chain
  ^-  chain:engine
  [state ~]
::
::  tests for %give
::
++  test-zz-zigs-give  ^-  test-txn
  =/  =calldata:smart
    [%give addr-2:zigs 1.000 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account addr-1 299.999.000 [addr-2 1.000.000]^~):zigs
          (account addr-2 200.001.000 ~):zigs
      ==
      burned=`~
      events=`~
  ==
::
++  test-zy-zigs-give-new-address  ^-  test-txn
  =/  =calldata:smart
    [%give 0xdead.beef 1.000 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account addr-1 299.999.000 [addr-2 1.000.000]^~):zigs
          (account 0xdead.beef 1.000 ~):zigs
      ==
      burned=`~
      events=`~
  ==
::
++  test-zx-zigs-give-self  ^-  test-txn  ::  should fail
  =/  =calldata:smart
    [%give addr-1:zigs 1.000 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  tx-fail
::
++  test-zw-zigs-give-too-much  ^-  test-txn  ::  should fail
  =/  =calldata:smart
    [%give addr-2:zigs 500.000.000 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  tx-fail
::
::  tests for %take
::
++  test-yz-zigs-take  ^-  test-txn
  =/  =calldata:smart
    [%take addr-3:zigs 1.000 (id addr-1):zigs]
  =/  tx=transaction:smart
    :+  fake-sig  calldata
    [caller-2 ~ id.p:pact:zigs [1 50.000] default-town-id 0]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account addr-3 100.001.000 [addr-1 50.000]^~):zigs
          (account addr-1 299.999.000 [addr-2 999.000]^~):zigs
      ==
      burned=`~
      events=`~
  ==
::
++  test-yy-zigs-take-no-allowance  ^-  test-txn  ::  should fail
  =/  =calldata:smart
    [%take addr-3:zigs 1.000 (id addr-2):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  tx-fail
::
::  tests for %set-allowance
::
++  test-xz-set-allowance  ^-  test-txn
  =/  =calldata:smart
    [%set-allowance addr-3:zigs 1.000 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      ~[(account addr-1 300.000.000 ~[[addr-2 1.000.000] [addr-3 1.000]]):zigs]
      burned=`~
      events=`~
  ==
::
++  test-xy-set-allowance-again  ^-  test-txn
  =/  =calldata:smart
    [%set-allowance addr-2:zigs 0 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      ~[(account addr-1 300.000.000 [addr-2 0]^~):zigs]
      burned=`~
      events=`~
  ==
::
++  test-xx-set-allowance-self  ^-  test-txn  ::  should fail
  =/  =calldata:smart
    [%set-allowance addr-1:zigs 1.000 (id addr-1):zigs]
  =/  tx=transaction:smart  [fake-sig calldata my-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  tx-fail
--
