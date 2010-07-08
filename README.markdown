# Rose

Rose (say it out loud: rows, rows, rows) is a slick Ruby DSL for reporting:

    Rose.make(:worlds) do
      rows do
        column(:hello => "Hello")
        column(:world)
      end
    end

    class World < Struct.new(:hello, :world)
    end

    Rose(:worlds).bloom([World.new("Say", "what?")]).to_s

    +---------------+
    | Hello | world |
    +---------------+
    | Say   | what? |
    +---------------+

It integrates with ActiveRecord too!

Install the gem:

    gem install rose


*****

# Installation and Usage

All documentation is at [http://hsume2.github.com/rose](http://hsume2.github.com/rose)

# Copyright

Copyright (c) 2010 Henry Hsu. See LICENSE for details.