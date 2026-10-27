class ThreadBarrier
  def initialize(parties)
    @parties = parties
    @arrived = 0
    @mutex = Mutex.new
    @condition = ConditionVariable.new
  end

  def arrive
    @mutex.synchronize do
      @arrived += 1
      if @arrived >= @parties
        @condition.broadcast
      else
        @condition.wait(@mutex)
      end
    end
  end
end
