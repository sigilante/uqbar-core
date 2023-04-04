::  lib/orgs.hoon  [UQ| DAO]
/+  *zig-sys-smart
|%
+$  tag  path
::
::  sub-orgs are stacked to create tags
::  note: each org can have its own controller,
::  but every org "above" in its tag-path can
::  unilaterally modify.
::
+$  org
  $@  %deleted
  $:  name=@t
      desc=(unit @t)  ::  optional label or description
      controller=id   ::  contract that is permitted to edit org
      members=(pset address)
      sub-orgs=(pmap @t org)
  ==
::
+$  action
  $%  ::  call this upon contract deployment
    [%create =org]
  ::
  ::  used to modify contents of an org. *cannot edit name-path*
  ::  tag selects which org/sub-org to edit
    [%edit-org org-id=id where=tag desc=(unit @t) controller=(unit id)]
  ::
  ::  must nest underneath existing org-structure
    [%add-sub-org org-id=id where=tag =org]
  ::
  ::  "it's over" -- can only use this on sub-orgs?
    [%delete-org org-id=id where=tag]
  ::
  ::  replace existing member-set of an org/sub-org
    [%replace-members org-id=id where=tag new=(pset address)]
  ::
  ::  add address to member-set of an org/sub-org
    [%add-member org-id=id where=tag =address]
  ::
  ::  remove address from member-set of an org/sub-org
    [%del-member org-id=id where=tag =address]
  ==
::
::  matches %social-graph API, but nodes always entities/addresses
::  nests under contract `event`
::
+$  org-event
  $%  [%add-tag =tag from=[%entity %orgs name=@t] to=[%address @ux]]
      [%del-tag =tag from=[%entity %orgs name=@t] to=[%address @ux]]
      [%nuke-tag =tag]  ::  remove this tag from all edges
      [%nuke-top-level-tag =tag]  :: remove all tags with same first element
  ==
::
::  helpers for producing events
::
++  add-tag
  |=  [=tag entity=@t =address]
  ^-  (list org-event)
  [%add-tag tag [%entity %orgs entity] [%address address]]^~
::
++  del-tag
  |=  [=tag entity=@t =address]
  ^-  (list org-event)
  [%del-tag tag [%entity %orgs entity] [%address address]]^~
::
++  nuke-tag
  |=  =tag
  ^-  (list org-event)
  [%nuke-tag tag]^~
::
++  make-tag
  |=  [=tag entity=@t members=(pset address)]
  ^-  (list event)
  %+  turn  ~(tap pn members)
  |=  =address
  [%add-tag tag [%entity %orgs entity] [%address address]]
::
::  make all the add-tag events for a new org
::
++  produce-org-events
  |=  [pre=path =org]
  ^-  (list org-event)
  ?:  ?=(%deleted org)  ~
  =/  =tag
    ?~  pre  /[name.org]
    (snoc pre name.org)
  ?>  ?=(^ tag)
  %+  weld
    %+  turn  ~(tap pn members.org)
    |=  =address
    [%add-tag tag [%entity %orgs i.tag] [%address address]]
  ^-  (list org-event)
  %-  zing
  %+  turn  ~(val py sub-orgs.org)
  |=  sub=^org
  (produce-org-events tag sub)
::
::  cannot touch name.org
+$  org-mod  $-(org org)
::
::  given an org, modify either that org or sub-org within
::
++  modify-org
  |=  [=org at=tag =org-mod]
  ^+  org
  ?<  ?=(%deleted org)
  ?~  at
    (org-mod org)
  ?>  =(i.at name.org)
  ?~  t.at
    (org-mod org)
  %=    org
      sub-orgs
    %+  ~(put py sub-orgs.org)
      i.t.at
    $(at t.at, org (~(got py sub-orgs.org) i.t.at))
  ==
--