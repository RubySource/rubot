require './arduino.rb'

class MotorDriver

  def initialize(arduino, motors={})
    @arduino = arduino
    @motors = motors
  end

  def close
    @arduino.close
  end

  def all(*args)
    @motors.values.each{ |e| e.send(args[0].to_sym, *args[1..-1])}
  end

  def method_missing(m, *args)
    if @motors[m]
      puts "Motor #{m} #{args}"
      @motors[m].send(args.shift.to_sym, *args)
    else
      super
    end
  end
end

class Motor
  FORWARD  = 1
  BACKWARD = 2
  BREAK    = 3 #do not use
  RELEASE  = 4

  def initialize(nr, arduino, commands={})
    @nr = constrain(nr, 1, 4)
    @arduino = arduino
    @commands = {:forward=>FORWARD, :backward=>BACKWARD, :stop=>RELEASE}.merge(commands)
  end

  def method_missing(m, *args)
    if @commands[m]
      @arduino.write(@nr, @commands[m], constrain(args.first.to_i || 255, 0, 255))
    else
      @arduino.write(@nr, @commands[:stop], 0)
      super
    end
  end

  private 

  def constrain(val, min, max)
    [min, [max, val].min].max
  end
end
