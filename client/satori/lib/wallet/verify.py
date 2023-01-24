# by elixir server in commandline utility

from ravencoin.signmessage import RavencoinMessage, VerifyMessage

def generateAddress(publicKey: str):
    ''' returns address from pubkey '''
    from ravencoin.wallet import P2PKHRavencoinAddress
    from ravencoin.core.key import CPubKey
    return str(
        P2PKHRavencoinAddress.from_pubkey(
            CPubKey(
                bytearray.fromhex(
                    publicKey))))

def verify(message:'str|RavencoinMessage', signature:'bytes|str', publicKey:str=None, address:str=None):
    ''' returns bool success '''
    return VerifyMessage(
        address or generateAddress(publicKey),
        RavencoinMessage(message) if isinstance(message, str) else message,
        signature if isinstance(signature, bytes) else signature.encode())
