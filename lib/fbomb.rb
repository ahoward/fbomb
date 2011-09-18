# built-ins
#
  require 'thread'
  require "uri"
  require 'net/http'
  require 'net/https'
  require 'open-uri'

# libs
#
  module FBomb
    Version = '1.0.0' unless defined?(Version)

    def version
      FBomb::Version
    end

    def dependencies
      {
        'tinder'              =>  [ 'tinder'         , '~> 1.7.0'  ]  , 
        'yajl'                =>  [ 'yajl-ruby'      , '~> 0.8.3'  ]  , 
        'fukung'              =>  [ 'fukung'         , '~> 1.1.0'  ]  , 
        'main'                =>  [ 'main'           , '~> 4.7.6'  ] 
      }
    end

    def libdir(*args, &block)
      @libdir ||= File.expand_path(__FILE__).sub(/\.rb$/,'')
      args.empty? ? @libdir : File.join(@libdir, *args)
    ensure
      if block
        begin
          $LOAD_PATH.unshift(@libdir)
          block.call()
        ensure
          $LOAD_PATH.shift()
        end
      end
    end

    def load(*libs)
      libs = libs.join(' ').scan(/[^\s+]+/)
      FBomb.libdir{ libs.each{|lib| Kernel.load(lib) } }
    end

    extend(FBomb)
  end

# gems
#
  begin
    require 'rubygems'
  rescue LoadError
    nil
  end

  if defined?(gem)
    FBomb.dependencies.each do |lib, dependency|
      gem(*dependency)
      require(lib)
    end
  end

  require "yajl/json_gem"     ### this *replaces* any other JSON.parse !
  require "yajl/http_stream"  ### we really do need this

  FBomb.load %w[
    util.rb
    campfire.rb
    command.rb
  ]

## openssl - STFU!
#
  class Net::HTTP
    def warn(msg)
      Kernel.warn(msg) unless msg == "warning: peer certificate won't be verified in this SSL session"
    end
  end

## global DSL hook
#
  def FBomb(*args, &block)
    FBomb::Command::DSL.evaluate(*args, &block)
  end
