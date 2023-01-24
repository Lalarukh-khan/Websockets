# TODO: refactor see issue #24

'''
Basic Reponsibilities of the ModelManager:
1. keep a record of the datasets, features, and parameters of the best model.
2. retrain the best model on new data available, generate and report prediction.
3. continuously generate new models to attempt to find a better one.
    A. search the parameter space smartly
    B. search the engineered feature space smartly
    C. evaluate new datasets when they become available
4. save the best model details and load them upon restart
'''
import time
import pandas as pd
from reactivex.subject import BehaviorSubject
from sklearn.exceptions import NotFittedError

from satori import config
from satori.lib.engine.structs import HyperParameter, SourceStreamTargets
from satori.lib.engine.model.pilot import PilotModel
from satori.lib.engine.model.stable import StableModel
from satori.lib.engine.interfaces.model import ModelDataDiskApi
from satori.lib.engine.interfaces.model import ModelMemoryApi

class ModelManager:

    def __init__(
        self,
        disk:ModelDataDiskApi=None,
        memory:ModelMemoryApi=None,
        modelPath:str=None,
        hyperParameters:'list(HyperParameter)'=None,
        metrics:dict=None,
        features:dict=None,
        chosenFeatures:'list(str)'=None,
        pinnedFeatures:'list(str)'=None,
        exploreFeatures:bool=True,
        sourceId:str='',
        streamId:str='',
        targetId:str='',
        targets:list[SourceStreamTargets]=None,
        split:'int|float'=.2,
        override:bool=False,
    ):
        '''
        modelPath: the path of the model
        hyperParameters: a list of HyperParameter objects
        metrics: a dictionary of functions that each produce
                    a feature (from 1 dynamic column)
                    example: year over year, rolling average
        features: a dictionary of functions that each take in
                    multiple columns of the raw data and ouput
                    a feature (cols known ahead of time)
                    example: high minus low, x if y > 1 else 2**z
        chosenFeatures: list of feature names to start with
        pinnedFeatures: list of feature names to keep in model
        exploreFeatures: change features or not
        id: column name of response variable
        split: train test split percentage or count
        override: override the existing model saved to disk if there is one
        '''
        self.disk = disk
        self.memory = memory
        self.sourceId = sourceId
        self.streamId = streamId
        self.targetId = targetId
        self.modelPath = modelPath or config.root('..', 'models', self.sourceId, self.streamId, self.targetId + '.joblib')
        #self.sources = {'source': {'stream':['targets']}}
        self.targets:list[SourceStreamTargets] = targets
        self.id = SourceStreamTargets(source=sourceId, stream=streamId, targets=[targetId])
        self.setupFlags()
        self.get()
        # how could we use dependency injection here? 
        self.stable = StableModel(
            manager=self,
            hyperParameters=hyperParameters or [],
            metrics=metrics,
            features=features or {},
            chosenFeatures=chosenFeatures or [],
            pinnedFeatures=pinnedFeatures or [],
            split=split) 
        if not override:
            self.load()
        # how could we use dependency injection here? 
        self.pilot = PilotModel(
            manager=self,
            stable=self.stable,
            exploreFeatures=exploreFeatures) 
        self.syncManifest()

    @property
    def prediction(self):
        ''' gets prediction from the stable model '''
        return self.stable.prediction

    def buildStable(self):
        self.stable.build()

    def overview(self):
        return {
            'source': self.sourceId,
            'stream': self.streamId, 
            'target': self.targetId, 
            'value': self.stable.current.values[0][0] if hasattr(self.stable, 'current') else '',
            'prediction': self.stable.prediction if hasattr(self.stable, 'prediction') else '',
            'values': self.data.dropna().loc[:, (self.sourceId, self.streamId, self.targetId)].values.tolist()[-20:],
            'predictions': [.9,.8,1,.6,.9,.5,.6,.8,1.1],
            # this isn't the accuracy we really care about (historic accuracy), 
            # it's accuracy of this current model on historic data.
            'accuracy': f'{str(self.stableScore*100)[0:5]} %' if hasattr(self, 'stableScore') else '', 
            'subscribers':'none'}

    def syncManifest(self):
        manifest = config.manifest()
        manifest[self.key()] = {
            'targets': [x.asTuples() for x in self.targets], 
            'purged': manifest.get(self.key(), {}).get('purged', [])}
        config.put('manifest', data=manifest)

    ### FLAGS ################################################################################
    
    def setupFlags(self):
        self.modelUpdated = BehaviorSubject(None)
        self.targetUpdated = BehaviorSubject(None)
        self.inputsUpdated = BehaviorSubject(None)
        self.predictionUpdate = BehaviorSubject(None)
        self.predictionEdgeUpdate = BehaviorSubject(None)
        self.newAvailableInput = BehaviorSubject(None)
    
    ### GET DATA ####################################################################
    
    #@staticmethod
    #def addFeatureLevel(df:pd.DataFrame):
    #    ''' adds a feature level to the multiindex columns'''
    #    return pd.MultiIndex.from_tuples([c + ('Raw',)  for c in df.columns])

    def get(self):
        ''' gets the raw data from disk '''
            
        def handleEmpty():
            '''
            todo: what should we do if no data available yet? 
            should self.data be None? or should it be an empty dataframe without our target columns?
            or should it be an empty dataframe with our target columns?
            It seems like it should just be None and that we should halt behavior until it has a
            threshold amount of data.
            '''
            self.data = self.data if self.data is not None else pd.DataFrame(
                {x: [] for x in SourceStreamTargets.combine(self.targets)})
    
        self.data = self.disk.gather(sourceStreamTargetss=self.targets, targetColumn=self.id.id)
        handleEmpty()

    ### TARGET ####################################################################

    def key(self):
        return self.id.id()
    
    def streamKey(self):
        return self.id.id()

    ### FEATURE DATA ####################################################################

    def showFeatureData(self):
        '''
        returns true raw feature importance
        example: {
            'Close': 0.6193444132804871,
            'High': 0.16701968474080786,
            'Low': 0.38159190578153357}
        '''
        return self.stable.showFeatureData()

    ### META TRAIN ######################################################################

    def evaluateCandidate(self):
        ''' notice, model consists of the hyperParameter values and the chosenFeatures '''
        self.stableScore = self.stable.xgb.score(self.stable.testX, self.stable.testY)
        self.pilotScore = self.pilot.xgb.score(self.pilot.testX, self.pilot.testY)
        # not sure what this score is... r2 f1? not mae I think
        if self.stableScore < self.pilotScore:
            for param in self.stable.hyperParameters:
                param.value = param.test # is this right? it looks right but I don't think the stable model ever updates from the pilot
            self.stable.chosenFeatures = self.pilot.testFeatures
            self.stable.featureSet = self.pilot.testFeatureSet
            self.save()
            return True
        return False
    
    ### SAVE ###########################################################################

    def save(self):
        ''' save the current model '''
        self.disk.saveModel(
            self.stable.xgb,
            self.modelPath,
            self.stable.hyperParameters,
            self.stable.chosenFeatures)
        
    def load(self): # -> bool:
        ''' loads the model - happens on init so we automatically load our progress '''
        xgb = self.disk.loadModel(self.modelPath)
        if xgb == False:
            return False
        if (
            all([scf in self.stable.features.keys() for scf in xgb.savedChosenFeatures]) and
            True # all([shp in self.stable.hyperParameters for shp in xgb.savedHyperParameters])
        ):
            self.stable.xgb = xgb
            self.stable.hyperParameters = xgb.savedHyperParameters
            self.stable.chosenFeatures = xgb.savedChosenFeatures
        return True

    ### LIFECYCLE ######################################################################
    
    def runPredictor(self):
        def makePrediction(isTarget=False):
            if isTarget and self.stable.build():
                self.stable.producePrediction()
                show(f'prediction - {self.streamId} {self.targetId}:', self.stable.prediction)
                self.predictionUpdate.on_next(self)
            ## this is a feature to be added - a second publish stream which requires a
            ## different dataset - one where the latest update is taken into account.
            #    if self.edge: 
            #        self.predictionEdgeUpdate.on_next(self)
            #elif self.edge:
            #    self.stable.build()
            #    self.predictionEdge = self.producePrediction()
            #    self.predictionEdgeUpdate.on_next(self)
        
        def makePredictionFromNewModel():
            show(f'model updated - {self.streamId} {self.targetId}:', f'{self.stableScore}, {self.pilotScore}')
            makePrediction()
        
        def makePredictionFromNewInputs(incremental):
            self.data = self.memory.appendInsert(
                df=self.data, 
                incremental=incremental)
            makePrediction()
            
        def makePredictionFromNewTarget(incremental):
            for col in incremental.columns:
                if col not in self.data.columns:
                    incremental = incremental.drop(col, axis=1)
            #incremental.columns = ModelManager.addFeatureLevel(df=incremental)
            self.data = self.memory.appendInsert(
                df=self.data, 
                incremental=incremental)
            makePrediction(isTarget=True)
                
        self.modelUpdated.subscribe(lambda x: makePredictionFromNewModel() if x is not None else None)
        self.inputsUpdated.subscribe(lambda x: makePredictionFromNewInputs(x) if x is not None else None)
        self.targetUpdated.subscribe(lambda x: makePredictionFromNewTarget(x) if x is not None else None)
        
    def runExplorer(self):
        if hasattr(self.stable, 'target') and hasattr(self.stable, 'xgbStable'):
            try:
                self.pilot.build()
                if self.evaluateCandidate():
                    self.modelUpdated.on_next(True)
            except NotFittedError as e:
                '''
                this happens on occasion...
                maybe making  self.xgbStable a deepcopy would fix
                '''
                #print('not fitted', e)
                pass
            #except AttributeError as e:
            #    ''' 
            #    this happens at the beginning of running when we have not set
            #    self.xgbStable yet.
            #    
            #    '''
            #    #print('Attribute', e)
            #    pass
            ##except Exception as e:
            ##    print('UNEXPECTED', e)
        else:
            time.sleep(1)
    
    def syncAvailableInputs(self):
        
        def sync(x):
            '''
            add the new datastreams and histories to the top 
            of the list of things to explore and evaluate 
            '''
            ## something like this?
            #self.features.append(x)
            # 
            #self.targets.append(SourceStreamTargets(x))  or something
            #self.syncManifest()  then sync manifest when you change targets.
            #maybe remove targets that aren't being used as any features.. somewhere?
            
        self.newAvailableInput.subscribe(lambda x: sync(x) if x is not None else None)


## testing
def show(name, value):
    if isinstance(value, pd.DataFrame):
        print(f'\n{name}\n', value.tail(2))
    else:
        print(f'\n{name}\n', value)
        