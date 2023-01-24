# # Importing the relevant libraries
# import websockets
# import asyncio

# # The main function that will handle connection and communication 
# # with the server
# async def listen():
#     url = "ws://127.0.0.1:4000/socket/websocket"
#     # Connect to the server
#     async with websockets.connect(url) as ws:
#         # Send a greeting message
#         await ws.send("Hello Server!")
#         # Stay alive forever, listening to incoming msgs
#         while True:
#             msg = await ws.recv()
#             print(msg)

# # Start the connection
# asyncio.get_event_loop().run_until_complete(listen())


def tests():
    import websocket
    import ssl
    from websocket import create_connection
    
    ws = websocket.WebSocket()

    ws = create_connection('ws://localhost:4000/socket/websocket',
    #  ws.connect('ws://localhost:4000',
    sslopt={"cert_reqs": ssl.CERT_NONE, 
            "check_hostname": False, 
            "ssl_version": ssl.PROTOCOL_TLSv1
    }) # server url
    assert(ws.connected == True)
    print('successfully connected')
    
    # ws.send("HELLO WORLD")
    response = ws.recv() 
    print(response)
    # assert(response == 'hello') # server should echo back
    # print('sent and received')
    
    import time
    time.sleep(1)
    # assert(ws.connected == True)
    print('still connected')
    
    ws.close() # server should detect we closed the connection
    assert(ws.connected == False)
    print('successfully disconnected')
 
tests()

# install latest python3 (>3.7)
# pip3 install websocket-client
# python3 clientws.py
