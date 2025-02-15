::  engine-tester.hoon [UQ| DAO]
::
::  Contract purpose-built to probe specific failure modes in engine.hoon.
::
::  Used in /tests/lib/engine.hoon
::
::  Should be source of one dummy item, a piece of data
::
/+  *zig-sys-smart
|_  =context
++  write
  |=  act=*
  ^-  (quip call diff)
  =/  new-id=id
    (hash-data this.context id.caller.context town.context 'salt')
  =/  new=item
    =+  ['salt' %label 'noun']
    [%& new-id this.context id.caller.context town.context -]
  ?+    act  `(result ~ ~ ~ ~)
      [%change-nonexistent ~]
    `(result [new ~] ~ ~ ~)
  ::
      [%change-type dummy=id]
    =+  i=(need (scry-state dummy.act))
    =/  new
      =+  [[~ ~] ~]  ::  empty pact
      [%| id.p.i source.p.i holder.p.i town.p.i -]
    `(result [new ~] ~ ~ ~)
  ::
      [%change-id dummy=id]
    =+  i=(need (scry-state dummy.act))
    =.  id.p.i  0x8888
    `(result [i ~] ~ ~ ~)
  ::
      [%change-salt dummy=id]
    =+  i=(need (scry-state dummy.act))
    ?>  ?=(%& -.i)
    =.  salt.p.i  `@`'some-new-salt'
    `(result [i ~] ~ ~ ~)
  ::
      [%change-source dummy=id]
    =+  i=(need (scry-state dummy.act))
    =.  source.p.i  zigs-contract-id
    `(result [i ~] ~ ~ ~)
  ::
      [%changed-issued-overlap ~]
    `(result [new ~] [new ~] ~ ~)
  ::
      [%change-without-provenance zigs=id]
    ::  call with zigs account data
    =+  z=(need (scry-state zigs.act))
    ?>  ?=(%& -.z)
    =.  noun.p.z  ['new' 'data']
    `(result [z ~] ~ ~ ~)
  ::
      [%issue-non-matching-id ~]
    =.  id.p.new  0x7864.8957
    =-  `[~ - ~ ~]
    (gas:big *(merk id item) ~[[new-id new]])
  ::
      [%issue-bad-data-id ~]
    =.  id.p.new  0x7864.8957
    `(result ~ [new ~] ~ ~)
  ::
      [%issue-bad-pact-id ~]
    =/  bad-pact
      [0x123 this.context this.context town.context [~ ~] ~]
    `(result ~ [%|^bad-pact ~] ~ ~)
  ::
      [%issue-without-provenance ~]
    =.  source.p.new  0xabcd.efef
    `(result ~ [new ~] ~ ~)
  ::
      [%issue-already-existing dummy=id]
    =+  i=(need (scry-state dummy.act))
    `(result ~ [i ~] ~ ~)
  ::
      [%burn-nonexistent ~]
    `(result ~ ~ [new ~] ~)
  ::
      [%burn-non-matching-id dummy=id]
    =+  i=(need (scry-state dummy.act))
    =/  old-id  id.p.i
    =.  id.p.i  0x7864.8957
    =-  `[~ ~ - ~]
    (gas:big *(merk id item) ~[[old-id i]])
  ::
      [%burn-changed-overlap dummy=id]
    =+  i=(need (scry-state dummy.act))
    `(result [i ~] ~ [i ~] ~)
  ::
      [%burn-issued-overlap ~]
    `(result ~ [new ~] [new ~] ~)
  ::
      [%burn-without-provenance zigs=id]
    =+  z=(need (scry-state zigs.act))
    `(result ~ ~ [z ~] ~)
  ::
      [%burn-change-source dummy=id]
    =+  i=(need (scry-state dummy.act))
    =.  source.p.i  zigs-contract-id
    `(result ~ ~ [i ~] ~)
  ::
  ::  actions for testing continuation calls
  ::
      [%exit ~]
    `[~ ~ ~ [%exit-event ~]~]
  ::
      [%simple-self-call ~]
    :_  (result ~ ~ ~ [%entry-event ~]~)
    [this.context town.context [%exit ~]]~
  ::
      [%triple-self-call ~]
    :_  (result ~ ~ ~ [%triple-event ~]~)
    :~  [this.context town.context [%simple-self-call ~]]
        [this.context town.context [%simple-self-call ~]]
        [this.context town.context [%simple-self-call ~]]
    ==
  ::
      [%modify-and-call dummy=id]
    =+  i=(need (scry-state dummy.act))
    ?>  ?=(%& -.i)
    =.  noun.p.i  'my new noun!'
    :_  (result [i ~] ~ ~ ~)
    [this.context town.context [%read-modified dummy.act]]~
  ::
      [%read-modified dummy=id]
    =+  i=(need (scry-state dummy.act))
    ?>  ?=(%& -.i)
    =/  event  [%i-read s+;;(@t noun.p.i)]
    `(result ~ ~ ~ event^~)
  ::
      [%just-modify dummy=id]
    =+  i=(need (scry-state dummy.act))
    ?>  ?=(%& -.i)
    =.  noun.p.i  'my new noun!'
    `(result [i ~] ~ ~ ~)
  ::
      [%modify-and-read-separately dummy=id]
    :_  (result ~ ~ ~ ~)
    :~  [this.context town.context [%just-modify dummy.act]]
        [this.context town.context [%read-modified dummy.act]]
    ==
  ::
      [%do-scry ~]
    =+  (scry-contract this.context [%free-scry ~])
    ?~  -  !!
    ?.  =(u.- %hello-world)  !!
    `(result ~ ~ ~ ~)
  ::
      [%do-paid-scry ~]
    =+  (scry-contract this.context [%fee [%ud 1.007] %paid-scry ~])
    ?~  -  !!
    ?.  =(u.- %thanks-for-paying)  !!
    `(result ~ ~ ~ ~)
  ::
      [%do-scry-bad-fee ~]
    =+  (scry-contract this.context [%fee [%ud 7] %paid-scry ~])
    ?~  -  `(result ~ ~ ~ ~)
    !!
  ::
      [%do-paid-scry-2 dummy=id]
    =+  %-  need
        %+  scry-contract  this.context
        [%fee [%ud 1.702] %pay-more [%ux dummy.act] ~]
    `(result ~ ~ ~ [%read-event -]^~)
  ::
      [%do-crashing-scry]
    =+  (scry-contract this.context [%free-crashing-scry ~])
    ?~  -  `(result ~ ~ ~ ~)
    !!
  ::
      [%do-paid-crashing-scry]
    =+  (scry-contract this.context [%fee [%ud 1.007] %paid-crashing-scry ~])
    ?~  -  `(result ~ ~ ~ ~)
    !!
  ::
      [%do-malformed-scry-1]
    =+  (scry-contract this.context [%fee %malformed-pith [%ud 100] ~])
    ?~  -  `(result ~ ~ ~ ~)
    !!
  ::
      [%do-malformed-scry-2]
    =+  (scry-contract this.context [%fee ~])
    `(result ~ ~ ~ ~)
  ::
      [%call-crash ~]
    :_  (result ~ ~ ~ ~)
    [this.context town.context [%crash ~]]~
  ::
      [%crash ~]
    !!
  ==
::
++  read
  |=  =pith
  ?+    pith  !!
      [%free-scry ~]
    %hello-world
  ::
      [%fee [%ud @ud] %paid-scry ~]
    ?>  =(+.i.t.pith 1.007)
    %thanks-for-paying
  ::
      [%fee [%ud @ud] %pay-more [%ux @ux] ~]
    ?>  =(+.i.t.pith 1.702)
    =+  i=(need (scry-state +.i.t.t.t.pith))
    ?>  ?=(%& -.i)
    noun.p.i
  ::
      [%free-crashing-scry ~]
    !!
  ::
      [%fee [%ud @ud] %paid-crashing-scry ~]
    !!
  ::
      [%fee %malformed-pith [%ud @ud] ~]
    ~
  ::
      [%fee ~]
    ~
  ==
--
