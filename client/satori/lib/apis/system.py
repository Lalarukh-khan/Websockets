''' the system api is how we talk to the machine, mainly to ask it about system resources '''
import platform
from numpy import mean
import psutil
import time
import shutil
import multiprocessing

def getPayload():
    ''' returns payload of metrics '''
    total, _, free = getDisk()
    return {
        'ram_total_gb': getRam(),
        'ram_available_percent': getRamAvailablePercentage(), 
        'cpu': getProcessorCount(), 
        'disk_total': total, 
        'disk_free': free, 
        'bandwidth': 'unknown'}

def getDisk():
    ''' returns ints in gb total, used, free '''
    total, used, free = shutil.disk_usage("/")
    return total // (2**30), used // (2**30), free // (2**30)
    
def getRam():
    ''' returns number of GB of ram on system as int '''
    return round(psutil.virtual_memory().total / (1024.0 **3))

def getProcessor():
    ''' name of processor as string '''
    return platform.processor()

def getProcessorCount():
    ''' number of cpus '''
    return multiprocessing.cpu_count()

def getProcessorUsage():
    ''' returns percentage of cpu usage as float '''
    return psutil.cpu_percent()

def getRamDetails():
    ''' returns dictionary containing these keys ['total', 'available' 'percent', 'used', 'free'] '''
    return dict(psutil.virtual_memory()._asdict())

def getRamAvailablePercentage():
    ''' returns percentage of available ram as float '''
    return psutil.virtual_memory().available * 100 / psutil.virtual_memory().total

def getProcessorUsageOverTime(seconds:int):
    ''' returns average of cpu usage over a number of seconds as float '''
    x = []
    for i in range(seconds):
        x.append(psutil.cpu_percent())
        if i <= seconds-1:
            time.sleep(1)
    return mean(x)