::  bridge-fungible.hoon [UQ| DAO]
::
::  Fungible token implementation using the fungible standard in
::  lib/fungible. Removes mint/deploy functionality as those are
::  handled by the sequencer/engine alone
::
/+  *zig-sys-smart
/=  fungible  /con/lib/fungible
=,  fungible
=>  |%
    +$  action
      $%  give:sur  take:sur
          push:sur  pull:sur
          set-allowance:sur
      ==
    --
::
|_  =context
++  write
  |=  act=action
  ^-  (quip call diff)
  ?-  -.act
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
