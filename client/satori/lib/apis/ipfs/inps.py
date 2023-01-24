'''
ipns methods
see https://docs.ipfs.tech/concepts/ipns/#example-ipns-setup-with-cli
'''
import os
#import subprocess

def associateKeyWithStream(key, streamName):
    '''saves locally tells server'''
    generateKey(streamName)
    tellServer(key, streamName)

def generateKey(streamName):
    return os.popen(f'ipfs key gen {streamName}').read()
    #return subprocess.Popen(
    #    f'ipfs key gen {streamName}',
    #    shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,)

def tellServer(key, streamName):
    '''endpoint'''

def get(key):
    return os.popen(f'curl https://gateway.ipfs.io/ipns/{key}').read()

def publish(ipfs, streamName):
    return os.popen(f'ipfs name publish --key={streamName} /ipfs/{ipfs}').read()

def getMostPopular(ipnsKeys):
    '''
    do we want to get most popluar (a heuristic)
    or do we want to see which one has the longest data?
    more true, but more work. do this first.'''
    x = {key:
        f'ipfs name resolve --key={key}'
        for key in ipnsKeys}
    return max(set(x.values), key=x.values.count)

def randomlyChooseKeyFromMostPopular(ipnsKeys):
    '''get a key'''
    import random
    x = getMostPopular(ipnsKeys)
    candidates = {key: value for key, value in ipnsKeys.items() if value == x}
    return random.choice(list(candidates.keys()))

