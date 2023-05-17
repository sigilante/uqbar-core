/-  *zig-zink
/+  smart=zig-sys-smart
=>  |%
    +$  good      (unit *)
    +$  fail      (list [@ta *])
    +$  body      (each good fail)
    +$  pays      (map id:smart @ud)  ::  payments for fee-gated scry paths
    +$  appendix  [jets=jetmap =pays gas=@]
    +$  book      (pair body appendix)
    --
|%
++  zebra                                                 ::  bounded zk +mule
  |=  [gas=@ud =jetmap scry=chain-state-scry [s=* f=*]]
  ^-  book
  ~>  %bout
  %.  [s f scry]
  %*  .  zink
    app  [jetmap ~ gas]
  ==
::
++  zink
  =|  appendix
  =*  app  -
  =|  trace=fail
  |=  [s=* f=* scry=chain-state-scry]
  ^-  book
  |^
  |-
  ?+    f
    [%|^trace app]
  ::
      [^ *]
    =^  hed=body  app
      $(f -.f)
    ?:  ?=(%| -.hed)  [%|^trace app]
    ?~  p.hed  [%&^~ app]
    =^  tal=body  app
      $(f +.f)
    ?:  ?=(%| -.tal)  [%|^trace app]
    ?~  p.tal  [%&^~ app]
    [[%& ~ u.p.hed^u.p.tal] app]
  ::
      [%0 axis=@]
    =^  part  gas
      (frag axis.f s gas)
    ?~  part  [%&^~ app]
    ?~  u.part  [%|^trace app]
    [[%& ~ u.u.part] app]
  ::
      [%1 const=*]
    [[%& ~ const.f] app]
  ::
      [%2 sub=* for=*]
    =^  subject=body  app
      $(f sub.f)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =^  formula=body  app
      $(f for.f)
    ?:  ?=(%| -.formula)  [%|^trace app]
    ?~  p.formula  [%&^~ app]
    %_  $
      s  u.p.subject
      f  u.p.formula
    ==
  ::
      [%3 arg=*]
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  [%|^trace app]
    ?~  p.argument  [%&^~ app]
    ?@  u.p.argument
      [[%& ~ %.n] app]
    [[%& ~ %.y] app]
  ::
      [%4 arg=*]
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  [%|^trace app]
    ?~  p.argument  [%&^~ app]
    ?^  u.p.argument  [%|^trace app]
    [[%& ~ .+(u.p.argument)] app]
  ::
      [%5 a=* b=*]
    =^  a=body  app
      $(f a.f)
    ?:  ?=(%| -.a)  [%|^trace app]
    ?~  p.a  [%&^~ app]
    =^  b=body  app
      $(f b.f)
    ?:  ?=(%| -.b)  [%|^trace app]
    ?~  p.b  [%&^~ app]
    [[%& ~ =(u.p.a u.p.b)] app]
  ::
      [%6 test=* yes=* no=*]
    =^  result=body  app
      $(f test.f)
    ?:  ?=(%| -.result)  [%|^trace app]
    ?~  p.result  [%&^~ app]
    ?+  u.p.result  [%|^trace app]
      %&  $(f yes.f)
      %|  $(f no.f)
    ==
  ::
      [%7 subj=* next=*]
    =^  subject=body  app
      $(f subj.f)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    %_  $
      s    u.p.subject
      f    next.f
    ==
  ::
      [%8 head=* next=*]
    =^  head=body  app
      $(f head.f)
    ?:  ?=(%| -.head)  [%|^trace app]
    ?~  p.head  [%&^~ app]
    %_  $
      s    [u.p.head s]
      f    next.f
    ==
  ::
      [%9 axis=@ core=*]
    =^  core=body  app
      $(f core.f)
    ?:  ?=(%| -.core)  [%|^trace app]
    ?~  p.core  [%&^~ app]
    =^  arm  gas
      (frag axis.f u.p.core gas)
    ?~  arm  [%&^~ app]
    ?~  u.arm  [%|^trace app]
    %_  $
      s  u.p.core
      f  u.u.arm
    ==
  ::
      [%10 [axis=@ value=*] target=*]
    ?:  =(0 axis.f)  [%|^trace app]
    =^  target=body  app
      $(f target.f)
    ?:  ?=(%| -.target)  [%|^trace app]
    ?~  p.target  [%&^~ app]
    =^  value=body  app
      $(f value.f)
    ?:  ?=(%| -.value)  [%|^trace app]
    ?~  p.value  [%&^~ app]
    =^  mutant=(unit (unit *))  gas
      (edit axis.f u.p.target u.p.value gas)
    ?~  mutant  [%&^~ app]
    ?~  u.mutant  [%|^trace app]
    =^  oldleaf  gas
      (frag axis.f u.p.target gas)
    ?~  oldleaf  [%&^~ app]
    ?~  u.oldleaf  [%|^trace app]
    [[%& ~ u.u.mutant] app]
  ::
       [%11 tag=@ next=*]
    ::  ~&  >  `@tas`tag.f
    =^  next=body  app
      $(f next.f)
    :_  app
    ?:  ?=(%| -.next)  %|^trace
    ?~  p.next  %&^~
    :+  %&  ~
    .*  s
    [11 tag.f 1 u.p.next]
  ::
      [%11 [tag=@ clue=*] next=*]
    ::  look for jet with this tag and compute sample
    =^  sam=body  app
      $(f clue.f)
    ?:  ?=(%| -.sam)  [%|^trace app]
    ?~  p.sam  [%&^~ app]
    ::  if jet exists for this tag, and sample is good,
    ::  replace execution with jet
    =^  jax=body  app
      ?:  ?=(?(%hunk %hand %lose %mean %spot) tag.f)
        [%&^~ app]
      (jet tag.f u.p.sam)
    ?:  ?=(%| -.jax)  [%|^trace app]
    ?^  p.jax  [%& p.jax]^app
    ::  jet not found, proceed with normal computation
    =^  clue=body  app
      $(f clue.f)
    ?:  ?=(%| -.clue)  [%|^trace app]
    ?~  p.clue  [%&^~ app]
    =^  next=body  app
      =?    trace
          ?=(?(%hunk %hand %lose %mean %spot) tag.f)
        [[tag.f u.p.clue] trace]
      $(f next.f)
    :_  app
    ?:  ?=(%| -.next)  %|^trace
    ?~  p.next  %&^~
    :+  %&  ~
    .*  s
    [11 [tag.f 1 u.p.clue] 1 u.p.next]
  ::
      [%12 ref=* path=*]
    =^  ref=body  app
      $(f ref.f)
    ?:  ?=(%| -.ref)     [%|^trace app]
    ?~  p.ref            [%&^~ app]
    =^  path=body  app
      $(f path.f)
    ?:  ?=(%| -.path)    [%|^trace app]
    ?~  p.path           [%&^~ app]
    =/  result  (scry gas p.ref p.path)
    =.  pays.app
      %-  (~(uno by pays.app) pays.result)
      |=([k=@ux f1=@ud f2=@ud] (add f1 f2))
    ?~  product.result
      [%&^~^~ app(gas gas.result)]
    [%&^[~ product.result] app(gas gas.result)]
  ==
  ::
  ++  jet
    |=  [tag=@ sam=*]
    ^-  book
    ?:  ?=(%slog tag)
      ::  print trace printfs?
      [%&^~ app]
    ?:  ?=(%mean tag)
      ::  this is a crash..
      [%|^trace app]
    ?~  cost=(~(get by jets.app) tag)
      ::  ~&  [%missing-jet `@tas`tag]
      [%&^~ app]
    ::  ~&  [%running-jet `@tas`tag]
    ?:  (lth gas u.cost)  [%&^~ app]
    :-  (run-jet tag sam `@ud`u.cost)
    app(gas (sub gas u.cost))
  ::
  ++  run-jet
    |=  [tag=@ sam=* cost=@ud]
    ^-  body
    ::  TODO: probably unsustainable to need to include assertions to
    ::  make all jets crash safe.
    ?+    tag  %|^trace
    ::                                                                       ::
    ::  math                                                                 ::
    ::                                                                       ::
        %add
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (add sam))
    ::
        %dec
      ?.  ?=(@ sam)  %|^trace
      %&^(some (dec sam))
    ::
        %div
      ?.  ?=([@ @] sam)  %|^trace
      ?.  (gth +.sam 0)  %|^trace
      %&^(some (div sam))
    ::
        %dvr
      ?.  ?=([@ @] sam)  %|^trace
      ?.  (gth +.sam 0)  %|^trace
      %&^(some (dvr sam))
    ::
        %gte
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (gte sam))
    ::
        %gth
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (gth sam))
    ::
        %lte
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (lte sam))
    ::
        %lth
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (lth sam))
    ::
        %max
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (max sam))
    ::
        %min
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (min sam))
    ::
        %mod
      ?.  ?=([@ @] sam)  %|^trace
      ?.  (gth +.sam 0)  %|^trace
      %&^(some (mod sam))
    ::
        %mul
      ?.  ?=([@ @] sam)  %|^trace
      %&^(some (mul sam))
    ::
        %sub
      ?.  ?=([@ @] sam)      %|^trace
      ?.  (gte -.sam +.sam)  %|^trace
      %&^(some (sub sam))
    ::                                                                       ::
    ::  bits                                                                 ::
    ::                                                                       ::
        %bex
      ?.  ?=(bloq sam)  %|^trace
      %&^(some (bex sam))
    ::
        %can
      ::  TODO validate
      %&^(some (slum can sam))
    ::
        %cat
      ?.  ?=([bloq @ @] sam)  %|^trace
      %&^(some (cat sam))
    ::
        %cut
      ?.  ?=([bloq [step step] @] sam)  %|^trace
      %&^(some (cut sam))
    ::
        %end
      ?.  ?=([bite @] sam)  %|^trace
      %&^(some (end sam))
    ::
        %fil
      ?.  ?=([bloq step @] sam)  %|^trace
      %&^(some (fil sam))
    ::
        %lsh
      ?.  ?=([bloq @] sam)  %|^trace
      %&^(some (lsh sam))
    ::
        %met
      ?.  ?=([bloq @] sam)  %|^trace
      %&^(some (met sam))
    ::
        %rap
      ::  TODO validate
      %&^(some (slum rap sam))
    ::
        %rep
      ::  TODO validate
      %&^(some (slum rep sam))
    ::
        %rev
      ?.  ?=([bloq @ud @] sam)  %|^trace
      %&^(some (rev sam))
    ::
        %rip
      ?.  ?=([bite @] sam)  %|^trace
      %&^(some (rip sam))
    ::
        %rsh
      ?.  ?=([bite @] sam)  %|^trace
      %&^(some (rsh sam))
    ::
        %run
      ::  TODO validate
      %&^(some (slum run sam))
    ::
        %rut
      ::  TODO validate
      %&^(some (slum rut sam))
    ::
        %sew
      ?.  ?=([bloq [step step @] @] sam)  %|^trace
      %&^(some (sew sam))
    ::
        %swp
      ?.  ?=([bloq @] sam)  %|^trace
      %&^(some (swp sam))
    ::
        %xeb
      ?.  ?=(@ sam)  %|^trace
      %&^(some (xeb sam))
    ::
    ::                                                                       ::
    ::  list                                                                 ::
    ::                                                                       ::
      ::  this one actually fails, so really need to find a better way.
      ::    %turn
      ::  ::  TODO: determine how best to validate complex jet inputs
      ::  ::  this will crash if the input is bad.
      ::  %&^(some (slum turn sam))
    ::                                                                       ::
    ::  sha                                                                  ::
    ::                                                                       ::
        %sham
      %&^(some (sham sam))
    ::
        %shax
      ?.  ?=(@ sam)  %|^trace
      %&^(some (shax sam))
    ::
        %shay
      ?.  ?=([@u @] sam)  %|^trace
      %&^(some (shay sam))
    ::                                                                       ::
    ::  merklization                                                         ::
    ::                                                                       ::
    ::      %shag
    ::    %&^(some (shag:smart sam))
    ::  ::
    ::      %sore
    ::    ?.  ?=([* *] sam)  %|^trace
    ::    %&^(some (sore:smart sam))
    ::  ::
    ::      %sure
    ::    ?.  ?=([* *] sam)  %|^trace
    ::    %&^(some (sure:smart sam))
    ::
        %rlp-encode
      %&^(some (encode:rlp:smart sam))
    ::                                                                       ::
    ::  etc                                                                  ::
    ::                                                                       ::
        %need
      ?.  ?=((unit) sam)  %|^trace
      ?:  ?=(~ sam)       %|^trace
      %&^(some (need sam))
    ::
        %scot
      ?.  ?=([@ta @] sam)  %|^trace
      %&^(some (scot sam))
    ::                                                                       ::
    ::  crypto                                                               ::
    ::                                                                       ::
        %k224
      ?.  ?=([@ud @] sam)  %|^trace
      %&^(some (keccak-224:keccak:crypto sam))
    ::
        %k256
      ?.  ?=([@ud @] sam)  %|^trace
      %&^(some (keccak-256:keccak:crypto sam))
    ::
        %k384
      ?.  ?=([@ud @] sam)  %|^trace
      %&^(some (keccak-384:keccak:crypto sam))
    ::
        %k512
      ?.  ?=([@ud @] sam)  %|^trace
      %&^(some (keccak-512:keccak:crypto sam))
    ::
        %make
      ?.  ?=([@uvI @] sam)  %|^trace
      %&^(some (make-k:secp256k1:secp:crypto sam))
    ::
        %sign
      ?.  ?=([@uvI @] sam)  %|^trace
      %&^(some (ecdsa-raw-sign:secp256k1:secp:crypto sam))
    ::
        %reco
      ?.  ?=([@ [@ @ @]] sam)  %|^trace
      %&^(some (ecdsa-raw-recover:secp256k1:secp:crypto sam))
    ==
  ::
  ++  frag
    |=  [axis=@ noun=* gas=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(0 axis)  [`~ gas]
    |-  ^-  [(unit (unit)) @ud]
    ?:  =(0 gas)  [~ gas]
    ?:  =(1 axis)  [``noun (dec gas)]
    ?@  noun  [`~ (dec gas)]
    =/  pick  (cap axis)
    %=  $
      axis  (mas axis)
      noun  ?-(pick %2 -.noun, %3 +.noun)
      gas   (dec gas)
    ==
  ::
  ++  edit
    |=  [axis=@ target=* value=* gas=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(1 axis)  [``value gas]
    ?@  target  [`~ gas]
    ?:  =(0 gas)  [~ gas]
    =/  pick  (cap axis)
    =^  mutant  gas
      %=  $
        axis    (mas axis)
        target  ?-(pick %2 -.target, %3 +.target)
        gas     (dec gas)
      ==
    ?~  mutant  [~ gas]
    ?~  u.mutant  [`~ gas]
    ?-  pick
      %2  [``[u.u.mutant +.target] gas]
      %3  [``[-.target u.u.mutant] gas]
    ==
  --
--
