require 'serialport'

class Arduino

  def initialize(opts={})
    device   = opts[:device]   || '/dev/ttyUSB0' #make sure to set correct permissions via chmod!
    puts "WARNING: unsufficient permissions for #{device}" unless File.readable?(device) && File.writable?(device)
    baudrate = opts[:baudrate] || 9600
    databits = opts[:databits] || 8
    stopbits = opts[:stopbits] || 1
    parity   = opts[:parity]   || SerialPort::NONE
    @sp      = SerialPort.new(device, baudrate, databits, stopbits, parity)
  end

  def write(*bytes)
    bytes.each{|b| @sp.putc b.to_i}
  end

  def close
    @sp.close
  end
end
