import phxsocket
import ssl

# Create socket client
headers = {'Authorization': 'Basic YWRtaW46YWRtaW4='}
socket = phxsocket.Client("ws://localhost:4000/socket/websocket", {"data": "STRING 1"})
# socket = phxsocket.Client("ws://localhost:4000/socket/websocket", {"data": "STRING 1"})

# Connect and join a channel
if socket.connect(): # blocking, raises exception on failure
  channel = socket.channel("room:lobby")
  print("SUCCESSFULLY CONNECTED")
  resp = channel.join() # also blocking, raises exception on failure

# Alternatively
def connect_to_channel(socket, origin = 'com.universal-devices.websockets.isy', subprotocols = ['ISYSUB'],extra_headers=headers):
  channel = socket.channel("room:lobby")
  resp = channel.join()
  
socket.on_open = connect_to_channel
# connection = socket.connect(blocking=True)
# print(connection)
# connection.wait()


# Reconnect on disconnection
socket.on_close = lambda socket: socket.connect()

#Subscribe to events
def do_something(payload):
  thing = payload["thing"]

channel.on("eventname", do_something)

message = ""

#Push data to a channel
# channel.push("message:add", {"message": "HELLO WORLD"})
# receive("ok" => setMessage("Hello World"))

# # Push data and wait for a response
# message = channel.push("message:add", {"message": "HELLO WORLD"})
# response = message.wait_for_response()
# print(response)
# import time
# time.sleep(3600)

# response = message.wait_for_response() # blocking

#Push data and react to the response with a callback
def respond(payload):
  print(payload)

channel.push("message:add", {"message": "HELLO WORLD"}, respond)

# Leave a channel
channel.leave()

import time
time.sleep(3600)

# Disconnect
socket.close()