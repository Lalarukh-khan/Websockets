import socket 
import json
import random
from satori import config
from satori.lib.apis.blockchain import ElectrumX
from satori.lib.wallet.structs import TransactionStruct 

class Ravencoin():
    def __init__(self, address, scripthash):
        self.address = address
        self.scripthash = scripthash
        self.conn = None
        self.balance = None
        self.stats = None
        self.banner = None
        self.rvn = None
        self.transactionHistory = None
        self.transactions = None
        
    def connect(self):
        hostPorts = config.electrumxServers()
        if len(hostPorts) == 0:
            return 
        hostPort = random.choice(hostPorts)
        return ElectrumX(
            host=hostPort.split(':')[0],
            port=int(hostPort.split(':')[1]),
            ssl=True,
            timeout=5)
        
    def get(self, allWalletInfo=False):
        '''
        this needs to be moved out into an interface with the blockchain,
        but we don't have that module yet. so it's all basically hardcoded for now.
        
        get_asset_balance
        {'confirmed': {'SATORI!': 100000000, 'SATORI': 100000000000000}, 'unconfirmed': {}}
        get_meta
        {'sats_in_circulation': 100000000000000, 'divisions': 0, 'reissuable': True, 'has_ipfs': False, 'source': {'tx_hash': 'a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3', 'tx_pos': 3, 'height': 2292586}}
        '''
        def interpret(x:str):
            return json.loads(x.decode('utf-8')).get('result', None)

        #def invertDivisibility(divisibility:int):
        #    return (16 + 1) % (divisibility + 8 + 1);
        #
        #def removeStringedZeros():
        #    
        #    return self.balance[0:len(self.balance) - invertDivisibility(int(self.stats.get('divisions', 8)))] 
        #
        #def removeZeros():
        #    return self.balance / 
        #
        #def splitBalanceOnDivisibility():
        #    return self.balance / int('1' + ('0'*invertDivisibility(int(self.stats.get('divisions', 8)))) )

        i = 0
        while self.conn == None and i < 5:
            i += 1
            self.conn = self.connect()
            name = f'Satori Node {self.address}'
            assetApiVersion = '1.10'
            try:
                handshake = interpret(self.conn.send(
                    'server.version', 
                    name, 
                    assetApiVersion))   
                break
            except socket.timeout:
                self.conn = None
                continue
        if self.conn == None:
            return 
            #raise Exception('unable to connect to electrumx servers')
        if (
            handshake[0].startswith('ElectrumX Ravencoin')
            and handshake[1] == assetApiVersion
        ):
            self.banner = interpret(self.conn.send('server.banner'))
            self.balance = interpret(self.conn.send(
                'blockchain.scripthash.get_asset_balance', 
                self.scripthash)
            ).get('confirmed', {}).get('SATORI', 'unknown')
            self.stats = interpret(self.conn.send(
                'blockchain.asset.get_meta', 
                'SATORI'))
            
            if allWalletInfo:
                x = interpret(self.conn.send(
                    'blockchain.scripthash.get_balance', 
                    self.scripthash))
                self.rvn = x.get('confirmed', 0) + x.get('unconfirmed', 0)
                #>>> b.send("blockchain.scripthash.get_balance", script_hash('REsQeZT8KD8mFfcD4ZQQWis4Ju9eYjgxtT'))
                #b'{"jsonrpc":"2.0","result":{"confirmed":18193623332178,"unconfirmed":0},"id":1656046285682}\n'
                self.transactionHistory = interpret(self.conn.send(
                    'blockchain.scripthash.get_history', 
                    self.scripthash)) 
                #b.send("blockchain.scripthash.get_history", script_hash('REsQeZT8KD8mFfcD4ZQQWis4Ju9eYjgxtT'))
                #b'{"jsonrpc":"2.0","result":[{"tx_hash":"a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3","height":2292586}],"id":1656046324946}\n'
                self.transactions = []
                for tx in self.transactionHistory:
                    raw = interpret(self.conn.send(
                        'blockchain.transaction.get',
                        tx.get('tx_hash', ''), True))
                    txs = []
                    for vin in raw.get('vin', []):
                        txs.append(interpret(self.conn.send(
                            'blockchain.transaction.get',
                            vin.get('txid', ''), True)))
                    self.transactions.append(TransactionStruct(raw=raw, vinVoutsTxs=txs)) 
                    #>>> b.send("blockchain.transaction.get", 'a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3')
                    #b'{"jsonrpc":"2.0","result":"0200000001aece4f378e364682d77ea345581f4880edd0709c2bf524320b223e7c66aaf25b000000006a473044022079b86eae8bf1974be0134387f6db11a49f273660ec2ea0ce98bb5cf31dfb70d702200b1d46a748f2dea4753175f9f695a16dfdbdbdb50400076cd28165795a80b30a012103571524d47ad9240a9674c2085959c60ea62c5d5567b62e0bfd4d40727bba7a8affffffff0400743ba40b0000001976a914f62e63b933953a680f3c3a63324948293ba47d1688ac52b574088c1000001976a9143d5143a9336eaf44990a0b4249fcb823d70de52c88ac00000000000000002876a9143d5143a9336eaf44990a0b4249fcb823d70de52c88acc00c72766e6f075341544f5249217500000000000000003276a9143d5143a9336eaf44990a0b4249fcb823d70de52c88acc01672766e71065341544f524900407a10f35a00000001007500000000","id":1656046440320}\n'
                    #print(bytes.fromhex('68656c6c6f').decode('utf-8'))

                
                
# transaction history
# private key
# qr address
# address
# send
# electrum banner
# about Satori Token - asset on rvn, will be fully convertable to it's own blockchain when Satori is fully decentralized

#>>> b.send("blockchain.scripthash.get_balance", script_hash('REsQeZT8KD8mFfcD4ZQQWis4Ju9eYjgxtT'))
#b'{"jsonrpc":"2.0","result":{"confirmed":18193623332178,"unconfirmed":0},"id":1656046285682}\n'

#b.send("blockchain.scripthash.get_history", script_hash('REsQeZT8KD8mFfcD4ZQQWis4Ju9eYjgxtT'))
#b'{"jsonrpc":"2.0","result":[{"tx_hash":"a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3","height":2292586}],"id":1656046324946}\n'

#>>> b.send("blockchain.transaction.get", 'a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3')
#b'{"jsonrpc":"2.0","result":"0200000001aece4f378e364682d77ea345581f4880edd0709c2bf524320b223e7c66aaf25b000000006a473044022079b86eae8bf1974be0134387f6db11a49f273660ec2ea0ce98bb5cf31dfb70d702200b1d46a748f2dea4753175f9f695a16dfdbdbdb50400076cd28165795a80b30a012103571524d47ad9240a9674c2085959c60ea62c5d5567b62e0bfd4d40727bba7a8affffffff0400743ba40b0000001976a914f62e63b933953a680f3c3a63324948293ba47d1688ac52b574088c1000001976a9143d5143a9336eaf44990a0b4249fcb823d70de52c88ac00000000000000002876a9143d5143a9336eaf44990a0b4249fcb823d70de52c88acc00c72766e6f075341544f5249217500000000000000003276a9143d5143a9336eaf44990a0b4249fcb823d70de52c88acc01672766e71065341544f524900407a10f35a00000001007500000000","id":1656046440320}\n'
#print(bytes.fromhex('68656c6c6f').decode('utf-8'))

#>>> b.send("blockchain.transaction.get", 'a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3', True)
#RAW
#b'{"jsonrpc":"2.0","result":{"txid":"a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3","hash":"a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3","version":2,"size":333,"vsize":333,"locktime":0,"vin":[{"txid":"5bf2aa667c3e220b3224f52b9c70d0ed80481f5845a37ed78246368e374fceae","vout":0,"scriptSig":{"asm":"3044022079b86eae8bf1974be0134387f6db11a49f273660ec2ea0ce98bb5cf31dfb70d702200b1d46a748f2dea4753175f9f695a16dfdbdbdb50400076cd28165795a80b30a[ALL] 03571524d47ad9240a9674c2085959c60ea62c5d5567b62e0bfd4d40727bba7a8a","hex":"473044022079b86eae8bf1974be0134387f6db11a49f273660ec2ea0ce98bb5cf31dfb70d702200b1d46a748f2dea4753175f9f695a16dfdbdbdb50400076cd28165795a80b30a012103571524d47ad9240a9674c2085959c60ea62c5d5567b62e0bfd4d40727bba7a8a"},"sequence":4294967295}],"vout":[{"value":500.0,"n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 f62e63b933953a680f3c3a63324948293ba47d16 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a914f62e63b933953a680f3c3a63324948293ba47d1688ac","reqSigs":1,"type":"pubkeyhash",'
#b'{"jsonrpc":"2.0","result":{"txid":"a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3","hash":"a015f44b866565c832022cab0dec94ce0b8e568dbe7c88dce179f9616f7db7e3","version":2,"size":333,"vsize":333,"locktime":0,"vin":[{"txid":"5bf2aa667c3e220b3224f52b9c70d0ed80481f5845a37ed78246368e374fceae","vout":0,"scriptSig":{"asm":"3044022079b86eae8bf1974be0134387f6db11a49f273660ec2ea0ce98bb5cf31dfb70d702200b1d46a748f2dea4753175f9f695a16dfdbdbdb50400076cd28165795a80b30a[ALL] 03571524d47ad9240a9674c2085959c60ea62c5d5567b62e0bfd4d40727bba7a8a","hex":"473044022079b86eae8bf1974be0134387f6db11a49f273660ec2ea0ce98bb5cf31dfb70d702200b1d46a748f2dea4753175f9f695a16dfdbdbdb50400076cd28165795a80b30a012103571524d47ad9240a9674c2085959c60ea62c5d5567b62e0bfd4d40727bba7a8a"},"sequence":4294967295}],"vout":[{"value":500.0,"n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 f62e63b933953a680f3c3a63324948293ba47d16 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a914f62e63b933953a680f3c3a63324948293ba47d1688ac","reqSigs":1,"type":"pubkeyhash",'
#>>>