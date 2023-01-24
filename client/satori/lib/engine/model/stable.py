'''
Basic Reponsibilities of the StableModel:
1. keep a record of the datasets, features, and parameters of the best model.
2. retrain the best model on new data available, generate and report prediction.
'''
import numpy as np
import pandas as pd
from itertools import product
from functools import partial
from sklearn.model_selection import train_test_split
from xgboost import XGBRegressor, XGBClassifier

from satori.lib.engine.model.interfaces.stable import StableModelInterface


class StableModel(StableModelInterface):

    ### TARGET ######################################################################
    
    def _produceTarget(self):
        series = self.data.loc[:, self.id.id()].shift(-1)
        self.target = pd.DataFrame(series)
    
    ### FEATURES ####################################################################

    def _produceFeatureStructure(self):
        self.features = {
            **self.features,
            **{
            metric(column=col): partial(metric, column=col)
            for metric, col in product(self.metrics.values(), self.data.columns)}
        }

    def _produceFeatureSet(self):
        producedFeatures = []
        for feature in self.chosenFeatures:
            fn = self.features.get(feature)
            if callable(fn):
                producedFeatures.append(fn(self.data))
        if len(producedFeatures) > 0:
            self.featureSet = pd.concat(
                producedFeatures,
                axis=1,
                keys=[s.name for s in producedFeatures])
            
    def _produceFeatureImportance(self):
        self.featureImports = {
            name: fimport
            for fimport, name in zip(self.xgbStable.feature_importances_, self.featureSet.columns)
        } if self.xgbStable else {}

    def leastValuableFeature(self):
        ''' called by pilot '''
        if len(self.xgbStable.feature_importances_) == len(self.chosenFeatures):
            matched = [(val, idx) for idx, val in enumerate(self.xgbStable.feature_importances_)]
            candidates = []
            for pair in matched:
                if pair[0] not in self.pinnedFeatures:
                    candidates.append(pair)
            if len(candidates) > 0:
                return self.chosenFeatures[min(candidates)[1]]
        return None

    ### FEATURE DATA ####################################################################

    def _produceFeatureData(self):
        '''
        produces our feature data map:
        {feature: (feature importance, [raw inputs])}
        '''
        for k in self.featureSet.columns:
            self.featureData[k] = (
                self.featureImports[k], # KeyError: ('streamrSpoof', 'simpleEURCleanedHL', 'RollingHigh43median')
                self.featureData[k][1] if k in self.featureData.keys() else [] + (
                    self.features[k].keywords.get('columns', None)
                    or [self.features[k].keywords.get('column')]))

    def showFeatureData(self):
        '''
        returns true raw feature importance
        example: {
            'Close': 0.6193444132804871,
            'High': 0.16701968474080786,
            'Low': 0.38159190578153357}
        '''
        rawImportance = {}
        for importance, features in self.featureData.values():
            for name in features:
                rawImportance[name] = (importance / len(features)) + rawImportance.get(name, 0)
        return rawImportance

    ### CURRENT ####################################################################

    def _producePredictable(self):
        if self.featureSet.shape[0] > 0:
            self.current = pd.DataFrame(self.featureSet.iloc[-1,:]).T#.dropna(axis=1)
            #print('\nself.data\n', self.data.tail(2))
            #print('\nself.featureSet\n', self.featureSet.tail(2))
            #print('\nself.current\n', self.current)
            #print('\nself.prediction\n', self.prediction)

    def producePrediction(self):
        ''' called by manager '''
        self.prediction = self.xgb.predict(self.current)[0]

    ### TRAIN ######################################################################

    def _produceTrainingSet(self):
        df = self.featureSet.copy()
        df = df.iloc[0:-1,:]
        df = df.replace([np.inf, -np.inf], np.nan)
        df = df.reset_index(drop=True)
        self.trainX, self.testX, self.trainY, self.testY = train_test_split(
            df, self.target.iloc[0:df.shape[0], :], test_size=self.split or 0.2, shuffle=False)

    def _produceFit(self):
        self.xgbInUse = True
        if all(isinstance(y[0], (int, float)) for y in self.trainY.values):
            self.xgb = XGBRegressor(**{param.name: param.value for param in self.hyperParameters})
        else:
            # todo: Classifier untested
            self.xgb = XGBClassifier(**{param.name: param.value for param in self.hyperParameters})
        self.xgb.fit(
            self.trainX,
            self.trainY,
            eval_set=[(self.trainX, self.trainY), (self.testX, self.testY)],
            eval_metric='mae',
            early_stopping_rounds=200,
            verbose=False)
        #self.xgbStable = copy.deepcopy(self.xgb) ## didn't fix it.
        self.xgbStable = self.xgb
        self.xgbInUse = False

    ### MAIN PROCESSES #################################################################

    def build(self):
        if self.data is not None and not self.data.empty and self.data.shape[0] > 20:
            self._produceTarget()
            self._produceFeatureStructure()
            self._produceFeatureSet()
            self._producePredictable()
            self._produceTrainingSet()
            self._produceFit()
            self._produceFeatureImportance()
            self._produceFeatureData()
            return True
        return False
