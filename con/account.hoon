::  account.hoon [UQ| DAO]
/+  *zig-sys-smart
|_  =context
++  write
  |^
  |=  =action
  ^-  (quip call diff)
  ?-    -.action
      %validate
    ::  limited to how much gas?
    [call.action^~ [~ ~ ~ ~]]
  ==
  ::
  +$  action
    $%  ::  these two actions required for all AA contracts
        ::  scries DO NOT WORK inside validate
        ::  if invalid, should just crash. if valid,
        ::  should issue *exactly one* continuation call,
        ::  which will be executed with gas paid by this
        ::  contract.
        [%validate =call]  ::  can put anything after %validate
    ==
  --
::
++  read
  |=  =pith
  ~
--
