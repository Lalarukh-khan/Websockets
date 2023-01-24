import websockets
import asyncio

PORT = 4001

print("Serve Listening on Port" + str(PORT))

async def echo(websocket, path):
	print("A client just connected")
	try:
		async for message in websocket:
			print("Recieved Message from Client-> " + message)
			await websocket.send("Pong: " + message)
	except websockets.exceptions.ConnectionClosed as e:
		print("Client just disconnected")
		print(e)

start_server = websockets.serve(echo, "localhost", PORT)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()