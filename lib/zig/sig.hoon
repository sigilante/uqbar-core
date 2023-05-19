/+  ethereum, smart=zig-sys-smart
|%
+$  ship-sig   [p=@ux q=ship r=life]
::
::  uqbar address signature validation
::
++  uqbar-validate
  |=  [=address:smart msg=@ =sig:smart]
  ^-  ?
  =?    v.sig
      (gte v.sig 27)
    (sub v.sig 27)
  =/  virt=toon
    %+  mong
      :-  ecdsa-raw-recover:secp256k1:secp:crypto
      [msg sig]
    ,~
  ?.  ?=(%0 -.virt)  %.n  ::  invalid sig
  .=  address
  %-  address-from-pub:key:ethereum
  %-  serialize-point:secp256k1:secp:crypto
  ;;([x=@ y=@] p.virt)
::
::  ship signing
::
++  jael-scry
  |*  [=mold our=ship desk=term now=time =path]
  .^  mold
    %j
    (scot %p our)
    desk
    (scot %da now)
    path
  ==
::
++  sign
  |=  [our=ship now=time hash=@]
  ^-  ship-sig
  =+  (jael-scry ,=life our %life now /(scot %p our))
  =+  (jael-scry ,=ring our %vein now /(scot %ud life))
  :+  `@ux`(sign:as:(nol:nu:crub:crypto ring) hash)
    our
  life
::
++  validate
  |=  [our=ship =ship-sig hash=@ now=time]
  ^-  ?
  =+  (jael-scry ,lyf=(unit @) our %lyfe now /(scot %p q.ship-sig))
  ::  we do not have a public key from ship at this life
  ::
  ?~  lyf  %.y
  ?.  =(u.lyf r.ship-sig)  %.y
  =+  %:  jael-scry
        ,deed=[a=life b=pass c=(unit @ux)]
        our  %deed  now  /(scot %p q.ship-sig)/(scot %ud r.ship-sig)
      ==
  ::  if ship-sig is from a past life, skip validation
  ::  XX: should be visualised on frontend, not great.
  ?.  =(a.deed r.ship-sig)  %.y
  ::  verify ship-sig from ship at life
  ::
  =/  them
    (com:nu:crub:crypto b.deed)
  =(`hash (sure:as.them p.ship-sig))
--
