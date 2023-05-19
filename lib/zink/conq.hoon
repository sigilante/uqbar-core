/+  *zink-zink, smart=zig-sys-smart, engine=zig-sys-engine
/*  smart-lib-noun  %noun  /lib/zig/sys/smart-lib/noun
/*  triv-txt        %hoon  /con/trivial/hoon
|%
++  compile-path
  |=  pax=path
  ^-  [bat=* pay=*]
  =/  desk=path  (swag [0 3] pax)
  (compile-contract desk .^(@t %cx pax))
::
++  compile-contract
  |=  [desk=path txt=@t]
  ^-  [bat=* pay=*]
  ::
  ::  goal flow:
  ::  - take main file, parse to find libs
  ::  - for each lib, parse to find any libs there
  ::  - if an import is already present in that stack
  ::    (circular), crash
  ::  - once a file with no imports is reached, (rain ) it
  ::  - compose against this back up the stack
  ::
  ::  old stuff:
  ::
  ::  parse contract code
  =/  [raw=(list [face=term =path]) contract-hoon=hoon]
    (parse-pile (trip txt))
  ::  generate initial subject containing uHoon
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  ::  compose libraries against uHoon subject
  =/  libraries=hoon
    :-  %clsg
    %+  turn  raw
    |=  [face=term =path]
    =/  pax  (weld desk path)
    ^-  hoon
    :+  %ktts  face
    =/  lib-txt  .^(@t %cx (welp pax /hoon))
    ::  CURRENTLY IGNORING IMPORTS INSIDE LIBRARIES
    +:(parse-pile (trip lib-txt))
  =/  pay=*  q:(~(mint ut p.smart-lib) %noun libraries)
  =/  payload=vase  (slap smart-lib libraries)
  =/  cont
    %+  ~(mint ut p:(slop smart-lib payload))
    %noun  contract-hoon
  ::
  [bat=q.cont pay]
::
++  compile-trivial
  |=  [hoonlib-txt=@t smartlib-txt=@t]
  ^-  vase
  =/  [raw=(list [face=term =path]) contract-hoon=hoon]
    (parse-pile (trip triv-txt))
  =/  smart-lib=vase
    ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  libraries=hoon  [%clsg ~]
  =/  full-nock=*     q:(~(mint ut p.smart-lib) %noun libraries)
  =/  payload=vase    (slap smart-lib libraries)
  ::
  (slap (slop smart-lib payload) contract-hoon)
::
::  conq helpers
++  arm-axis
  |=  [vax=vase arm=term]
  ^-  @
  =/  r  (~(find ut p.vax) %read ~[arm])
  ?>  ?=(%& -.r)
  ?>  ?=(%| -.q.p.r)
  p.q.p.r
::
::  parser helpers
::
+$  small-pile
    $:  raw=(list [face=term =path])
        =hoon
    ==
+$  taut  [face=(unit term) pax=term]
++  parse-pile
  |=  tex=tape
  ^-  small-pile
  =/  [=hair res=(unit [=small-pile =nail])]  (pile-rule [1 1] tex)
  ?^  res  small-pile.u.res
  %-  mean  %-  flop
  =/  lyn  p.hair
  =/  col  q.hair
  :~  leaf+"syntax error"
      leaf+"\{{<lyn>} {<col>}}"
      leaf+(runt [(dec col) '-'] "^")
      leaf+(trip (snag (dec lyn) (to-wain:format (crip tex))))
  ==
++  pile-rule
  %-  full
  %+  ifix
    :_  gay
    ::  parse optional smart library import and ignore
    ;~(plug gay (punt ;~(plug fas lus gap taut-rule gap)))
  ;~  plug
  ::  only accept /= imports for contract libraries
    %+  rune  tis
    ;~(plug sym ;~(pfix gap stap))
  ::
    %+  stag  %tssg
    (most gap tall:vast)
  ==
++  rune
  |*  [bus=rule fel=rule]
  %-  pant
  %+  mast  gap
  ;~(pfix fas bus gap fel)
++  pant
  |*  fel=rule
  ;~(pose fel (easy ~))
++  mast
  |*  [bus=rule fel=rule]
  ;~(sfix (more bus fel) bus)
++  taut-rule
  %+  cook  |=(taut +<)
  ;~  pose
    (stag ~ ;~(pfix tar sym))
    ;~(plug (stag ~ sym) ;~(pfix tis sym))
    (cook |=(a=term [`a a]) sym)
  ==
--