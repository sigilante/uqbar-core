::  lib/zigs.hoon [UQ| DAO]
::
/+  *zig-sys-smart
|%
++  sur
  |%
  +$  token-metadata
    ::  will be automatically inserted into town state
    ::  at instantiation, along with this contract
    ::  hardcoded values included to match token standard
    $:  name=@t
        symbol=@t
        decimals=@ud
        supply=@ud
        cap=~  ::  no pre-set supply cap
        mintable=%.n
        minters=~
        deployer=address  ::  will be 0x0
        salt=@            ::  'zigs'
    ==
  ::
  +$  account
    $:  balance=@ud
        allowances=(pmap address @ud)
        metadata=id
        nonces=(pmap address @ud)
    ==
  ::
  +$  action
    $%  $:  %give
            budget=@ud
            to=address
            amount=@ud
            from-account=id
        ==
    ::
        $:  %take
            to=address
            amount=@ud
            from-account=id
        ==
    ::
        $:  %push
            to=address
            amount=@ud
            from-account=id
            calldata=*
        ==
    ::
        $:  %pull
            from=address
            to=address
            amount=@ud
            from-account=id
            nonce=@ud
            deadline=@ud
            =sig
        ==
    ::
        $:  %set-allowance
            who=address
            amount=@ud  ::  (to revoke, call with amount=0)
            account=id
        ==
    ==
  --
::
++  lib
  |%
  ::  see lib/fungible.hoon
  ++  pull-jold-hash  0x8a0c.ebea.b35e.84a1.1729.7c78.f677.f39a
  ::  for %pull signatures
  ++  generate-eth-hash
    |=  =hash
    ^-  @ux
    %-  keccak-256:keccak:crypto
    %-  as-octt:mimes:html
    %+  weld  "\19Ethereum Signed Message:\0a"       :: eth signed message, 
    =+  len=(lent (trip (scot %ux hash)))            :: note, don't use ++scow
    %+  weld  (a-co:co len)                          :: prefix + len(msg)[no dots] + msg
    (trip (scot %ux hash))                                  
  ::
  ++  recover-pub
    |=  [=hash =sig]
    ^-  address
    =?  v.sig  (gte v.sig 27)  (sub v.sig 27)
    =?  hash  (gth (met 3 hash) 32)  (end [3 32] hash)
    %-  address-from-pub
    %-  serialize-point:secp256k1:secp:crypto
    (ecdsa-raw-recover:secp256k1:secp:crypto hash sig) 
  --
--
