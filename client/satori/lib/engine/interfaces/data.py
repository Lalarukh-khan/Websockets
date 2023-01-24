import pandas as pd

            
class DataDiskApi():
    
    def setAttributes(self, df:pd.DataFrame=None, source:str=None, stream:str=None, location:str=None, append:bool=None, ext:str='parquet'):
        ''' setter for any and all attributes, like __init__ returns self '''

    def incrementals(self, source:str=None, stream:str=None):
        ''' Layer 0 '''

    def append(self, df:pd.DataFrame=None):
        ''' Layer 1
        writes a dataframe to a parquet file.
        must remove multiindex column first.
        must use write_to_dataset rather than write_to_table to support append.
        streamId is the name of file.
        '''

    def compress(self, source:str=None, stream:str=None):
        ''' Layer 1
        assumes columns are always the same...
        this function is used on rare occasion to compress the on disk 
        incrementally saved data to long term storage. The compressed
        table takes up less room than the dataset because the dataset
        is partitioned into many files, allowing us to easily append
        to it. So we normally append observations to the dataset, and
        occasionally, like daily or weekly, run this compress function
        to save it to long term storage. We can still query long term
        storage the same way.
        '''
        
    def savePrediction(self, path:str=None, prediction:str=None):
        ''' Layer 1 - saves prediction to disk '''
