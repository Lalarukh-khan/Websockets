from functools import reduce
import pandas as pd
import warnings
from satori.lib.apis.interfaces.memory import DiskMemory
from satori.lib.engine.interfaces.model import ModelMemoryApi

warnings.simplefilter(action='ignore', category=FutureWarning)


class Memory(ModelMemoryApi, DiskMemory):

    @staticmethod    
    def mergeAllTime(dfs:list[pd.DataFrame]):
        ''' Layer 1 - not useful?
        combines multiple mutlicolumned dataframes.
        to support disparate frequencies, 
        outter join fills in missing values with previous value.
        So this isn't really important anymore becauase I realized
        it'll not be needed anywhere I think, maybe for the live
        updates models and stream but that's for later.
        '''
        if dfs is pd.DataFrame:
            return dfs
        if len(dfs) == 0:
            return None
        if len(dfs) == 1:
            return dfs[0]
        for df in dfs:
            df.index = pd.to_datetime(df.index)
        return reduce(
            lambda left, right: pd.merge(
                left, 
                right, 
                how='outer',
                left_index=True,
                right_index=True)
            # can't use this for merge because we don't want to fill the targetColumn
            .fillna(method='ffill'), 
            #.fillna(method='bfill'),
            # don't bfill here, in many cases its fine to bfill, but not in all.
            # maybe we will bfill in model. always bfill After ffill.
            dfs)

    @staticmethod    
    def merge(dfs:list[pd.DataFrame], targetColumn:'str|tuple[str]'):
        ''' Layer 1
        combines multiple mutlicolumned dataframes.
        to support disparate frequencies, 
        outter join fills in missing values with previous value.
        filters down to the target column observations.
        '''
        if len(dfs) == 0:
            return None
        if len(dfs) == 1:
            return dfs[0]
        for ix, item in enumerate(dfs):
            if targetColumn in item.columns:
                dfs.insert(0, dfs.pop(ix))
                break
            # if we get through this loop without hitting the if
            # we could possibly use that as a trigger to use the
            # other merge function, also if targetColumn is None 
            # why would we make a dataset without target though?
        for df in dfs:
            df.index = pd.to_datetime(df.index)
        return reduce(
            lambda left, right: 
                pd.merge_asof(left, right, left_index=True, right_index=True),
            dfs)

    @staticmethod    
    def appendInsert(df:pd.DataFrame, incremental:pd.DataFrame):
        ''' Layer 2
        after datasets merged one cannot merely append a dataframe. 
        we must insert the incremental at the correct location.
        this function is more of a helper function after we gather,
        to be used by models, it doesn't talk to disk directly.
        incremental is should be a multicolumn, one row DataFrame. 
        '''
        df.index = pd.to_datetime(df.index)
        incremental.index = pd.to_datetime(incremental.index)
        if incremental.index.values[0] in df.index.values:
            df.loc[incremental.index, [x for x in incremental.columns]] = incremental
        else:
            df = df.append(incremental).sort_index()
        return df.fillna(method='ffill')