require 'eventmachine-distributed-notification'

module EventMachine
  class ITunesWatch < DistributedNotificationWatch
    def notify(name, user_info)
      states = {
        'Playing' => :on_play,
        'Paused'  => :on_pause,
        'Stopped' => :on_stop
      }

      __send__(states[user_info['Player State']], user_info)
    end

    def on_play(user_info); end
    def on_pause(user_info); end
    def on_stop(user_info); end
  end

  def self.watch_itunes(handler = nil, *args, &block)
    args = ['com.apple.iTunes.playerInfo', *args]
    klass = klass_from_handler(EventMachine::ITunesWatch, handler, *args);
    c = klass.new(*args, &block)
    block_given? and yield c
    c.start
    c
  end
end
