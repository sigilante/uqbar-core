/+  *zig-sys-smart
|%
+$  action
  $%  $:  %deploy
          mutable=?
          code=[bat=* pay=*]
          interface=pith
      ==
  ::
      $:  %deploy-and-init
          mutable=?
          code=[bat=* pay=*]
          interface=pith
          init=calldata
      ==
  ::
      $:  %upgrade
          to-upgrade=id
          new-code=[bat=* pay=*]
          new-interface=pith
      ==
  ==
--
