/-  *tx
/+  *test, *add-tx
|%
++  build-test-state
  ^-  state
  =/  asset
    [%fung 0x0 1.000]  ::  these are 'zigs'
  =/  a1  ::  test account 1
    [%asset-account 0x1234 0 ~[asset]]
  =/  a2  ::  test account 2
    [%asset-account 0x5678 0 ~[asset]]
  :: =/  a3  ::  test minter account
  ::   [0x5678 0 ~[asset]]
  :-  0x0  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2]])
++  test-process-tx-send
  =/  t
    :*  %send
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa]]
        10
        0x2
        ~[[%fung 0x1337 5]]
    ==
  ~&  (process-tx t build-test-state)
  :: ~&  state
  (expect-eq !>(%.y) !>(%.n))
++  test-process-tx-mint
  =/  t
    :*  %mint
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa]]
        10
        ~[[0x1 [%fung 0x1337 5]]]
    ==
  ~&  (process-tx t build-test-state)
  :: ~&  state
  (expect-eq !>(%.y) !>(%.n))
--