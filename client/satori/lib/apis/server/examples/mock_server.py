import asyncio
import websockets

# create handler for each connection
async def handle_connections(websocket, path):
    while True: 
        data = await websocket.recv()
        print(f"Data recieved as: {data}")
        print(f"echoing...")
        reply = f"Data recieved as: {data}"
        await websocket.send(reply)
    
async def handle_endpoint(websocket, path):
        data = await websocket.recv()
        print(f"Data recieved as: {data}")
        print(f"echoing...")
        reply = f"Data recieved as: {data}"
        await websocket.send(reply)
 
#start_server = websockets.serve(handle_endpoint, "localhost", 8000)
start_server = websockets.serve(handle_connections, "localhost", 8000)
 
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()