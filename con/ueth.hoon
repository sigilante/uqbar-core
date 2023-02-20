::  eth.hoon [UQ| DAO]
::
::  Instantiation of the fungible standard in a special-case contract
::  for ETH bridged onto town
::
/+  *zig-sys-smart
/=  fungible  /con/lib/fungible
=,  fungible
|_  =context
++  write
  |=  act=action:sur
  ^-  (quip call diff)
  ?+  -.act  !!
    %give           (give:lib context act)
    %take           (take:lib context act)
    %pull           (pull:lib context act)
    %push           (push:lib context act)
    %set-allowance  (set-allowance:lib context act)
  ==
::
++  read
  |=  =pith
  ?+    pith  !!
      [%get-balance [%ux @ux] ~]
    =+  (need (scry-state +.i.t.pith))
    =+  (husk account:sur - ~ ~)
    balance.noun.-
  ==
--
