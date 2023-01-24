class TransactionStruct():
    
    def __init__(self, raw, vinVoutsTxs):
        self.txid = self.getTxid(raw)
        self.height = self.getHeight(raw)
        self.confirmations = self.getConfirmations(raw)
        self.sent = self.getSent(raw)
        self.received = self.getReceived(raw, vinVoutsTxs)
    
    def getTxid(self, raw):
        return raw.get('txid', 'unknown txid')
    
    def getHeight(self, raw):
        return raw.get('height', 'unknown height')
    
    def getConfirmations(self, raw):
        return raw.get('confirmations', 'unknown confirmations')
    
    def getSent(self, raw):
        sent = {}
        for vout in raw.get('vout', []):
            if 'asset' in vout:
                name = vout.get('asset', {}).get('name', 'unknown asset')
                amount = float(vout.get('asset', {}).get('amount', 0))
            else:
                name = 'Ravencoin'
                amount = float(vout.get('value', 0))
            if name in sent:
                sent[name] = sent[name] + amount
            else:
                sent[name] = amount
        return sent

    def getReceived(self, raw, vinVoutsTxs):
        received = {}
        for vin in raw.get('vin', []):
            position = vin.get('vout', None)
            for tx in vinVoutsTxs:
                for vout in tx.get('vout', []):
                    if position == vout.get('n', None):
                        if 'asset' in vout:
                            name = vout.get('asset', {}).get('name', 'unknown asset')
                            amount = float(vout.get('asset', {}).get('amount', 0))
                        else:
                            name = 'Ravencoin'
                            amount = float(vout.get('value', 0))
                        if name in received:
                            received[name] = received[name] + amount
                        else:
                            received[name] = amount
        return received
    
    def getAsset(self, raw):
        return raw.get('txid', 'unknown txid')