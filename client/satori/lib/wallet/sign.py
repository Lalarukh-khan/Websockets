from ravencoin.wallet import CRavencoinSecret
from ravencoin.signmessage import RavencoinMessage, SignMessage

def signMessage(key:CRavencoinSecret, message:'str|RavencoinMessage'):
    ''' returns binary signature '''
    return SignMessage(
        key,
        RavencoinMessage(message) if isinstance(message, str) else message)