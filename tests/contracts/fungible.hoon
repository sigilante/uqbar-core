::
::  tests for con/fungible.hoon
::
/+  *test, *transaction-sim
/=  fungible-lib  /con/lib/fungible
/*  fungible-contract  %jam  /con/compiled/fungible/jam
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
++  fungible
  |%
  ++  code
    (cue fungible-contract)
  ++  id
    (hash-pact 0x1234.5678 0x1234.5678 default-town-id code)
  ++  pact
    ^-  item:smart
    :*  %|  id
        0x1234.5678  ::  source
        0x1234.5678  ::  holder
        default-town-id
        [- +]:code
        ~
    ==
  ++  account
  |=  [holder=id:smart metadata=id:smart amt=@ud salt=@ allowances=(list [@ux @ud])]
  ^-  item:smart
  :*  %&  (hash-data:smart id holder default-town-id salt)
      id
      holder
      default-town-id
      salt
      %account
      [amt (make-pmap:smart allowances) metadata ~]
  ==
--
::
++  token-1
  |%
  ++  salt
    (cat 3 'test-salt' addr-1:zigs)
  ++  metadata
    ^-  item:smart
    :*  %&
        (hash-data id:fungible id:fungible default-town-id salt)
        id:fungible
        id:fungible
        default-town-id
        salt
        %token-metadata
        :*  name='token-1'
            symbol='TT1'
            decimals=18
            supply=100.000
            cap=~
            mintable=%.n
            minters=~
            deployer=addr-1:zigs
            salt
    ==  ==
  ++  account-1
    ^-  item:smart
    :*  %&
        (hash-data id:fungible addr-1:zigs default-town-id salt)
        id:fungible
        addr-1:zigs
        default-town-id
        salt
        %account
        :*  balance=100.000
            allowances=~
            id.p:metadata
            nonces=~
    ==  ==
  --
::
++  token-2
  |%
  ++  salt
    (cat 3 'test-salt' addr-2:zigs)
  ++  metadata
    ^-  item:smart
    :*  %&
        (hash-data id:fungible id:fungible default-town-id salt)
        id:fungible
        id:fungible
        default-town-id
        salt
        %token-metadata
        :*  name='token-2'
            symbol='TT2'
            decimals=18
            supply=200.000
            cap=`10.000.000
            mintable=%.y
            minters=[addr-1:zigs ~ ~]
            deployer=addr-1:zigs
            salt
    ==  ==
  ++  account-1
    ^-  item:smart
    :*  %&
        (hash-data id:fungible addr-1:zigs default-town-id salt)
        id:fungible
        addr-1:zigs
        default-town-id
        salt
        %account
        :*  balance=100.000
            allowances=~
            id.p:metadata
            nonces=~
    ==  ==
  ++  account-2
    ^-  item:smart
    :*  %&
        (hash-data id:fungible addr-2:zigs default-town-id salt)
        id:fungible
        addr-2:zigs
        default-town-id
        salt
        %account
        :*  balance=100.000
            allowances=~
            id.p:metadata
            nonces=~
    ==  ==
  ++  account-3
    ^-  item:smart
    :*  %&
        (hash-data id:fungible addr-3:zigs default-town-id salt)
        id:fungible
        addr-3:zigs
        default-town-id
        salt
        %account
        :*  balance=100.000
            allowances=(make-pmap:smart ~[[addr-2:zigs 5.000]])
            id.p:metadata
            nonces=~
    ==  ==
--
::
++  state
  %-  make-chain-state
  :~  pact:zigs
      pact:fungible
      metadata:token-1
      account-1:token-1
      metadata:token-2
      account-1:token-2
      account-2:token-2
      account-3:token-2
      (account addr-1 300.000.000 ~):zigs
      (account addr-2 200.000.000 ~):zigs
      (account addr-3 100.000.000 ~):zigs
      (account addr-4 100.000.000 ~):zigs
  ==
++  chain
  ^-  chain:engine
  [state ~]
::
::  tests for %deploy
::
++  test-zzz-deploy  ^-  test-txn
  =/  salt  (cat 3 'deploy-salt' addr-4:zigs)  
  ::  replace supply, todo just change wing
  =/  new-token-metadata
    ^-  item:smart
    :*  %&
        (hash-data id:fungible id:fungible default-town-id salt)
        id:fungible
        id:fungible
        default-town-id
        salt
        %token-metadata
        :*  name='token-3'
            symbol='TT3'
            decimals=18
            supply=5.000
            cap=`10.000
            mintable=%.n
            minters=~
            deployer=addr-4:zigs
            salt
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%deploy 'token-3' 'TT3' 'deploy-salt' `10.000 ~ ~[[addr-4:zigs 5.000]]]
    [caller-4 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-token-metadata
          (account:fungible addr-4:zigs id.p:new-token-metadata 5.000 salt ~)
      ==
      burned=`~
      events=`~
  ==
::
::  tests for %mint
::
++  test-zzz-mint  ^-  test-txn
  =/  new-token-metadata
    ^-  item:smart
    :*  %&
        (hash-data id:fungible id:fungible default-town-id salt:token-2)
        id:fungible
        id:fungible
        default-town-id
        salt:token-2
        %token-metadata
        :*  name='token-2'
            symbol='TT2'
            decimals=18
            supply=300.000
            cap=`10.000.000
            mintable=%.y
            minters=[addr-1:zigs ~ ~]
            deployer=addr-1:zigs
            salt:token-2
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%mint id.p:metadata:token-2 ~[[addr-1:zigs 100.000]]]
    [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-token-metadata
          (account:fungible addr-1:zigs id.p:metadata:token-2 200.000 salt:token-2 ~)
      ==
      burned=`~
      events=`~
  ==
::
::  tests for %give
::
++  test-zz-give  ^-  test-txn
  :^    chain
    [sequencer default-town-id batch=1 eth-block-height=0]
  :+  fake-sig
     [%give addr-2:zigs 50.000 id.p:account-1:token-2]
  [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account:fungible addr-1:zigs id.p:metadata:token-2 50.000 salt:token-2 ~)
          (account:fungible addr-2:zigs id.p:metadata:token-2 150.000 salt:token-2 ~)
      ==
      burned=`~
      events=`~
  ==
::
++  test-zz-give-new-address  ^-  test-txn
  :^    chain
    [sequencer default-town-id batch=1 eth-block-height=0]
  :+  fake-sig
     [%give addr-2:zigs 1.000 id.p:account-1:token-1]
  [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account:fungible addr-1:zigs id.p:metadata:token-1 99.000 salt:token-1 ~)
          (account:fungible addr-2:zigs id.p:metadata:token-1 1.000 salt:token-1 ~)
      ==
      burned=`~
      events=`~
  ==
::
++  test-zz-give-yourself  ^-  test-txn  :: should fail
  :^    chain
    [sequencer default-town-id batch=1 eth-block-height=0]
  :+  fake-sig
     [%give addr-1:zigs 1.000 id.p:account-1:token-1]
  [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%6  
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-zz-give-too-much  ^-  test-txn  :: should fail
  :^    chain
    [sequencer default-town-id batch=1 eth-block-height=0]
  :+  fake-sig
     [%give addr-2:zigs 100.000.000.000 id.p:account-1:token-1]
  [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%6  
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %take
::
++  test-yz-take  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%take addr-2:zigs 5.000 id.p:account-3:token-2]
    [caller-2 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account:fungible addr-2:zigs id.p:metadata:token-2 105.000 salt:token-2 ~)
          (account:fungible addr-3:zigs id.p:metadata:token-2 95.000 salt:token-2 ~[[addr-2:zigs 0]])
      ==
      burned=`~
      events=`~
  ==
::
++  test-yz-take-no-allowanc  ^-  test-txn  :: should fail
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%take addr-1:zigs 5.000 id.p:account-2:token-2]
    [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~  ::  we don't care
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %set-allowance
::
++  test-yz-set-allowance  ^-  test-txn  
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%set-allowance addr-2:zigs 15.000 id.p:account-1:token-2]
    [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~  ::  we don't care
      errorcode=`%0
      :-  ~
      %-  make-chain-state
      :~  (account:fungible addr-1:zigs id.p:metadata:token-2 100.000 salt:token-2 ~[[addr-2:zigs 15.000]])
      ==
      burned=`~
      events=`~
  ==
::
++  test-xy-set-allowance-again  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%set-allowance addr-2:zigs 0 id.p:account-3:token-2]
    [caller-3 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~ 
      errorcode=`%0
      :-  ~
      %-  make-chain-state
      :~  (account:fungible addr-3:zigs id.p:metadata:token-2 100.000 salt:token-2 ~[[addr-2:zigs 0]])
      ==
      burned=`~
      events=`~
  ==
::  
++  test-xx-set-allowance-self  ^-  test-txn  ::  should fail
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%set-allowance addr-1:zigs 5.000 id.p:account-1:token-2]
    [caller-1 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~ 
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %push
::
++  test-zz-push  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%push addr-1:zigs 50.000 id.p:account-2:token-2 [%random-call ~]]
    [caller-2 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%4  ::  0x1234.5678 is a missing pact, this is success
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %pull
::
++  test-zzx-pull  ^-  test-txn
  =/  =typed-message:smart
    :+  id.p:account-1:token-2                         :: domain, giver zigs account
      0x8a0c.ebea.b35e.84a1.1729.7c78.f677.f39a        :: pull-jold hash
    :*  addr-1:zigs                                    :: msg: [giver to amount nonce deadline]
        addr-2:zigs
        50.000
        0
        1.000
    ==
  =/  =sig:smart
    %+  ecdsa-raw-sign:secp256k1:secp:crypto
    `@uvI`(shag:smart typed-message)  priv-1:zigs
  =/  new-giver  ::  incrementing nonces for giver
    ^-  item:smart
    :*  %&
        (hash-data id:fungible addr-1:zigs default-town-id salt:token-2)
        id:fungible
        addr-1:zigs
        default-town-id
        salt:token-2
        %account
        :*  balance=50.000
            allowances=~
            id.p:metadata:token-2
            nonces=(make-pmap:smart ~[[addr-2:zigs 1]])
    ==  ==
  :^    chain
     [sequencer default-town-id batch=1 eth-block-height=999]
    :+  fake-sig
      [%pull addr-1:zigs addr-2:zigs 50.000 id.p:account-1:token-2 0 1.000 sig]
    [caller-2 ~ id:fungible [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      :-  ~
      %-  make-chain-state
      :~  (account:fungible addr-2:zigs id.p:metadata:token-2 150.000 salt:token-2 ~)
          new-giver
      ==
      burned=`~
      events=`~
  ==
--