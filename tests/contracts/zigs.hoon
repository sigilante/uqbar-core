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
::
::  tests for %push
::
++  test-zz-push  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%push addr-1:zigs 100.000 (id:zigs addr-2:zigs) [%random-call ~]]
    [caller-2 ~ id.p:pact:zigs [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%4  ::  0x1234.5678 is a missing pact, this is success
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %pull
::
++  generate-eth-hash
  |=  =hash:smart
  ^-  @ux
  %-  keccak-256:keccak:crypto
  %-  as-octt:mimes:html
  %+  weld  "\19Ethereum Signed Message:\0a"           :: eth signed message, 
  %+  weld  (a-co:co (lent (scow %ux hash)))           :: prefix + len(msg)[no dots] + msg
  (scow %ux hash)                                  
::
++  recover-pub
  |=  [=hash:smart =sig:smart]
  ^-  address:smart
  =?  v.sig  (gte v.sig 27)  (sub v.sig 27)
  =?  hash  (gth (met 3 hash) 32)  (end [3 32] hash)
  %-  address-from-pub:smart
  %-  serialize-point:secp256k1:secp:crypto
  (ecdsa-raw-recover:secp256k1:secp:crypto hash sig)
::
++  test-zzx-pull  ^-  test-txn
  =/  =typed-message:smart
    :+  (id:zigs addr-2:zigs)                         :: domain, giver zigs account
      0x8a0c.ebea.b35e.84a1.1729.7c78.f677.f39a       :: pull-jold hash
    :*  addr-2:zigs                                   :: msg: [giver to amount nonce deadline]
        addr-1:zigs
        100.000
        0
        1.000
    ==
  ::  signatures now signed in eth_personal_sign by default. 
  ::  see ++generate-eth hash
  =/  =hash:smart  (generate-eth-hash (shag:smart typed-message)) 
  =/  =sig:smart
    %+  ecdsa-raw-sign:secp256k1:secp:crypto
    `@uvI`hash  priv-2:zigs
  :^    chain
     [sequencer default-town-id batch=1 eth-block-height=999]
    :+  fake-sig
      [%pull addr-2:zigs addr-1:zigs 100.000 (id:zigs addr-2:zigs) 0 1.000 sig]
    [caller-1 ~ id.p:pact:zigs [1 1.000.000] default-town-id 0]
  =/  new-giver  ::  incrementing nonces for giver
    ^-  item:smart
    :*  %&
        (id addr-2):zigs
        id.p:pact:zigs
        addr-2:zigs
        default-town-id
        `@`'zigs'
        %account
        :*  balance=199.900.000
            allowances=~
            metadata=`@ux`'zigs-metadata'
            nonces=(make-pmap:smart ~[[addr-1:zigs 1]])
    ==  ==
  :*  gas=~
      errorcode=`%0
      :-  ~
      %-  make-chain-state
      :~  (account addr-1 300.100.000 [addr-2 1.000.000]^~):zigs
          new-giver
      ==
      burned=`~
      events=`~
  ==
--
