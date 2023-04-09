::
::  tests for con/orgs.hoon
::
/+  *test, *transaction-sim
/=  org-lib  /con/lib/orgs
/*  orgs-contract  %jam  /con/compiled/orgs/jam
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
  [caller-1 ~ id.p:orgs-pact [1 1.000.000] default-town-id 0]
::
++  orgs-pact
  ^-  item:smart
  =/  code  (cue orgs-contract)
  =/  id  (hash-pact:smart 0x1234.5678 0x1234.5678 default-town-id code)
  :*  %|  id
      0x1234.5678  ::  source
      0x1234.5678  ::  holder
      default-town-id
      [-.code +.code]
      ~
  ==
::
++  my-test-org-id
  ^-  id:smart
  %:  hash-data:smart
      id.p:orgs-pact
      addr-1:zigs
      default-town-id
      'my-test-org'
  ==
++  my-test-org
  |=  =org:org-lib
  ^-  item:smart
  :*  %&  my-test-org-id
      id.p:orgs-pact
      addr-1:zigs
      default-town-id
      'my-test-org'
      %org
      org
  ==
::
++  state
  %-  make-chain-state
  :~  orgs-pact
      %-  my-test-org
      :*  'my-test-org'
          `'an org controlled by 0xd387...'
          addr-1:zigs
          ~
          %-  make-pmap:smart
          ~['my-sub-org'^['my-sub-org' ~ addr-2:zigs ~ ~]]
      ==
      (account addr-1 300.000.000 ~):zigs
      (account addr-2 200.000.000 ~):zigs
  ==
++  chain
  ^-  chain:engine
  [state ~]
::
::  tests for %create
::
++  test-zz-create  ^-  test-txn
  =/  my-org
    ^-  org:org-lib
    :*  'squidz'
        `'an organization for squids'
        addr-1:zigs
        (make-pset:smart ~[addr-1:zigs])
        ~
    ==
  =/  org-item
    ^-  item:smart
    :*  %&
        %:  hash-data:smart
            id.p:orgs-pact
            addr-1:zigs
            default-town-id
            'squidz'
        ==
        id.p:orgs-pact
        addr-1:zigs
        default-town-id
        'squidz'
        %org
        my-org
    ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    [fake-sig [%create my-org] my-shell]
  :*  gas=~
      errorcode=`%0
      modified=`(make-chain-state ~[org-item])
      burned=`~
      ::  events
      :-  ~  :_  ~
      :+  id.p:orgs-pact  %add-tag
      [/squidz [%entity %orgs 'squidz'] [%address addr-1:zigs]]
  ==
::
++  test-zy-create-not-publisher  ^-  test-txn
  =/  my-org
    ^-  org:org-lib
    :*  'squidz'
        `'an organization for squids'
        addr-1:zigs
        (make-pset:smart ~[addr-1:zigs])
        ~
    ==
  =/  org-item
    ^-  item:smart
    :*  %&
        %:  hash-data:smart
            id.p:orgs-pact
            addr-1:zigs
            default-town-id
            'squidz'
        ==
        id.p:orgs-pact
        addr-1:zigs
        default-town-id
        'squidz'
        %org
        my-org
    ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    =-  [fake-sig [%create my-org] -]
    [caller-2 ~ id.p:orgs-pact [1 1.000.000] default-town-id 0]
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-zy-create-deleted  ^-  test-txn
  =/  my-org
    ^-  org:org-lib
    %deleted
  =/  org-item
    ^-  item:smart
    :*  %&
        %:  hash-data:smart
            id.p:orgs-pact
            addr-1:zigs
            default-town-id
            'squidz'
        ==
        id.p:orgs-pact
        addr-1:zigs
        default-town-id
        'squidz'
        %org
        my-org
    ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    [fake-sig [%create my-org] my-shell]
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
::  tests for %edit-org
::
++  test-yz-edit-org-not-controller  ^-  test-txn
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    =+  [caller-2 ~ id.p:orgs-pact [1 1.000.000] default-town-id 0]
    [fake-sig [%edit-org my-test-org-id /my-test-org `'newdesc' ~] -]
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-yy-edit-org
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    [fake-sig [%edit-org my-test-org-id /my-test-org `'newdesc' ~] my-shell]
  :*  gas=~
      errorcode=`%0
      ::  modified the org
      :-  ~
      %-  make-chain-state
      :_  ~
      %-  my-test-org
      :*  'my-test-org'
          `'newdesc'
          addr-1:zigs
          ~
          %-  make-pmap:smart
          ~['my-sub-org'^['my-sub-org' ~ addr-2:zigs ~ ~]]
      ==
      burned=`~
      events=`~
  ==
--
