::  nft.hoon [UQ| DAO]
::
::  Bridged NFTs. Same as nft.hoon but removes deploy/mint functionality
::  as this is handled by the engine and sequencer.
::
/+  *zig-sys-smart
/=  nft  /con/lib/nft
=,  nft
::
=>  |%
    +$  action
      $%  give:sur  take:sur
          set-allowance:sur
      ==
    --
::
|_  =context
++  write
  |=  act=action
  ^-  (quip call diff)
  ?-  -.act
    %give           (give:lib:nft context act)
    %take           (take:lib:nft context act)
    %set-allowance  (set-allowance:lib:nft context act)
  ==
::
++  read
  |=  =pith
  ~
--
