$(document).ready(function(){
  // Websocket connection
  var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
  ws.onopen      = function()  { console.log('websocket opened'); };
  ws.onclose     = function()  { console.log('websocket closed'); };
  ws.onmessage   = function(m) { console.log('websocket message: ' +  m.data); };
  var ws_send    = function(d) { ws.send(JSON.stringify(d)); };
  //wss = ws_send // for debugging
  var ws_ping = setInterval(function(){ws_send({'ping':Date.now()});}, 5000);

  var key_states = {
    'shift' : false,
    37 : false, //left
    38 : false, //up
    39 : false, //right
    40 : false, //down
    81 : false, //q
    87 : false, //w
    65 : false, //a
    83 : false, //s
  }

  var motor_states = function(){
    var cmd = {'gripper':'stop', 'rotator':'stop', 'left':'stop', 'right':'stop'};
    speed = key_states['shift'] ? 100 : 255;
    if     (key_states[81]){ cmd['gripper'] = ['forward', speed];  }
    else if(key_states[87]){ cmd['gripper'] = ['backward', speed]; }
    if     (key_states[65]){ cmd['rotator'] = ['forward', speed]; }
    else if(key_states[83]){ cmd['rotator'] = ['backward', speed]; }
    if     (key_states[38] && key_states[37]){ cmd['left'] = 'stop';              cmd['right'] = ['forward', speed];  }
    else if(key_states[38] && key_states[39]){ cmd['left'] = ['forward', speed];  cmd['right'] = 'stop';              }
    else if(key_states[40] && key_states[37]){ cmd['left'] = 'stop';              cmd['right'] = ['backward', speed]; }
    else if(key_states[40] && key_states[39]){ cmd['left'] = ['backward', speed]; cmd['right'] = 'stop';              }
    else if(key_states[38])                  { cmd['left'] = ['forward', speed];  cmd['right'] = ['forward', speed];  }
    else if(key_states[40])                  { cmd['left'] = ['backward', speed]; cmd['right'] = ['backward', speed]; }
    else if(key_states[37])                  { cmd['left'] = ['backward', speed]; cmd['right'] = ['forward', speed];  }
    else if(key_states[39])                  { cmd['left'] = ['forward', speed];  cmd['right'] = ['backward', speed]; }
    return cmd;
  }

  $(document).on('keydown', function(e){
    var k = e.keyCode
    key_states['shift'] = e.shiftKey;
    if(key_states[k] === false){
      key_states[k] = true; 
      ws_send(motor_states());
    }else if(key_states[k] == undefined){
      console.log('unknown key: '+k);
      console.log(e);
    }
  });

$(document).on('keyup', function(e){
    var k = e.keyCode
    if(k == 32){
      var txt = prompt('What to say?');
      if(txt != '') ws_send({'speak':txt});
    }else if(key_states[k] === true){
      key_states[k] = false; 
      ws_send(motor_states());
    }
  });

});
