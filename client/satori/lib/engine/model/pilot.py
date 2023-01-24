'''
Basic Reponsibilities of the PilotModel:
1. continuously generate new models to attempt to find a better one.
    A. search the parameter space smartly
    B. search the engineered feature space smartly
    C. evaluate new datasets when they become available
'''
import random
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
import ppscore
from xgboost import XGBRegressor, XGBClassifier

from satori.lib.engine.model.interfaces.pilot import PilotModelInterface


class PilotModel(PilotModelInterface):

    ### FEATURES ####################################################################

    def _produceFeatureSet(self, featureNames:'list[str]'=None):
        producedFeatures = []
        for feature in featureNames or self.testFeatures:
            fn = self.features.get(feature)
            if callable(fn):
                producedFeatures.append(fn(self.data))
        if len(producedFeatures) > 0:
            self.testFeatureSet = pd.concat(
                producedFeatures,
                axis=1,
                keys=[s.name for s in producedFeatures])

    def _produceEvalFeatureSet(self, featureNames:'list[str]'):
        producedFeatures = []
        for feature in featureNames or self.testFeatures:
            fn = self.features.get(feature)
            if callable(fn):
                producedFeatures.append(fn(self.data))
        if len(producedFeatures) > 0:
            return pd.concat(
                producedFeatures,
                axis=1,
                keys=[s.name for s in producedFeatures])

    def _scoreFeatures(self, df:pd.DataFrame = None):# -> dict:
        ''' generates a predictive power score for each column in df '''
        df = df if df is not None else self.featureSet
        if self.target.columns[0] in df.columns:
            df = df.drop(self.target.columns[0], axis=1)
        df = pd.concat([df, self.target], axis=1)
        return {
            v['x']: v['ppscore']
            for v in ppscore.predictors(
                df,
                y=self.key(),
                output='df',
                sorted=True,
                sample=None)[['x', 'ppscore']].T.to_dict().values()}

    ### TRAIN ######################################################################

    def _produceTrainingSet(self):
        df = self.testFeatureSet.copy()
        df = df.iloc[0:-1,:]
        df = df.replace([np.inf, -np.inf], np.nan)
        df = df.reset_index(drop=True)
        self.trainX, self.testX, self.trainY, self.testY = train_test_split(
            df, self.target.iloc[0:df.shape[0], :], test_size=self.split or 0.2, shuffle=False)

    def _produceFit(self):
        if all(isinstance(y[0], (int, float)) for y in self.trainY.values):
            self.xgb = XGBRegressor(**{param.name: param.test for param in self.hyperParameters})
        else:
            # todo: Classifier untested
            self.xgb = XGBClassifier(**{param.name: param.test for param in self.hyperParameters})
        self.xgb.fit(
            self.trainX,
            self.trainY,
            eval_set=[(self.trainX, self.trainY), (self.testX, self.testY)],
            eval_metric='mae',
            early_stopping_rounds=200,
            verbose=False)

    ### META TRAIN ######################################################################

    def _produceHyperParameters(self):
        def radicallyRandomize():
            for param in self.hyperParameters:
                x = param.min + (random.random() * (param.max - param.min))
                if param.kind == int:
                    x = int(x)
                param.test = x

        def incrementallyRandomize():
            for param in self.hyperParameters:
                x = (
                    (random.random() * param.limit * 2) +
                    (param.value - param.limit))
                if param.min < x < param.max:
                    if param.kind == int:
                        x = int(round(x))
                    param.test = x

        x = random.random()
        if x >=.9:
            radicallyRandomize()
        elif .1 < x < .9:
            incrementallyRandomize()

    def _produceFeatures(self):
        ''' sets testFeatures to a list of feature names '''
        def preservePinned():
            self.testFeatures.extend([
                feature for feature in self.pinnedFeatures
                if feature not in self.testFeatures])

        def radicallyRandomize():
            count = min(max(len(self.chosenFeatures) + 2, 1), len(self.features))
            maxCount = len(list(self.features.keys()))
            if maxCount > count * 5:
                evalScores = generateEvalScores(possibleFeatures=list(self.features.keys()), count=count*5)
                self.testFeatures = [evalScores[i][0] for i in range(0, count)]
            else:
                self.testFeatures = list({
                    random.choice(list(self.features.keys()))
                    for _ in range(0, count)})

        def dropOne():
            if len(self.chosenFeatures) >= 2:
                choice = self.leastValuableFeature() or random.choice(self.chosenFeatures)
                self.testFeatures = [f for f in self.chosenFeatures if f != choice]
            else:
                self.testFeatures = self.chosenFeatures

        def addOne():
            notChosen = [f for f in self.features.keys() if f not in self.chosenFeatures]
            if len(notChosen) > 100:
                evalScores = generateEvalScores(notChosen)
                self.testFeatures = self.chosenFeatures + [evalScores[0][0]]
            elif len(notChosen) > 0:
                self.testFeatures = self.chosenFeatures + [random.choice(notChosen)]
            else:
                self.testFeatures = self.chosenFeatures

        def replaceOne():
            notChosen = [f for f in self.features.keys() if f not in self.chosenFeatures]
            if len(notChosen) == 0 or len(self.chosenFeatures) == 0:
                self.testFeatures = self.chosenFeatures
            else:
                if len(notChosen) > 100:
                    evalScores = generateEvalScores(notChosen)
                    addChoice = evalScores[0][0]
                elif len(notChosen) > 0:
                    addChoice = random.choice(notChosen)
                dropChoice = self.leastValuableFeature() or random.choice(self.chosenFeatures)
                self.testFeatures = self.chosenFeatures + [addChoice]
                self.testFeatures = [f for f in self.testFeatures if f != dropChoice]

        def generateEvalScores(possibleFeatures:'list[str]', count:int=None):
            count = count or min(20, round(len(possibleFeatures)*0.05))
            evalSet = self._produceEvalFeatureSet(
                featureNames=list(set([random.choice(possibleFeatures) for _ in range(0, count)])))
            evalSet = evalSet.replace([np.inf, -np.inf], np.nan)
            evalScores = self._scoreFeatures(evalSet)
            self.scoredFeatures = {**self.scoredFeatures, **evalScores}
            evalScores = list(evalScores.items())
            evalScores.sort(key=lambda x:x[1])
            evalScores.reverse()
            return evalScores

        if self.exploreFeatures:
            x = random.random()
            if x >=.9:
                radicallyRandomize()
            elif x >=.7:
                replaceOne()
            elif x >=.5:
                addOne()
            elif x >=.3:
                dropOne()
            else:
                self.testFeatures = self.chosenFeatures
        else:
            self.testFeatures = self.chosenFeatures
        preservePinned()

    ### MAIN PROCESSES #################################################################

    def build(self):
        self._produceFeatures()
        self._produceFeatureSet()
        self._produceTrainingSet()
        self._produceHyperParameters()
        self._produceFit()
    
## testing
#def show(name, value):
#    if isinstance(value, pd.DataFrame):
#        print(f'\n{name}\n', value.tail(2))
#    else:
#        print(f'\n{name}\n', value)
        