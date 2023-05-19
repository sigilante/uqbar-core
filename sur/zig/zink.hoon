|%
+$  chain-state-scry
  $-  [gas=@ud ^]
  [gas=@ud pays=(map @ux @ud) product=(unit *)]
::
+$  child  *
+$  parent  *
::  map from jet tag to gas cost
+$  jetmap  (map @tas @ud)
::
++  jets
  ^-  (map @tas @ud)
  ::  TODO: determine *real* costs
  ::  these are totally made up placeholders
  %-  ~(gas by *(map @tas @ud))
  :~  ::  math
      [%add 1]  [%dec 1]  [%div 1]
      [%dvr 1]  [%gte 1]  [%gth 1]
      [%lte 1]  [%lth 1]  [%max 1]
      [%min 1]  [%mod 1]  [%mul 1]
      [%sub 1]
      ::  bits
      [%bex 1]  [%can 1]  [%cat 1]
      [%cut 1]  [%end 1]  [%fil 1]
      [%lsh 1]  [%met 1]  [%rap 1]
      [%rep 1]  [%rev 1]  [%rip 1]
      [%rsh 1]  [%run 1]  [%rut 1]
      [%sew 1]  [%swp 1]  [%xeb 1]
      ::  list
      ::  [%turn 5]
      ::  sha
      [%sham 1.000]
      [%shax 1.000]
      [%shay 1.000]
      ::  merklization
      [%rlp-encode 100]
      ::  etc
      [%need 1]
      [%scot 5]
      ::  crypto
      [%k224 100]  [%k256 100]  [%k384 100]  [%k512 100]
      [%make 100]  [%sign 100]  [%reco 100]
  ==
--
