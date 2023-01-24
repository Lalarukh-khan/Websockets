import logging
import json, time
from .connector import Connector


class ElectrumX(Connector):
    def __init__(self, *args, **kwargs):
        self.log = logging.getLogger(type(self).__name__)
        super(type(self), self).__init__(*args, **kwargs)

    def _receive(self):
        raw = self.connection.recv(1024*16)
        try:
            r = json.loads(raw)
            self.log.log(5, "_receive {}".format(r))
        except json.decoder.JSONDecodeError:
            print('RAW')
            print(raw)
        return raw

    def send(self, method, *args):
        payload = json.dumps(
            {
                "jsonrpc": "2.0",
                "id": int(time.time()*1000),
                "method": method,
                "params": args
            }
        ) + '\n'
        payload = payload.encode()
        self.log.log(5, "send {} {}".format(method, args))
        self.connection.send(payload)
        return self._receive()
