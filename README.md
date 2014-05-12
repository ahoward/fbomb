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

https://github.com/ahoward/fbomb/blob/master/lib/fbomb/commands/system.rb

and a bunch of canned ones, most of which actually work ;-)

https://github.com/ahoward/fbomb/blob/master/lib/fbomb/commands/builtin.rb

the dsl for adding commands is super, super simple, you just

```ruby

  command(:my_command_name) do
    call do |*args|

      speak 'stuff'

      paste 'stuff'

    end
  end

```

commands can be loaded from a file by putting something like this in your
config

```yaml

commands:

  - system
  - builtin
  - ~/.fbomb/commands.rb

```

the interpolation of these paths is the only sane one

- realtive to the libdir of the fbomb gem if bare (not starting with ~ or ./ or /)
- otherwise an expanded path in the fs
- otherwise a url (yep, it evaluates code from a url - sweet huh?)

in the config above you'll notice the '~/.fbomb' path.  by default fbomb keeps
all it's state in '~/.fbomb' including it's logs, pid files, config, etc.
this is therefore a great place to keep commands on your server.  if you gem
install fbomb it's the dot directory, and nothing more, you'd probably want in
your repo.

in dojo4's we have command to list our people and txt message them.  here is a
litle example of that custom command(s)

https://gist.github.com/ahoward/d31fc57067a15c0387bf

the fbomb tool can be installed with

```bash

~> gem install fbomb

```

and the cli is super well behaved, like all main.rb scripts



TIPS
====

```bash

# run in debug mode to emulate getting command from the flow and sending the
back (stdin/stdout) based controls

~> FBOMB_DEBUG=42 fbomb run

```

```bash

# start an iteractive shell in a live flow! 

~> fbomb shell

```

```cron

# use cron to drop shit in your flow 

* 12 * * * * fbomb speak 'time for stand-up bitches!' --tag stand-up

```


DOCS
====
RFTC  @
- https://github.com/ahoward/fbomb/tree/master/lib
- https://github.com/ahoward/fbomb/blob/master/bin/fbomb 
