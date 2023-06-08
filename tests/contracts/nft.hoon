::
::  tests for con/nft.hoon
::
/+  *test, *transaction-sim
/=  nft-lib  /con/lib/nft
/*  nft-contract  %jam  /con/compiled/nft/jam
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
++  my-shell  ^-  shell:smart
  [caller-1 ~ 0x0 [1 1.000.000] default-town-id 0]
::
++  nft
  |%
  ++  code
    (cue nft-contract)
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
  --
::
++  collection-1
  |%
  ++  salt
    (cat 3 'test-salt' addr-1:zigs)
  ++  metadata
    ^-  item:smart
    :*  %&
        (hash-data id:nft id:nft default-town-id salt)
        id:nft
        id:nft
        default-town-id
        salt
        %metadata
        :*  name='collection-1'
            symbol='TC1'
            properties=~
            supply=1
            cap=~
            mintable=%.y
            minters=[addr-1:zigs ~ ~]
            deployer=addr-1:zigs
            salt
    ==  ==
  ++  item-1
    ^-  item:smart
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt 1))
        id:nft
        addr-1:zigs
        default-town-id
        (cat 3 salt 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata
            allowances=[addr-2:zigs ~ ~]
            properties=~
            transferrable=%.y
    ==  ==
  --
::
++  collection-2
  |%
  ++  salt
    (cat 3 'test-salt' addr-2:zigs)
  ++  metadata
    ^-  item:smart
    :*  %&
        (hash-data id:nft id:nft default-town-id salt)
        id:nft
        id:nft
        default-town-id
        salt
        %metadata
        :*  name='collection-2'
            symbol='TC2'
            properties=~
            supply=1
            cap=~
            mintable=%.y
            minters=[addr-2:zigs ~ ~]
            deployer=addr-1:zigs
            salt
    ==  ==
  ++  item-1
    ^-  item:smart
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt 1))
        id:nft
        addr-1:zigs
        default-town-id
        (cat 3 salt 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata
            allowances=~
            properties=~
            transferrable=%.n
    ==  ==
  ++  item-2
    ^-  item:smart
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt 2))
        id:nft
        addr-2:zigs
        default-town-id
        (cat 3 salt 2)
        %nft
        :*  2
            'asdfasdfasdf'
            id.p:metadata
            allowances=~
            properties=~
            transferrable=%.n
    ==  ==
  --
::
++  state
  %-  make-chain-state
  :~  pact:zigs
      pact:nft
      metadata:collection-1
      item-1:collection-1
      metadata:collection-2
      item-1:collection-2
      item-2:collection-2
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
++  test-zz-nft-give  ^-  test-txn
  =/  new-item-1
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 1))
        id:nft
        addr-2:zigs
        default-town-id
        (cat 3 salt:collection-1 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=~
            properties=~
            transferrable=%.y
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%give addr-2:zigs id.p:item-1:collection-1]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-item-1
      ==
      burned=`~
      events=`~
  ==
::
++  test-zy-nft-give-not-owned  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%give addr-2:zigs id.p:item-1:collection-1]
    [caller-2 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-zx-nft-give-nontransferrable  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%give addr-2:zigs id.p:item-1:collection-2]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
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
  =/  new-item-1
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 1))
        id:nft
        addr-2:zigs
        default-town-id
        (cat 3 salt:collection-1 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=~
            properties=~
            transferrable=%.y
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%take addr-2:zigs id.p:item-1:collection-1]
    [caller-2 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-item-1
      ==
      burned=`~
      events=`~
  ==
::
::  tests for %push
::
++  test-xz-push  ^-  test-txn
  =/  new-item-1
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 1))
        id:nft
        addr-2:zigs
        default-town-id
        (cat 3 salt:collection-1 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=(make-pset:smart ~[addr-2:zigs 0x1234.5678])
            properties=~
            transferrable=%.y
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%push 0x1234.5678 id.p:item-1:collection-1 [%hello ~]]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%4  ::  0x1234.5678 is a missing pact, this is success
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %pull
::
++  test-wz-pull  ^-  test-txn
  *test-txn
::
::  tests for %set-allowance
::
++  test-vz-set-new-allowance  ^-  test-txn
  =/  new-item-1
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 1))
        id:nft
        addr-1:zigs
        default-town-id
        (cat 3 salt:collection-1 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=(make-pset:smart ~[addr-2:zigs 0x1234.5678])
            properties=~
            transferrable=%.y
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%set-allowance ~[[0x1234.5678 id.p:item-1:collection-1 %.y]]]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-item-1
      ==
      burned=`~
      events=`~
  ==
::
++  test-vy-clear-allowance  ^-  test-txn
  =/  new-item-1
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 1))
        id:nft
        addr-1:zigs
        default-town-id
        (cat 3 salt:collection-1 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=~
            properties=~
            transferrable=%.y
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%set-allowance ~[[addr-2:zigs id.p:item-1:collection-1 %.n]]]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-item-1
      ==
      burned=`~
      events=`~
  ==
::
++  test-vx-set-new-allowance-clear-old  ^-  test-txn
  =/  new-item-1
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 1))
        id:nft
        addr-1:zigs
        default-town-id
        (cat 3 salt:collection-1 1)
        %nft
        :*  1
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=[0x1234.5678 ~ ~]
            properties=~
            transferrable=%.y
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%set-allowance ~[[0x1234.5678 id.p:item-1:collection-1 %.y] [addr-2:zigs id.p:item-1:collection-1 %.n]]]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-item-1
      ==
      burned=`~
      events=`~
  ==
::
::  tests for %mint
::
++  test-uz-mint  ^-  test-txn
  =/  new-item-2
    :*  %&
        (hash-data id:nft addr-1:zigs default-town-id (cat 3 salt:collection-1 2))
        id:nft
        addr-1:zigs
        default-town-id
        (cat 3 salt:collection-1 2)
        %nft
        :*  2
            'asdfasdfasdf'
            id.p:metadata:collection-1
            allowances=~
            properties=~
            transferrable=%.y
    ==  ==
  ::  new collection metadata supply is 2
  ::  todo: just change noun.p.metadata( wing
  =/  new-metadata
    ^-  item:smart
    :*  %&
        (hash-data id:nft id:nft default-town-id salt:collection-1)
        id:nft
        id:nft
        default-town-id
        salt:collection-1
        %metadata
        :*  name='collection-1'
            symbol='TC1'
            properties=~
            supply=2
            cap=~
            mintable=%.y
            minters=[addr-1:zigs ~ ~]
            deployer=addr-1:zigs
            salt:collection-1
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%mint id.p:metadata:collection-1 ~[[addr-1:zigs 'asdfasdfasdf' ~ %.y]]]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-item-2
          new-metadata          
      ==
      burned=`~
      events=`~
  ==
::
::  tests for %deploy
::
++  test-tz-deploy  ^-  test-txn
  =/  salt  (cat 3 'deploy-salt' addr-1:zigs)  
  =/  new-collection
    ^-  item:smart
    :*  %&
        (hash-data id:nft id:nft default-town-id salt)
        id:nft
        id:nft
        default-town-id
        salt
        %metadata
        :*  name='collection-3'
            symbol='TC3'
            properties=~
            supply=0
            cap=~
            mintable=%.y
            minters=[addr-1:zigs ~ ~]
            deployer=addr-1:zigs
            salt
    ==  ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    :+  fake-sig
      [%deploy 'collection-3' 'TC3' 'deploy-salt' ~ ~ [addr-1:zigs ~ ~] ~]
    [caller-1 ~ id:nft [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  new-collection
      ==
      burned=`~
      events=`~
  ==
--
