require 'sinatra'
require 'sinatra-websocket'
require 'haml'
require 'json'
require './motordriver.rb'

set server: 'thin', websockets: [], video_connections: []

$arduino = Arduino.new
$motordriver = MotorDriver.new(
  $arduino,
  { :left    => Motor.new(2, $arduino, { :forward => Motor::BACKWARD, :backward => Motor::FORWARD }),
    :right   => Motor.new(1, $arduino, { :forward => Motor::BACKWARD, :backward => Motor::FORWARD }),
    :gripper => Motor.new(3, $arduino, { :forward => Motor::FORWARD, :backward => Motor::BACKWARD }),
    :rotator => Motor.new(4, $arduino, { :forward => Motor::FORWARD, :backward => Motor::BACKWARD }),
  }
)

def handle_commands(params={})
  params = (JSON.parse(params) unless params.class == Hash rescue {})
  Thread.new{`espeak '#{params['speak'].tr('\'','')}' 2> /dev/null`} if params['speak']
  $motordriver.left(*params['left'])       if params['left']
  $motordriver.right(*params['right'])     if params['right']
  $motordriver.gripper(*params['gripper']) if params['gripper']
  $motordriver.rotator(*params['rotator']) if params['rotator']
rescue
  p $!
end

get '/' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        ws.send("CONNECTED #{Time.now}")
        settings.websockets << ws
      end
      ws.onmessage do |msg|
        handle_commands(msg)
        EM.next_tick { settings.websockets.each{|s| s.send(msg) } }
      end
      ws.onclose do
        settings.websockets.delete(ws)
      end
    end
  else
    haml :index
  end
end

get '/mjpgstream' do
  fps = (params['fps']||10).to_i
  ms = (1000 / fps.to_f).to_i
  headers('Cache-Control' => 'no-cache, private', 'Pragma' => 'no-cache',
          'Content-type'  => 'multipart/x-mixed-replace; boundary={{{NEXT}}}')
  stream(:keep_open) do |out|
    if !$mjpg_stream || $mjpg_stream.closed?
      puts "starting mjpg stream with #{fps} fps. #{ms} ms between frames."
      $mjpg_stream = IO.popen "./uvccapture/uvccapture -oSTDOUT -m -t#{ms} -DMJPG -x640 -y480 2> /dev/null"
    end
    settings.video_connections << out
    out.callback {
      settings.video_connections.delete(out)
      if settings.video_connections.empty?
	      puts 'closing mjpg stream'
        $mjpg_stream.close
      end
    }
    buffer = ''
    buffer << $mjpg_stream.read(1) while !buffer.end_with?("{{{NEXT}}}\n")
    while !$mjpg_stream.closed?
      begin
        out << $mjpg_stream.read(512)
      rescue
      end
    end
  end
end

########## VIEWS
__END__

@@ layout
!!! 5
%html{:lang => 'en'}
  %head
    %meta{:charset => 'utf-8'}
    %link{:rel=>'shortcut icon', :type=>'image/gif', :href=>'favicon.gif'}
    %title RuBot
  %body{:style=>'background-color:black; text-align:center;'}
    = yield(:layout)
    %script{:src => 'jquery.js'}
    %script{:src => 'app.js?'}

@@ index
%div
  %img{:src=>'/mjpgstream'}
  %p{:style=>'color:#555'}
    Help:
    Use arrow keys to drive,
    q/w to open/close gripper
    a/s to turn gripper left/right 
    hold shift for slow-mode,
    space to speak

