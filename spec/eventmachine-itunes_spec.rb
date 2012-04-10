require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
require 'spec_helper'
require 'appscript'

class Watcher < EM::ITunesWatch
  attr_accessor :value, :user_info

  def on_play(user_info)
    @user_info = user_info
    @value = user_info['Player State']
  end
end

describe EventMachine::ITunesWatch do
  before do
    @itunes = Appscript.app('iTunes')
    @itunes.run
    @itunes.stop
  end

  it 'should watch playing with class' do
    watcher = nil

    EM.run {
      watcher = EM.watch_itunes(Watcher)

      @itunes.playlists["Music"].tracks[1].play

      EM::add_timer(1) {
        @itunes.stop
        EM.stop
        watcher.stop
      }
    }

    watcher.value.should_not be_nil
    watcher.user_info['Total Time'].should be_kind_of(Fixnum)
  end

  it 'should watch playing with block' do
    result = nil
    watcher = nil

    EM.run {
      watcher = EM.watch_itunes {|c|
        (class << c; self; end).send(:define_method, :on_play) {|info|
          result = info
        }
      }

      @itunes.playlists["Music"].tracks[1].play

      EM::add_timer(1) {
        @itunes.stop
        EM.stop
        watcher.stop
      }
    }

    result.should_not be_nil
    result['Total Time'].should be_kind_of(Fixnum)
  end
end
