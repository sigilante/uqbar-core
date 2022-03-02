/+  *bink, *zig-sys-smart
|_  [miller=account town-id=@ud blocknum=@ud now=time]
::
::  +mill-all: mills all eggs in mempool
::
++  mill-all
  |=  [=town mempool=(list egg)]
  =/  pending
    %+  sort  mempool
    |=  [a=egg b=egg]
    (gth rate.p.a rate.p.b)
  =|  [processed=(list [@ux egg]) reward=@ud]      
  |-
  ::  'chunk' def 
  ^-  [(list [@ux egg]) ^town]
  ?~  pending
    [processed town(p (~(pay tax p.town) reward))]
  =+  [res fee]=(mill town i.pending)
  %_  $
    pending    t.pending
    processed  [[`@ux`(shax (jam i.pending)) i.pending] processed]
    town       res
    reward     (add reward fee)
  ==
::  +mill: processes a single egg and returns updated town
::
++  mill
  |=  [=town =egg]
  ^-  [^town fee=@ud]
  ?.  ?=(account from.p.egg)  [town 0]
  ?~  curr-nonce=(~(get by q.town) id.from.p.egg)
    [town 0]  ::  missing account
  ?.  =(nonce.from.p.egg +(u.curr-nonce))
    [town 0]  ::  bad nonce
  ?.  (~(audit tax p.town) egg)
    [town 0]  ::  can't afford gas
  =+  [gan rem]=(~(work farm p.town) egg)
  =/  fee=@ud   (sub budget.p.egg rem)
  :_  fee
  :-  ?~  gan  (~(charge tax p.town) from.p.egg fee)
      (~(charge tax u.gan) from.p.egg fee)
  (~(put by q.town) id.from.p.egg nonce.from.p.egg)
::
::  +tax: manage payment for egg in zigs
::
++  tax
  |_  =granary
  +$  account-mold
    $:  balance=@ud
        allowances=(map sender=id @ud)
    ==
  ::  +audit: evaluate whether a caller can afford gas
  ++  audit
    |=  =egg
    ^-  ?
    ?.  ?=(account from.p.egg)                    %.n
    ?~  zigs=(~(get by granary) zigs.from.p.egg)  %.n
    ?.  ?=(%& -.germ.u.zigs)                      %.n
    =/  acc  (hole account-mold data.p.germ.u.zigs)
    (gth balance.acc budget.p.egg)
  ::  +charge: extract gas fee from caller's zigs balance
  ++  charge
    |=  [payee=account fee=@ud]
    ^-  ^granary 
    ?~  zigs=(~(get by granary) zigs.payee)  granary
    ?.  ?=(%& -.germ.u.zigs)                 granary
    =/  acc  (hole account-mold data.p.germ.u.zigs)
    =.  balance.acc  (sub balance.acc fee)
    =.  data.p.germ.u.zigs  acc
    (~(put by granary) zigs.payee u.zigs)
  ::  +pay: give fees from eggs to miller
  ++  pay
    |=  total=@ud
    ^-  ^granary
    ?~  zigs=(~(get by granary) zigs.miller)  granary
    ?.  ?=(%& -.germ.u.zigs)                  granary
    =/  acc  (hole account-mold data.p.germ.u.zigs)
    =.  balance.acc  (add balance.acc total)
    =.  data.p.germ.u.zigs  acc
    (~(put by granary) zigs.miller u.zigs)
  --
::
::  +farm: execute a call to a contract within a wheat
::
++  farm
  |_  =granary
  ::
  ++  work
    |=  =egg
    ^-  [(unit ^granary) @ud]
    =/  hatchling
      (incubate egg(budget.p (div budget.p.egg rate.p.egg)))
    :_  +.hatchling
    ?~  -.hatchling  ~
    (harvest u.-.hatchling to.p.egg from.p.egg)
  ::
  ++  incubate
    |=  =egg
    ^-  [(unit rooster) @ud]
    |^
    =/  args  (fertilize q.egg)
    ?~  stalk=(germinate to.p.egg cont-grains.q.egg)
      `budget.p.egg
    (grow u.stalk args egg)
    ::
    ++  fertilize
      |=  =yolk
      ^-  zygote
      ?.  ?=(account caller.yolk)  !!
      :+  caller.yolk
        args.yolk
      %-  ~(gas by *(map id grain))
      %+  murn  ~(tap in my-grains.yolk)
      |=  =id
      ?~  res=(~(get by granary) id)      ~
      ?.  ?=(%& -.germ.u.res)             ~
      ?.  =(holder.u.res id.caller.yolk)  ~
      `[id u.res]
    ::
    ++  germinate
      |=  [find=id grains=(set id)]
      ^-  (unit crop)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)           ~
      ?~  cont.p.germ.u.gra             ~
      :+  ~
        (hole contract u.cont.p.germ.u.gra)
      %-  ~(gas by *(map id grain))
      %+  murn  ~(tap in grains)
      |=  =id
      ?~  res=(~(get by granary) id)  ~
      ?.  ?=(%& -.germ.u.res)         ~
      ?.  =(lord.u.res find)          ~
      `[id u.res]
    --
  ::
  ++  grow
    |=  [=crop =zygote =egg]
    ^-  [(unit rooster) @ud]
    |^
    =+  [chick rem]=(weed crop to.p.egg [%& zygote] ~ budget.p.egg)
    ?~  chick  `rem
    ?:  ?=(%& -.u.chick)
      ::  rooster result, finished growing
      [`p.u.chick rem]
    ::  hen result, continuation
    |-
    =*  next  next.p.u.chick
    =*  mem   mem.p.u.chick
    =^  child  rem
      (incubate egg(from.p to.p.egg, to.p to.next, budget.p rem, q args.next))
    ?~  child  `rem
    =/  gan  (harvest u.child to.p.egg from.p.egg)
    ?~  gan  `rem
    =.  granary  u.gan
    =^  eve  rem
      (weed crop to.p.egg [%| u.child] mem rem)
    ?~  eve  `rem
    ?:  ?=(%& -.u.eve)
      [`p.u.eve rem]
    %_  $
      next.p.u.chick  next.p.u.eve
      mem.p.u.chick   mem.p.u.eve
    ==
    ::
    ++  weed
      |=  [=^crop to=id inp=embryo mem=(unit vase) budget=@ud]
      ^-  [(unit chick) @ud]
      =/  cart  [mem to blocknum town-id owns.crop]
      =+  [res bud]=(barn contract.crop inp cart budget)
      ?~  res               `bud
      ?:  ?=(%| -.u.res)    `bud
      ?:  ?=(%& -.p.u.res)  `bud
      ::  write or event result
      [`p.p.u.res bud]
    ::
    ::  +barn: run contract formula with arguments and memory, bounded by bud
    ::  [note: contract reads are scrys performed in sequencer]
    ++  barn
      |=  [=contract inp=embryo =cart bud=@ud]
      ^-  [(unit (each (each * chick) (list tank))) @ud]
      |^
      ?:  ?=(%| -.inp)
        ::  event
        =/  res  (event p.inp)
        ?~  -.res  `+.res
        ?:  ?=(%& -.u.-.res)
          [`[%& %| p.u.-.res] +.res]
        [`[%| p.u.-.res] +.res]
      ::  write
      =/  res  (write p.inp)
      ?~  -.res  `+.res
      ?:  ?=(%& -.u.-.res)
        [`[%& %| p.u.-.res] +.res]
      [`[%| p.u.-.res] +.res]
      ::
      ::  note:  i believe the way we're using ;; here destroys
      ::  any trace data we may get out of the contract. the
      ::  output trace ends up resolving at the ;; rather than
      ::  wherever in the contract caused a stack trace.
      ::
      ::  using +mule here and charging no gas until jet dashboard for +bink
      ++  write
        |=  =^zygote
        ^-  [(unit (each chick (list tank))) @ud]
        :_  (sub bud 7)
        `(mule |.(;;(chick (~(write contract cart) zygote))))
      ++  event
        |=  =rooster
        ^-  [(unit (each chick (list tank))) @ud]
        :_  (sub bud 8)
        `(mule |.(;;(chick (~(event contract cart) rooster))))
      --
    --
  ::
  ++  harvest
    |=  [res=rooster lord=id from=caller]
    ^-  (unit ^granary)
    =-  ?.  -  ~
        `(~(uni by granary) (~(uni by changed.res) issued.res))
    ?&  %-  ~(all in changed.res)
        |=  [=id =grain]
        ::  id in changed map must be equal to id in grain AND
        ::  all changed grains must already exist AND
        ::  no changed grains may also have been issued at same time AND
        ::  only grains that proclaim us lord may be changed
        ?&  =(id id.grain)
            (~(has by granary) id.grain)
            !(~(has by issued.res) id.grain)
            =(lord lord:(~(got by granary) id))
        ==
      ::
        %-  ~(all in issued.res)
        |=  [=id =grain]
        ::  id in issued map must be equal to id in grain AND
        ::  all newly issued grains must have properly-hashed id AND
        ::  lord of grain must be contract issuing it
        ?&  =(id id.grain)
            =((fry lord.grain town-id.grain germ.grain) id.grain)
            =(lord lord.grain)
    ==  ==
  --
--