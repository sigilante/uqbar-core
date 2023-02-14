/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
|^
=/  args  !<((unit api-key) arg)
=/  url
  "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber"
=?    url
    ?=(^ args)
  (weld url (weld "&apikey=" (trip u.args)))
::  ~&  url
;<  =json  bind:m
  (fetch-json:strandio url)
(pure:m !>(`@ud`(scan `tape`(slag 2 (pars json)) hex)))
::
+$  api-key  cord
++  pars
  =,  dejs:format
  %-  ot
  :~  [%result sa]
  ==
--