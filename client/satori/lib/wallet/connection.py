# a satori node uses the wallet public key to connect to the server via signing a message.
# the message is the date in UTC now that way the server doesn't have to give the client
# a message to sign. so the client just sends up the public key and the sig. done.
import json
import datetime as dt

def payloadForServer(wallet, asDict=False):
    ''' see wallet_auth in server '''
    dateMessage = getFullDateMessage()
    dictionary = {
        'message': dateMessage,
        'public_key': wallet.publicKey,
        'address': wallet.address,
        'signature': wallet.sign(dateMessage).decode()}
    if asDict:
        return dictionary
    return json.dumps(dictionary)
    
def getFullDateMessage():
    ''' returns a string of today's date in UTC like this: "2022-08-01 17:28:44.748691" '''
    return str(dt.datetime.utcnow())