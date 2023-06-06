/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
|^
;<  ~  bind:m
  %+  poke-our:strandio  %sequencer
  :-  %sidecar-action
  !>([%trigger-batch ~])
::
=/  args  !<((unit api-key) arg)
=/  url
  "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber"
=?    url
    ?=(^ args)
  (weld url (weld "&apikey=" (trip u.args)))
;<  =json  bind:m
  (fetch-json:strandio url)
=/  eth-block
  `@ud`(scan `tape`(slag 2 (pars json)) hex)
::
;<  batch-root=@ux  bind:m
  (scry:strandio @ux /gx/sequencer/pending-batch-root/noun)
::
;<  ~  bind:m
  %+  poke-our:strandio  %sequencer
  :-  %sidecar-action
  !>([%batch-posted 0x0 batch-root eth-block])
(pure:m !>(~))
::
+$  api-key  cord
++  pars
  =,  dejs:format
  %-  ot
  :~  [%result sa]
  ==
--