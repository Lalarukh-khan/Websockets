'''
uses the cli to add a file to ipfs

on program start:
# in a separate thread
ipfs.start

on new observation, or publication:
cid = ipfs.addAndPinDirectoryByCLI(abspath, name)
# send cid to server

on closing a subscription:
cid = ipfs.addAndPinDirectoryByCLI(abspath, name)
ipfs.removeDirectoryByCLI(name)
# remvoe cid from server
'''

import subprocess
        
def addDirectoryByCLI(abspath: str):
    '''all attempts to use the api for this ended in disaster.'''
    cmd = f'ipfs add -r -Q {abspath}'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True).stdout.decode('utf-8').strip()

def pinDirectoryByCLI(cid: str, name: str):
    cmd = f'ipfs files cp /ipfs/{cid} /{name}'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True)

def pinAndAddDirectoryByCLI(abspath: str, name: str):
    cmd = f'ipfs files cp /ipfs/$(ipfs add -r -Q {abspath}) /{name}'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True)

def init():
    cmd = f'ipfs init'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True)

def daemon():
    ''' run this in a separate thread '''
    cmd = f'ipfs daemon'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True)
        
## interface ##################################################################

def start():
    ''' run this in a separate thread '''
    init()
    daemon()

def addAndPinDirectoryByCLI(abspath: str, name: str):
    cid = addDirectoryByCLI(abspath)
    pinDirectoryByCLI(cid, name)
    return cid

def seeMFSByCLI():
    cmd = f'ipfs files ls'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True)

def removeDirectoryByCLI(name: str):
    cmd = f'ipfs files rm -r /{name}'
    return subprocess.run(["powershell", "-Command", cmd], capture_output=True)