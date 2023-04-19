::  orgs.hoon [UQ| DAO]
::
::  manage an organization on-chain
::
::  this contract is designed to emit updates to a %social-graph.
::  NOT FOR DAOs! DAOs should be self-governing. orgs.hoon allows
::  users to create user-controlled organizations. control of the
::  org is delegated to an id, which can be a multisig contract,
::  some person's address, or something else entirely...
::
::  why not generic? one likely wants to subscribe to events from
::  one contract per organization. in the future, watching events
::  associated with one item in particular could be easy, in which
::  case, can genericize this easily.
::
/+  *zig-sys-smart
/=  lib  /con/lib/orgs
|_  =context
++  write
  |=  act=action:lib
  ^-  (quip call diff)
  ?:  ?=(%create -.act)
    ::  called by publish contract: %deploy-and-init
    ::  swap this out for 0x1111.1111 on testnet
    ?>  =(0xd387.95ec.b77f.b88e.c577.6c20.d470.d13c.8d53.2169 id.caller.context)
    =/  =item
      :*  %&
          %:  hash-data
              this.context
              controller.org.act
              town.context
              name.org.act
          ==
          this.context
          controller.org.act
          town.context
          name.org.act
          %org
          org.act
      ==
    =-  `(result ~ [item ~] ~ -)
    (produce-org-events:lib / org.act)
  ::
  =/  org
    =+  (need (scry-state org-id.act))
    (husk org:lib - `this.context ~)
  ::  caller must control identified org
  ?>  =(id.caller.context controller.noun.org)
  =^  events  noun.org
    ?-    -.act
        %edit-org
      :-  ~
      %^  modify-org:lib
        noun.org  where.act
      |=  =org:lib
      %=    org
          desc
        ?~(desc.act desc.org desc.act)
          controller
        ?~(controller.act controller.org u.controller.act)
      ==
    ::
        %add-sub-org
      :-  (produce-org-events:lib where.act org.act)
      %^  modify-org:lib
        noun.org  where.act
      |=  =org:lib
      =-  org(sub-orgs -)
      (~(put py sub-orgs.org) [name.org org]:act)
    ::
        %delete-org
      !!  ::  TODO
    ::
        %replace-members
      :-  %+  weld  (nuke-tag:lib where.act)
          (make-tag:lib where.act name.noun.org new.act)
      %^  modify-org:lib
        noun.org  where.act
      |=(=org:lib org(members new.act))
    ::
        %add-member
      :-  (add-tag:lib where.act name.noun.org ship.act)
      %^  modify-org:lib
        noun.org  where.act
      |=  =org:lib
      org(members (~(put pn members.org) ship.act))
    ::
        %del-member
      :-  (del-tag:lib where.act name.noun.org ship.act)
      %^  modify-org:lib
        noun.org  where.act
      |=  =org:lib
      org(members (~(del pn members.org) ship.act))
    ==
  `(result [&+org ~] ~ ~ events)
::
++  read
  |=  =pith
  ~  ::  TODO
--
