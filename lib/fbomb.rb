# built-ins
#
  require 'thread'
  require "uri"
  require 'net/http'
  require 'net/https'
  require 'open-uri'
  require 'fileutils'
  require 'tmpdir'
  require 'yaml'
  require 'rbconfig'

# libs
#
  module FBomb
    Version = '2.1.0' unless defined?(Version)

    def version
      FBomb::Version
    end

    def dependencies
      {
        'flowdock'        =>  [ 'flowdock'        , '>= 0.4.0'   ]  , 
        'eventmachine'    =>  [ 'eventmachine'    , '>= 1.0.3'   ]  , 
        'em-http'         =>  [ 'em-http-request' , '>= 1.1.2'   ]  , 
        'json'            =>  [ 'json'            , '>= 1.8.1'   ]  , 
        'coerce'          =>  [ 'coerce'          , '>= 0.0.6'   ]  , 
        'fukung'          =>  [ 'fukung'          , '>= 1.1.0'   ]  , 
        'main'            =>  [ 'main'            , '>= 4.7.6'   ]  , 
        'nokogiri'        =>  [ 'nokogiri'        , '>= 1.5.0'   ]  , 
        'google-search'   =>  [ 'google-search'   , '>= 1.0.2'   ]  , 
        'unidecode'       =>  [ 'unidecode'       , '>= 1.0.0'   ]  , 
        'systemu'         =>  [ 'systemu'         , '>= 2.3.0'   ]  , 
        'pry'             =>  [ 'pry'             , '>= 0.9.6.2' ]  , 
        'mechanize'       =>  [ 'mechanize'       , '>= 2.7.3'   ]  , 
        'mime/types'      =>  [ 'mime-types'      , '>= 1.16'    ] 
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

    def messages
      @messages ||= Array.new
    end

    def leader
      '.'
    end

    def uuid
      UUID.create.to_s
    end

    attr_accessor :message
    attr_accessor :debug

    extend(FBomb)
  end

## isolate gems
#
  require 'rubygems'

  libdir = File.expand_path(File.join('~', '.fbomb', 'isolate'))
  options = {:file => false, :path => libdir}

  deps = true
  ::FBomb.dependencies.each do |lib, dependency|
    unless Gem.try_activate(dependency.first)
      deps = false
      lib, version = dependency 
      command = "gem install #{ lib.inspect } --version #{ version.inspect }"
      #STDERR.puts(command)
    end
  end

  ::FBomb.dependencies.each do |lib, dependency|
    begin
      gem(*dependency)
    rescue Gem::LoadError
      raise
      lib, version = dependency 
      command = "gem install #{ lib.inspect } --version #{ version.inspect }"
      system(command)
      retry
    end
  end

## load gems
#
  ::FBomb.dependencies.each do |lib, dependency|
    require(lib)
  end

## load fbomb
#
  FBomb.load %w[
    util.rb
    flowdock.rb
    command.rb
    uuid.rb
  ]

##
#
  if Coerce.boolean(ENV['FBOMB_DEBUG'])
    FBomb.debug = true
  end

## openssl - STFU!
#
  verbose = $VERBOSE
  begin
    require 'openssl'
    $VERBOSE = nil
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  rescue Object => e
    :STFU
  ensure
    $VERBOSE = verbose
  end

  class Net::HTTP
    require 'net/https'

    module STFU
      def warn(msg)
        #Kernel.warn(msg) unless msg == "warning: peer certificate won't be verified in this SSL session"
      end

      def use_ssl=(flag)
        super
      ensure
        @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    include(STFU)
  end

## global DSL hook
#
  def FBomb(*args, &block)
    FBomb::Command::DSL.evaluate(*args, &block)
  end

##
#
  Fbomb=FBomb
