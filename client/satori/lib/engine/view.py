import pandas as pd
import datetime as dt
from matplotlib import pyplot as plt
from IPython.display import clear_output

class View:
    '''
    holds functionality for viewing model results
    '''

    def __init__(self):
        ''' no need '''
        self.isReactive = False

    @staticmethod
    def pretty(x:dict):
        return ' ' + '\n '.join([f' {k}: {v}' for k, v in x.items()])
    
    def view(self, *args, **kwargs):
        self.print(*args, **kwargs)
    
    @staticmethod
    def print(*args, **kwargs):
        for arg in args:
            print(View.pretty(arg) if isinstance(arg, dict) else arg)
        for key, value in kwargs.items():
            print(key)
            print(View.pretty(value) if isinstance(value, dict) else value)


class JupyterView(View):
    '''
    holds functionality for viewing model results in a jupyter notebook
    '''

    def __init__(self, points:int=7):
        self.points = points
        super().__init__()

    def view(self, data, predictions:dict, scores:dict):
        self.jupyterOut(data, predictions, scores)

    def jupyterOut(self, data, predictions:dict, scores:dict):

        def lineWidth(score:str) -> float:
            try:
                score = (float(score.split()[0])+1)**3
            finally:
                score = None
            return min(abs(score or .1), 1)

        #(model.data.iloc[-1*self.points:]
        #    .append(pd.DataFrame({k: [v] for k, v in predictions.items()}))
        #    .reset_index(drop=True)
        #    .plot(figsize=(8,5), linewidth=3))
        ## to show confidence with linewidth:
        ax = None
        for ix, col in enumerate(data.columns.tolist()):
            ax = (data.iloc[-1*self.points:, [ix]]
                .append(pd.DataFrame({col: [predictions.get(col, 0)]}))
                .reset_index(drop=True)
                .plot(
                    **{'ax': ax} if ax is not None else {},
                    figsize=(8,5),
                    linewidth=lineWidth(scores.get(col, 0))))
        clear_output()
        plt.show()

class JupyterViewReactive(View):
    '''
    holds functionality for viewing model results in a jupyter notebook
    '''

    def __init__(self, points:int=7):
        self.isReactive = True
        self.points = points
        self.predictions = {}
        self.scores = {}
        self.listeners = []
        self.cooldown = 30
        self.displayTime = dt.datetime.now() + dt.timedelta(days=-1)  
        
    def listen(self, model):
        def gatherPrediction(model):
            self.predictions[model.id] = model.prediction
            self.view(model)
            
        def gatherScores(model):
            self.scores[model.id] = f'{round(model.stable, 3)} ({round(model.test, 3)})'
            self.view(model)
        
        self.listeners.append(model.predictionUpdate.subscribe(
            lambda x: gatherPrediction(x) 
            if x else None))
        self.listeners.append(model.modelUpdated.subscribe(
            lambda x: gatherScores(x) 
            if x else None))
    
    def view(self, model):
        def cooldownOver():
            return (dt.datetime.now() - self.displayTime).total_seconds() > self.cooldown
        
        if cooldownOver():
            self.displayTime = dt.datetime.now()
            self.jupyterOut(model)
            self.print(**{
                'Predictions:\n': self.predictions,
                '\nScores:\n': self.scores})

    def jupyterOut(self, model):

        def lineWidth(score:str) -> float:
            if score: 
                try:
                    score = (float(score.split()[0])+1)**3
                except AttributeError as e:
                    print('Expected', e)
                    score = None
                return min(abs(score or .1), 1)
            return .1

        ax = None
        for ix, col in enumerate(model.data.columns.tolist()):
            print(model.id, self.predictions.get(col), col)
            ax = (model.data.iloc[-1*self.points:, [ix]]
                .append(pd.DataFrame({col: [self.predictions.get(col, 0)]}))
                .reset_index(drop=True)
                .plot(
                    **{'ax': ax} if ax is not None else {},
                    figsize=(8,5),
                    linewidth=lineWidth(self.scores.get(col, 0))))
        clear_output()
        plt.show()