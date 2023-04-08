/-  spider
/+  strandio, *transaction-sim
/*  smart-lib-noun  %noun  /lib/zig/sys/smart-lib/noun
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  =bowl:strand  bind:m  get-bowl:strandio
=/  paz=(list path)
  :: cast path to ~[path] if needed
  ::
  ?@  +<.q.arg
    [(tail !<([~ path] arg)) ~]
  (tail !<([~ (list path)] arg))
=/  bez=(list beam)
  (turn paz |=(p=path ~|([%test-not-beam p] (need (de-beam p)))))
;<  fiz=(set [=beam test=(unit term)])  bind:m  (find-test-files bez)
=>  .(fiz (sort ~(tap in fiz) aor))
=|  test-arms=(map path (list test-arm))
=|  build-ok=?
|-  ^-  form:m
=/  eng
  %~  engine  engine
  :^  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  *(map * @)  jets:zink  [%.n %.n]  ::  sigs off, hints off
::
=*  gather-tests  $
?^  fiz
  ;<  cor=(unit vase)  bind:m  (build-file:strandio beam.i.fiz)
  ?~  cor
    ~>  %slog.0^leaf+"FAILED  {(spud s.beam.i.fiz)} (build)"
    gather-tests(fiz t.fiz, build-ok |)
  ~>  %slog.0^leaf+"built   {(spud s.beam.i.fiz)}"
  =/  arms=(list test-arm)  (get-test-arms u.cor)
  =.  test-arms  (~(put by test-arms) (snip s.beam.i.fiz) arms)
  gather-tests(fiz t.fiz)
::
=/  res=(list path)
  %+  murn  (resolve-test-paths test-arms)
  |=  [=path =test-txn]
  =/  =output
    %~  intake  %~  eng  eng
      engine-data.test-txn
    [chain transaction]:test-txn
  ~&  >  "running {<path>}"
  ?:  (check-output output expected.test-txn)
    ~
  `path
%-  pure:m  !>
?~  res  'ALL OK'
[%failed-tests res]
