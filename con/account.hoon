::  account.hoon [UQ| DAO]
/+  *zig-sys-smart
|_  =context
++  write
  |^
  |=  =action
  ^-  (quip call diff)
  `[~ ~ ~ ~]
  ::
  +$  action
    $%  ::  these two actions required for all AA contracts
        ::  scries DO NOT WORK inside validate
        [%validate *]
        ::  this contract is very simple, just does signatures..
        ::  but abstractly. once you create account, contract
        ::  lets you %validate arbitrary calldata with a valid
        ::  sigature matching a created account. contract must
        ::  have zigs sent to it in order to execute stuff.
        [%create-account =address]
    ==
  --
::
++  read
  |=  =pith
  ~
--
