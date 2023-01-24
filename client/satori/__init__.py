from satori import config
from satori.lib import engine
from satori.lib import apis
from satori.lib import spoof
from satori.lib import start
from satori.lib import wallet
from satori.lib.apis import disk
from satori.lib.engine import view
from satori.lib.engine import Engine
from satori.lib.engine import DataManager
from satori.lib.engine import ModelManager
from satori.lib.engine import HyperParameter
from satori.lib.engine.view import View
from satori.lib.engine.view import JupyterView
from satori.lib.engine.view import JupyterViewReactive

# https://stackoverflow.com/questions/12059509/create-a-single-executable-from-a-python-project