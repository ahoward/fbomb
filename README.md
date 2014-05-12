NAME
====
  fbomb

SYNOPSIS
========
  fbomb is the dangerous, easily customizable flowdock robot

TL;DR;
======
```bash

  ~> ./bin/fbomb setup

    # edit your config

  ~> ./bin/fbomb start

    # now a daemon is running in your flowz, try typing .help in the flow!

```

DESCRIPTION
===========

after setting the appropriate api tokens and config you'll have a robot
running in your flow that does all sorts of irritating stuff.  to find out
what he does just type _.help_

![](http://cl.ly/VUDV/Screen%20Shot%202014-05-12%20at%2012.49.06%20PM.png)

there are two sets of built-in commands, system commands





SETUP
  1) get going
    ./bin/fbomb setup

  2) try out some commands
    ./bin/fbomb .help
    ./bin/fbomb .chucknorris
    ./bin/fbomb .fukung canada

  3) devastate your flowdock flow
    ./bin/fbomb run

  4) devastate your flowdock flow (daemon)
    ./bin/fbomb start

CUSTOMIZE
  see lib/fbomb/commands/*
