# import websocket
# import asyncio
# import ssl
# from websocket import create_connection

# # ws = websocket.WebSocket()

# headers = {'Authorization': 'Basic YWRtaW46YWRtaW4='}
# base_endpoint = create_connection('ws://localhost:4000/socket/websocket', sslopt={"cert_reqs": ssl.CERT_NONE, 
#             "check_hostname": False, 
#             "ssl_version": ssl.PROTOCOL_TLSv1
#     })

# async def hello(uri):
#     async with create_connection(uri) as ws:
#         await ws.send("Hello Server")
#         while True:
#             msg = await ws.recv()
#             print(msg)
#         assert(ws.connected == True)
#         print('SUCCESSFULLY CONNECTED')
        
#         data = await websocket.recv()
#         print(data)

# asyncio.run(hello(base_endpoint))




# Importing the relevant libraries
import websockets
import asyncio

# The main function that will handle connection and communication 
# with the server
async def listen():
    url = "ws://127.0.0.1:4001"
    # Connect to the server
    async with websockets.connect(url) as ws:
        # Send a greeting message
        await ws.send("Hello Server!")
        # Stay alive forever, listening to incoming msgs
        while True:
            msg = await ws.recv()
            print(msg)

# Start the connection
asyncio.get_event_loop().run_until_complete(listen())