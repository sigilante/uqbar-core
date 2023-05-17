/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  ~  bind:m
  %+  poke-our:strandio  %wallet
  :-  %wallet-poke
  !>([%approve-origin [%thread /] [1 1.000.000]])
::
;<  ~  bind:m
  %+  poke-our:strandio  %uqbar
  :-  %wallet-poke
  !>  :*  %transaction  `[%thread /]
          from=0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70
          contract=0x74.6361.7274.6e6f.632d.7367.697a
          town=0x0
          :*  %give
              to=0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de
              amount=123.456
              item=0x7810.2b9f.109c.e44e.7de3.cd7b.ea4f.45dd.aed8.054c.0b52.b2c8.2788.93c6.5bb4.bb85
      ==  ==
::
(pure:m !>(~))
