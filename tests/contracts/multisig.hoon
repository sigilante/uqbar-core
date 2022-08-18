::
::  Tests for multisig.hoon
::
/-  zink
/+  *test, smart=zig-sys-smart, *sequencer, merk
/*  smart-lib-noun     %noun  /lib/zig/compiled/smart-lib/noun
/*  zink-cax-noun      %noun  /lib/zig/compiled/hash-cache/noun
/*  multisig-contract  %noun  /lib/zig/compiled/multisig/noun
|%
::
::  constants / dummy info for mill
::
++  big  (bi:merk id:smart grain:smart)  ::  merkle engine for granary
++  pig  (bi:merk id:smart @ud)          ::                for populace
++  town-id   0x0
++  batch-num  1
++  fake-sig  [0 0 0]
++  mil
  %~  mill  mill
  :+    ;;(vase (cue q.q.smart-lib-noun))
    ;;((map * @) (cue q.q.zink-cax-noun))
  %.y
::
+$  mill-result
  [fee=@ud =land burned=granary =errorcode:smart hits=(list hints:zink) =crow:smart]
::
::  fake data
::
++  miller  ^-  caller:smart
  [0x24c.23b9.8535.cd5a.0645.5486.69fb.afbf.095e.fcc0 1 0x0]  ::  zigs account not used
++  holder-1  0xd387.95ec.b77f.b88e.c577.6c20.d470.d13c.8d53.2169
++  holder-2  0xface.face.face.face.face.face.face.face.face.face
++  holder-3  0x1c9b.638f.9e4e.c79f.e0da.fa2f.296c.54be.5092.e47a
++  caller-1  ^-  caller:smart  [holder-1 1 (make-id:zigs holder-1)]
++  caller-2  ^-  caller:smart  [holder-2 1 (make-id:zigs holder-2)]
++  caller-3  ^-  caller:smart  [holder-3 1 (make-id:zigs holder-3)]
::
++  zigs
  |%
  ++  make-id
    |=  holder=id:smart
    (fry-rice:smart zigs-wheat-id:smart holder town-id `@`'zigs')
  ++  make-account
    |=  [holder=id:smart amt=@ud]
    ^-  grain:smart
    :*  %&  `@`'zigs'  %account
        [amt ~ `@ux`'zigs-metadata-id']
        (make-id holder)
        zigs-wheat-id:smart
        holder
        town-id
    ==
  --
::
++  multisig-wheat
  ^-  grain:smart
  =/  cont  ;;([bat=* pay=*] (cue q.q.multisig-contract))
  =/  interface=lumps:smart  ~
  =/  types=lumps:smart  ~
  :*  %|
      `cont
      interface
      types
      0xdada.dada  ::  id
      0xdada.dada  ::  lord
      0xdada.dada  ::  holder
      town-id
  ==
::
++  two-man-sig
  ^-  grain:smart
  =/  salt
    `@`(shag:smart (cat 3 id:caller-1 0))
  =/  =id:smart
    (fry-rice:smart id.p:multisig-wheat id.p:multisig-wheat town-id salt)
  =/  members
    %-  ~(gas pn:smart *(pset:smart address:smart))
    ~[id:caller-1 id:caller-2]
  =/  proposal
    :^  [id.p:multisig-wheat town-id [%add-member id holder-3]]^~
    ~  0  0
  =/  pending
    %-  ~(gas py:smart *(pmap:smart @ux _proposal))
    [0x1234 proposal]^~
  :*  %&  salt  %multisig
      [members 2 pending]
      id
      id.p:multisig-wheat
      id.p:multisig-wheat
      town-id
  ==
::
++  fake-granary
  ^-  granary
  %+  gas:big  *(merk:merk id:smart grain:smart)
  %+  turn
    :~  multisig-wheat
        two-man-sig
        (make-account:zigs holder-1 300.000.000)
        (make-account:zigs holder-2 300.000.000)
        (make-account:zigs holder-3 300.000.000)
    ==
  |=(=grain:smart [id.p.grain grain])
::
++  fake-populace
  ^-  populace
  %+  gas:pig  *(merk:merk id:smart @ud)
  ~[[id:caller-1 0]]
++  fake-land
  ^-  land
  [fake-granary fake-populace]
::
::  types
::
+$  proposal
  $:  calls=(list [to=id:smart town=id:smart =yolk:smart])
      votes=(pmap:smart address:smart ?)
      ayes=@ud
      nays=@ud
  ==
::
+$  multisig-state
  $:  members=(pset:smart address:smart)
      threshold=@ud
      pending=(pmap:smart @ux proposal)
  ==
::
::  begin tests
::
::  tests for %create
::
++  test-create-multisig
  =/  member-set  (~(gas pn:smart *(pset:smart address:smart)) ~[id:caller-1])
  =/  =yolk:smart  [%create 1 member-set]
  =/  shel=shell:smart
    [caller-1 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id batch-num)
      fake-land
    `egg:smart`[fake-sig shel yolk]
  ::
  =/  correct-salt  (shag:smart (cat 3 id:caller-1 batch-num))
  =/  correct-id
    (fry-rice:smart id.p:multisig-wheat id.p:multisig-wheat town-id correct-salt)
  =/  correct
    ^-  grain:smart
    :*  %&
        correct-salt
        %multisig
        [member-set 1 ~]
        correct-id
        id.p:multisig-wheat
        id.p:multisig-wheat
        town-id
    ==
  ::
  ;:  weld
  ::  assert that our call went through
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::  assert new contract grain was created properly
    %+  expect-eq
      !>(correct)
    !>((got:big p.land.res correct-id))
  ==
::
++  test-create-no-members
  !!
::
++  test-create-high-threshold
  !!
::
++  test-create-many-members
  !!
::
::  tests for %vote
::
++  test-vote-not-member
  =/  =yolk:smart  [%vote id.p:two-man-sig 0x1234 %.y]
  =/  shel=shell:smart
    [caller-3 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id batch-num)
      fake-land
    `egg:smart`[fake-sig shel yolk]
  ::
  %+  expect-eq
  !>(%6)  !>(errorcode.res)
::
++  test-vote-no-proposal
  =/  =yolk:smart  [%vote id.p:two-man-sig 0x6789 %.y]
  =/  shel=shell:smart
    [caller-3 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id batch-num)
      fake-land
    `egg:smart`[fake-sig shel yolk]
  ::
  %+  expect-eq
  !>(%6)  !>(errorcode.res)
::
++  test-vote-aye
  =/  =yolk:smart  [%vote id.p:two-man-sig 0x1234 %.y]
  =/  shel=shell:smart
    [caller-1 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id batch-num)
      fake-land
    `egg:smart`[fake-sig shel yolk]
  =/  correct-proposal
    :^  [id.p:multisig-wheat town-id [%add-member id.p:two-man-sig holder-3]]^~
      %-  ~(gas py:smart *(pmap:smart address:smart ?))
      [id:caller-1 %.y]^~
    1  0
  ::
  ;:  weld
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::
    %+  expect-eq
      !>(correct-proposal)
    !>  =+  (got:big p.land.res id.p:two-man-sig)
        =+  data:(husk:smart multisig-state - ~ ~)
        (~(got py:smart pending.-) 0x1234)
  ==
::
++  test-vote-nay
  =/  =yolk:smart  [%vote id.p:two-man-sig 0x1234 %.n]
  =/  shel=shell:smart
    [caller-1 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id batch-num)
      fake-land
    `egg:smart`[fake-sig shel yolk]
  =/  correct-proposal
    :^  [id.p:multisig-wheat town-id [%add-member id.p:two-man-sig holder-3]]^~
      %-  ~(gas py:smart *(pmap:smart address:smart ?))
      [id:caller-1 %.n]^~
    0  1
  ::
  ;:  weld
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::
    %+  expect-eq
      !>(correct-proposal)
    !>  =+  (got:big p.land.res id.p:two-man-sig)
        =+  data:(husk:smart multisig-state - ~ ~)
        (~(got py:smart pending.-) 0x1234)
  ==
::
++  test-vote-execute
  =/  =yolk:smart  [%vote id.p:two-man-sig 0x1234 %.y]
  =/  shel-1=shell:smart
    [caller-1 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res-1=mill-result
    %+  ~(mill mil miller town-id batch-num)
      fake-land
    `egg:smart`[fake-sig shel-1 yolk]
  =/  shel-2=shell:smart
    [caller-2 ~ id.p:multisig-wheat 1 1.000.000 town-id 0]
  =/  res-2=mill-result
    %+  ~(mill mil miller town-id batch-num)
      land.res-1
    `egg:smart`[fake-sig shel-2 yolk]


  =/  correct-multisig
    :^  [id.p:multisig-wheat town-id [%add-member id.p:two-man-sig holder-3]]^~
      %-  ~(gas py:smart *(pmap:smart address:smart ?))
      [id:caller-1 %.y]^~
    1  0
  ::
  ;:  weld
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::
    %+  expect-eq
      !>(correct-proposal)
    !>  =+  (got:big p.land.res id.p:two-man-sig)
        =+  data:(husk:smart multisig-state - ~ ~)
        (~(got py:smart pending.-) 0x1234)
  ==
::
::  tests for %propose
::
++  test-propose
  !!
::
++  test-propose-not-member
  !!
::
::  tests for %add-member, %remove-member, %set-threshold
::
++  test-add-member
  !!
::
++  test-remove-member
  !!
::
++  test-set-threshold
  !!
::
++  test-set-threshold-too-low
  !!
--