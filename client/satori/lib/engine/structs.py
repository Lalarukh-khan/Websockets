import json
import pandas as pd 
import datetime as dt
from satori import config

class SourceStreamTargets:
    
    def __init__(
        self,
        stream:str,
        targets:list[str]=None,
        source:str=None,
    ):
        self.stream = stream
        self.targets = targets or [stream] 
        self.source = source or config.defaultSource()

    def id(self):
        ''' id has one target '''
        return (self.source, self.stream, self.targets[0])

    def key(self):
        return self.id()
    
    def streamKey(self):
        return (self.source, self.stream)
    
    def get(self):
        ''' easy to combine '''
        return (self.source, self.stream, self.targets)

    def asTuples(self):
        ''' easy to combine '''
        return [(self.source, self.stream, target) for target in self.targets]

    def asMap(self):
        ''' hard to combine '''
        return {self.source: {self.stream: self.targets}}

    def asDict(self):
        ''' hard to combine '''
        return {(self.source, self.stream): self.targets}
    
    @staticmethod
    def combine(sourceStreamTargetss:list['SourceStreamTargets']):
        ''' {('x', 'y', 'z1'), ('a', 'b', 'c'), ('x', 'y', 'z2')} '''
        return {(source, stream, targets) for sst in sourceStreamTargetss for source, stream, targets in sst.asTuples()}

    @staticmethod
    def condense(sourceStreamTargetss:list['SourceStreamTargets']):
        '''
        SourceStreamTargets.condense(targets)
        [('x', 'y', ['z1', 'z2']), ('a', 'b', ['c'])]
        '''
        existing = {}
        ret = []
        for sst in sourceStreamTargetss:
            if (sst.source, sst.stream) in existing.keys():
                existing[(sst.source, sst.stream)].extend(sst.targets)
                existing[(sst.source, sst.stream)].extend(sst.targets)
            else:
                existing = {**existing, **sst.asDict()}
        for key, value in existing.items():
            ret.append((key[0], key[1], list(set(value))))
        return ret
    
class SourceStreamMap(dict):
    
    def __init__(self, content=None, source:str=None, stream:str=None):
        super(SourceStreamMap,self).__init__([
            ((source, stream), content)] if source is not None and stream is not None else [])
    
    def add(self, source, stream, value=None):
        return self.__setitem__((source, stream), value)
    
class SourceStreamTargetMap(dict):
    def __init__(self, targetValues:dict[str, str]=None, source:str=None, stream:str=None):
        super(SourceStreamTargetMap,self).__init__([
            ((source, stream, k), v) for k, v in (targetValues or {}).items()])
    def add(self, source, stream, target, value=None):
        return self.__setitem__((source, stream, target), value)
    def isFilled(self, source:str=None, stream:str=None, key:tuple[str, str]=None):
        if key is not None:
            condition = lambda x: x[1] == key[1] and x[0] == key[0]
        if source is not None and stream is not None:
            condition = lambda x: x[1] == stream and x[0] == source    
        return all([self[k] is not None for k in self if condition(k)])
    def erase(self, source:str=None, stream:str=None, key:tuple[str, str]=None):
        for k in self:
            if key is not None:
                if k[1] == key[1] and k[0] == key[0]:
                    self[k] = None
            elif source is not None and stream is not None:
                if k[1] == stream and k[0] == source:
                    self[k] = None
    def getAllAsMap(self, source:str=None, stream:str=None, key:tuple[str, str]=None):
        if key is not None:
            condition = lambda x: x[1] == key[1] and x[0] == key[0]
        if source is not None and stream is not None:
            condition = lambda x: x[1] == stream and x[0] == source    
        return {k: self[k] for k in self if condition(k)}
    def getAll(self, source:str=None, stream:str=None, key:tuple[str, str]=None):
        if key is not None:
            condition = lambda x: x[1] == key[1] and x[0] == key[0]
        if source is not None and stream is not None:
            condition = lambda x: x[1] == stream and x[0] == source    
        return [(k, self[k]) for k in self if condition(k)]

class HyperParameter:
    
    def __init__(
        self,
        name:str='n_estimators',
        value=3,
        limit=1,
        minimum=1,
        maximum=10,
        kind:'type'=int
    ):
        self.name = name
        self.value = value
        self.test = value
        self.limit = limit
        self.min = minimum
        self.max = maximum
        self.kind = kind

class Observation:
    
    def __init__(self, data):
        self.data = data
        self.parse(data)

    def parse(self, data):
        ''' {
                'source-id:"streamrSpoof",'
                'stream-id:"simpleEURCleaned",'
                'observation-id': 3675, 
                'observed-time': "2022-02-16 02:52:45.794120", 
                'content': {
                    'High': 0.81856, 
                    'Low': 0.81337, 
                    'Close': 0.81512}}
            note: if observed-time is missing, define it here.
        '''
        j = json.loads(data)
        self.sourceId = j['source-id']
        self.streamId = j['stream-id']
        self.observedTime = j.get('observed-time', str(dt.datetime.utcnow()))
        self.observationId = j['observation-id']
        self.content = j['content']
        if isinstance(self.content, dict):
            self.df = pd.DataFrame(
                {(self.sourceId, self.streamId, target): values for target, values in list(self.content.items()) + [('StreamObservationId', self.observationId)]},
                #columns=pd.MultiIndex.from_tuples([(self.sourceId, self.streamId, self.)]),
                index=[self.observedTime])
        elif not isinstance(self.content, dict):
            self.df = pd.DataFrame(
                {(self.sourceId, self.streamId, self.streamId): [self.content] + [('StreamObservationId', self.observationId)]}, 
                index=[self.observedTime])

    def key(self):
        return (self.sourceId, self.streamId)