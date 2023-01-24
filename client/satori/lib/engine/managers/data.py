# TODO: refactor see issue #24

'''
the DataManager should save the streams to a database on disk as a parquet file
so that the model managers can get their data easily.

the DataManager object could even run as a separate server.
it should be as light weight as possible, handling data streams and their
updates constantly. any downtime it has should be spent aggregating new
datasets that might be of use to the Modelers. It does not evaluate them using
the predictive power score, but could access the global map of publishers and
their subscribers on chain, thereby acting as a low-computation recommender
system for the Modelers since it doesn't actually compute any scores. The
DataManager needs lots of disk space, both ram and short term memory. It also
needs high bandwidth capacity. If it serves only one modeler it need not be
separate from the modeler, but if it serves many, it should be on its own
hardware.

Basic Reponsibilities of the DataManager:
1. listen for new datapoints on all datastreams used by ModelManagers
    A. download and save new datapoints
    B. notify relevant ModelManagers new data is available (see 2.)
2. produce a query whereby to pull data for each model from disk.
    A. list the datasets to pull
    B. for each dataset list the columns
    C. filter by recent data (model managers can add this part if they want)
3. search for useful data streams
    A. generate a map of all pub sub relationships from the chain
    B. find similar subscribers: compare the model manager's inputs to other
       subscribers inputs
    C. find a likely group of useful publishers: of all the similar subscribers
       (by input) what group of publishers (by input or metadata) do they
       subscribe to that this model manager does not?
    D. find a unique datastream in the group: one that few or zero similar
       subscriber subscribe to
    E. download the datastream and notify model manager
4. garbage collect stale datastreams
'''
import datetime as dt
from reactivex.subject import BehaviorSubject
from satori import config
from satori.lib.engine.interfaces.data import DataDiskApi

from satori.lib.engine.structs import Observation, SourceStreamTargetMap, SourceStreamMap

class DataManager:

    def __init__(self, disk:DataDiskApi=None):
        # dictionary of source, streams, and their latest incremental
        self.targets = SourceStreamMap() # must be initialized with keys otherwise we'll post partial predictions
        # dictionary of source, stream, targets and their latest predictions
        self.predictions = SourceStreamTargetMap() # must be initialized with keys otherwise we'll post partial predictions
        self.listeners = []
        self.newData = BehaviorSubject(None)
        self.disk = disk

    def importance(self, inputs:dict = None):
        inputs = inputs or {}
        totaled = {}
        for importances in inputs.values():
            for k, v in importances.items():
                totaled[k] = v + totaled.get(k, 0)
        self.imports = sorted(totaled.items(), key=lambda item: item[1])

    def showImportance(self):
        return [i[0] for i in self.imports]

    def getExploratory(self):
        '''
        asks an endpoint for the history of an unseen datastream.
        provides showImportance and everythingSeenBefore perhaps...
        scores each history against each of my original data columns
        Highest are kept, else forgotten (not included in everything)
        a 'timer' is started for each that is kept so we know when to
        purge them if not picked up by our models, so the models need
        a mechanism to recognize new stuff and test it out as soon as
        they see it.
        '''
        pass

    def getPurge(self):
        ''' in charge of removing columns that aren't useful to our models '''
        pass

    
    #################################################################################
    ### most of the fuctions above this point are made obsolete by the new design ###
    #################################################################################
    
    def runSubscriber(self, models: list):
        ''' triggered from the flask app '''
        
        def handleNewData(models, observation: Observation):
            ''' append to existing datastream, save to disk, notify models '''
            
            def remember():
                '''
                cache latest observation for each stream as an Observation object with a DataFrame 
                if it's new returns true so process can continue, if a repeat, return false
                '''
                if observation.key() not in self.targets.keys():
                    self.targets[observation.key()] = None
                x = self.targets[observation.key()]
                if x is not None and x.observationId == observation.observationId:
                    return False
                self.targets[observation.key()] = observation
                return True
        
            def saveIncremental():
                ''' save these observations to the right parquet file on disk '''
                self.disk.setAttributes(source=observation.sourceId, stream=observation.streamId).append(observation.df.copy())
            
            def compress():
                ''' compress if the number of incrementals is high '''
                self.disk.setAttributes(source=observation.sourceId, stream=observation.streamId)
                if len(self.disk.incrementals()) > 100:
                    try:
                        self.disk.compress()
                    except Exception:
                        pass
                
            def tellModels():
                ''' tell the modesl that listen to this stream and these targets '''
                for model in models:
                    if (model.sourceId == observation.sourceId and
                        model.streamId == observation.streamId and
                        model.targetId in observation.content.keys()
                    ):
                        model.targetUpdated.on_next(observation.df)
                    ##elif any([key in observation.df.columns for key in model.feature.keys()]): 
                    ##    model.inputsUpdated.on_next(True)
                    ## reference model.targets:
                    #if (
                    #    model.targets.sourceId == observation.sourceId and
                    #    model.targets.streamId == observation.streamId 
                    #):
                    #    sendUpdates = []
                    #    for modelTarget in model.targets.targets:
                    #        for obsTarget in observation.targets:
                    #            if modelTarget == obsTarget:
                    #                sendUpdates.append(obsTarget)
                    #    model.inputsUpdated.on_next(
                    #        observation.df.loc[:, [
                    #            (observation.sourceId, observation.streamId, update) 
                    #            for update in sendUpdates]])

            if remember():
                saveIncremental()
                compress()
                tellModels()
            
        self.listeners.append(self.newData.subscribe(
            lambda x: handleNewData(models, x) if x is not None else None))
        #self.listeners.append(self.newData.subscribe(lambda x: print('triggered')))
                

    def runPublisher(self, models):
        def publish(model):
            ''' probably a rest call to the NodeJS server so it can pass it to the streamr light client '''
            
            def remember():
                if model.key() not in self.predictions.keys():
                    self.predictions[model.key()] = None
                self.predictions[model.key()] = model.prediction
                return True
            
            def post():
                ''' here we save prediction to disk, but that'll change once we can post it somewhere '''
                if self.predictions.isFilled(key=model.key()):
                    for k, v in self.predictions.getAll(key=model.key()):
                        path = config.root('..', 'predictions', k[0], k[1], k[2] + '.txt')
                        self.disk.savePrediction(path=path, prediction=f'{str(dt.datetime.now())} | {k} | {v}\n')
                    self.predictions.erase(key=model.key())
                    
            remember()
            post()
                
        ## non-implemented feature yet. as it turns out this requires the model to contain two datasets or
        ## one dataset that is cut on two different time frames (merge_asof for the above publish and 
        ## anti-merge_as of for the edge stream), so it introduces a lot of complexity we're not willing
        ## to deal with right now.
        #def publishEdge(model):
        #    ''' probably a rest call to the NodeJS server so it can pass it to the streamr light client '''
        #    with open(f'{model.id.id()}.txt', 'w') as f:
        #        f.write(f'{model.predictionEdge}, {str(dt.datetime.now())} {model.predictionEdge}')
                
        for model in models:
            self.listeners.append(model.predictionUpdate.subscribe(
                lambda x: publish(x) if x else None))
        #    self.listeners.append(model.predictionEdgeUpdate.subscribe(lambda x: publishEdge(x) if x else None))
    
    def runScholar(self, models):
        ''' download histories and tell model sync '''
        
        def syncManifest(purged: list = None, new: list = None):
            purged = purged or []
            new = new or []
            manifest = config.manifest()
            toPurge = manifest.get('datasets to purge', [])
            toPurge.extend(new)
            for x in purged:
                toPurge.remove(x)
            manifest['datasets to purge'] = {
                ds: dt.datetime.now() for ds in toPurge}
            config.put('manifest', data=manifest)

        ## look for new useful datastreams - something like this
        #self.download(self.bestOf(self.compileMap(models)))
        #self.availableInputs.append(newInput)
        #for model in models:
        #    model.newAvailableInput.on_next(newInput)
        '''
        ## basic algorithm:
        while true
            wait a bit (or get triggered when a model feels it's exhausted it's search space)
            choose next model to target
            PURGE look at all datasets we have downloaded, look at manifest, anything that is
                old enough that isn't being used in the model manifests (could litterally use
                model.targets) gets tossed out as in deleted from disk and purged datasets
                gets added to a list by model so we don't download it again, unsubscribe first
                then syncManifest(purged=[...])
            RECOMMENDER SYSTEM: choose what kind of dataset you should ask for 
                (model inputs vs the inputs of other datasets)
                (dataset features, etc.)
                (the general case recommender system will generate a map of datasets 
                 and their inputs, find the dataset(s) that looks the most like mine
                 by inputs and choose a (popular) input they listen to that I don't)
            ask for the dataset, download and save to disk
            subscribe for updates
            tell model its available
            add it to the list with timestamp for later purge using
                syncManifest(new=[...])     
        '''
        '''
        ## what the manifest should look like
        config.yaml:
        port: 24685
        manifest:
            models:
                modelName: 
                    pinned: [(sourceId, streamId, targetId), ...]
                    accepted: [...]
                    evaluating: [...]
                    purged: [...]
        
        '''