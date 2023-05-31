::  account.hoon [UQ| DAO]
/+  *zig-sys-smart
|_  =context
++  write
  |^
  |=  =action
  ^-  (quip call diff)
  ?-    -.action
      %validate
    ::  trivial validation function: only executes if num is 7
    ::  can perform ECDSA signature validation here, multisig,
    ::  or something else entirely...
    ::  test running out of gas here with num=5
    ?:  =(num.action 5)
      |-  $(num.action +(num.action))
    ?>  =(num.action 7)
    [call.action^~ [~ ~ ~ ~]]
  ==
  ::
  +$  action
    $%  ::  these two actions required for all AA contracts
        ::  scries DO NOT WORK inside validate!
        ::  if invalid, should just crash. if valid,
        ::  should issue *exactly one* continuation call,
        ::  which will be executed with gas paid by this
        ::  contract.
        [%validate num=@ud =call]  ::  can put anything after %validate
    ==
  --
::
++  read
  |=  =pith
  ~
--
