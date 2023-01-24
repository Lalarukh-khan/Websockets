import os
import json
from satori import config
from satori.lib.apis.ravencoin import Ravencoin
from satori.lib.apis.disk import WalletApi
from satori.lib.wallet import sign, verify as satori_verify
import ravencoin.base58
from ravencoin.wallet import P2PKHRavencoinAddress, CRavencoinSecret
import mnemonic
from satori.lib.wallet import connection

class Wallet():
    
    def __init__(self, temporary=False):
        self._entropy = None
        self._privateKeyObj = None
        self._addressObj = None
        self.publicKey = None
        self.privateKey = None
        self.words = None
        self.address = None
        self.scripthash = None
        self.stats = None
        self.banner = None
        self.rvn = None
        self.balance = None
        self.transactionHistory = None
        self.transactions = [] # TransactionStruct
        self.temporary = temporary
    
    def __repr__(self):
        return f'''Wallet(
    publicKey: {self.publicKey}
    privateKey: {self.privateKey}
    words: {self.words}
    address: {self.address}
    scripthash: {self.scripthash}
    balance: {self.balance}
    stats: {self.stats}
    banner: {self.banner})'''

    def authPayload(self, asDict=False): 
        return connection.payloadForServer(self, asDict=asDict)
    
    def __call__(self):
        self.init()
        return self
    
    def init(self):
        ''' try to load, else generate and save '''
        if self.load():
            self.regenerate()
        else:
            self.generate()
            self.save()
        if not self.temporary:
            self.get()

    def load(self):
        wallet = WalletApi.load(
            walletPath=config.walletPath('wallet.yaml'))
        if wallet == False:
            return False
        self._entropy = wallet.get('entropy')
        self.publicKey = wallet.get('publicKey')
        self.privateKey = wallet.get('privateKey')
        self.words = wallet.get('words')
        self.address = wallet.get('address')
        self.scripthash = wallet.get('scripthash')
        if self._entropy is None:
            return False
        return True

    def save(self):
        WalletApi.save(
            wallet={
                'entropy': self._entropy,
                'publicKey': self.publicKey,
                'privateKey': self.privateKey,
                'words': self.words,
                'address': self.address,
                'scripthash': self.scripthash,
                },
            walletPath=config.walletPath('wallet.yaml'))

    def regenerate(self):
        self.generate()
        
    def generate(self):
        self._entropy = self._entropy or self._generateEntropy()
        self._privateKeyObj = self._generatePrivateKey()
        self._addressObj = self._generateAddress()
        self.words = self.words or self._generateWords()
        self.privateKey = self.privateKey or str(self._privateKeyObj)
        self.publicKey = self.publicKey or self._privateKeyObj.pub.hex()
        self.address = self.address or str(self._addressObj)
        self.scripthash = self.scripthash or self._generateScripthash()


    def _generateScripthash(self):
        # possible shortcut:
        #self.scripthash = '76a914' + [s for s in self._addressObj.to_scriptPubKey().raw_iter()][2][1].hex() + '88ac'
        from base58 import b58decode_check
        from binascii import hexlify
        from hashlib import sha256
        import codecs
        OP_DUP = b'76'
        OP_HASH160 = b'a9'
        BYTES_TO_PUSH = b'14'
        OP_EQUALVERIFY = b'88'
        OP_CHECKSIG = b'ac'
        DATA_TO_PUSH = lambda address: hexlify(b58decode_check(address)[1:])
        sig_script_raw = lambda address: b''.join((OP_DUP, OP_HASH160, BYTES_TO_PUSH, DATA_TO_PUSH(address), OP_EQUALVERIFY, OP_CHECKSIG))
        scripthash = lambda address: sha256(codecs.decode(sig_script_raw(address), 'hex_codec')).digest()[::-1].hex()
        return scripthash(self.address);

    def _generateEntropy(self):
        #return m.to_entropy(m.generate())
        return os.urandom(32)

    def _generateWords(self):
        return mnemonic.Mnemonic('english').to_mnemonic(self._entropy)

    def _generatePrivateKey(self):
        ravencoin.SelectParams('mainnet')
        return CRavencoinSecret.from_secret_bytes(self._entropy)

    def _generateAddress(self):
        return P2PKHRavencoinAddress.from_pubkey(self._privateKeyObj.pub)

    def showStats(self):
        ''' returns a string of stats properly formatted '''
        def invertDivisibility(divisibility:int):
            return (16 + 1) % (divisibility + 8 + 1);
        
        divisions = self.stats.get('divisions', 8)
        circulatingSats = self.stats.get('sats_in_circulation', 100000000000000) / int('1' + ('0'*invertDivisibility(int(divisions))))
        headTail = str(circulatingSats).split('.')
        if headTail[1] == '0' or headTail[1] == '00000000':
            circulatingSats = f"{int(headTail[0]):,}"
        else:
            circulatingSats = f"{int(headTail[0]):,}" + '.' + f"{headTail[1][0:4]}" + '.' + f"{headTail[1][4:]}"
        return f'''
    Circulating Supply: {circulatingSats}
    Decimal Points: {divisions}
    Reissuable: {self.stats.get('reissuable', False)}
    Issuing Transactions: {self.stats.get('source', {}).get('tx_hash', 'a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3')}
    '''
        
    def showBalance(self, rvn=False):
        ''' returns a string of balance properly formatted '''
        def invertDivisibility(divisibility:int):
            return (16 + 1) % (divisibility + 8 + 1);
        
        if rvn:
            balance = self.rvn / int('1' + ('0'*8))
        else:
            if self.balance == 'unknown':
                return self.balance
            balance = self.balance / int('1' + ('0'*invertDivisibility(int(self.stats.get('divisions', 8)))))
        headTail = str(balance).split('.')
        if headTail[1] == '0':
            return f"{int(headTail[0]):,}"
        else:
            return f"{int(headTail[0]):,}" + '.' + f"{headTail[1][0:4]}" + '.' + f"{headTail[1][4:]}"
        
    def get(self, allWalletInfo=False):
        ''' gets data from the blockchain, saves to attributes '''
        x = Ravencoin(self.address, self.scripthash)
        x.get(allWalletInfo)
        self.balance = x.balance
        self.stats = x.stats
        self.banner = x.banner
        self.rvn = x.rvn
        self.transactionHistory = x.transactionHistory
        self.transactions = x.transactions
    
    def sign(self, message:str):
        return sign.signMessage(self._privateKeyObj, message)
    
    def verify(self, message:str, sig:bytes):
        return satori_verify(address=self.address, message=message, signature=sig)    
