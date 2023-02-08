/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
|^
=/  args  !<((unit api-key) arg)
?~  args
  ~&  >>>  "must add etherscan api key"
  !!
;<  =json  bind:m
    %-  fetch-json:strandio
    %+  weld
      "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey="
    (trip u.args)
(pure:m !>(`@ud`(scan `tape`(slag 2 (pars json)) hex)))
::
+$  api-key  cord
++  pars
  =,  dejs:format
  %-  ot
  :~  [%result sa]
  ==
--