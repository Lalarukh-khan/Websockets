''' interface for a PilotModel '''

import pandas as pd
from satori.lib.engine.model.interfaces.stable import StableModelInterface

class PilotModelInterface():

    def __init__(
        self,
        manager:'ModelManager',
        stable:StableModelInterface,
        exploreFeatures:bool=True,
    ):
        '''
        manager: parent object
        stable: stable model
        exploreFeatures: change features or not
        '''
        self.manager = manager
        self.stable = stable
        self.exploreFeatures = exploreFeatures
        self.testFeatures = self.chosenFeatures
        self.scoredFeatures = {}
        self.xgb = None
        if not self.data.empty:
            self._produceFeatureSet()
    
    @property
    def data(self):
        ''' gets data from the model manager '''
        return self.manager.data
    
    @property
    def id(self):
        ''' gets id from the model manager '''
        return self.manager.id

    @property
    def target(self):
        ''' gets target from the stable model '''
        return self.stable.target

    @property
    def features(self):
        ''' gets features from the stable model '''
        return self.stable.features

    @property
    def featureSet(self):
        ''' gets featureSet from the stable model '''
        return self.stable.featureSet

    @property
    def chosenFeatures(self):
        ''' gets chosenFeatures from the stable model '''
        return self.stable.chosenFeatures

    @property
    def pinnedFeatures(self):
        ''' gets pinnedFeatures from the stable model '''
        return self.stable.pinnedFeatures
    
    @property
    def split(self):
        ''' gets split from the stable model '''
        return self.stable.split

    @property
    def hyperParameters(self):
        ''' gets hyperParameters from the stable model '''
        return self.stable.hyperParameters        

    def key(self):
        ''' gets key() from the model manager '''
        return self.manager.key()

    def leastValuableFeature(self):
        ''' gets leastValuableFeature() from the stable model '''
        return self.stable.leastValuableFeature()
        
    ### FEATURES ####################################################################

    def _produceFeatureSet(self, featureNames:'list[str]'=None):
        ''' produces a feature set for the pilot model '''

    ### MAIN PROCESSES #################################################################

    def build(self):
        '''builds pilot model'''
    


    



