#!/usr/bin/env python
# -*- coding: utf-8 -*-

# run with:
# sudo nohup /app/anaconda3/bin/python app.py > /dev/null 2>&1 &

'''
this is the backend server which listens to messages from and sends messages
to the nodejs server so it can communicate with the streamr light client.

Communication model
NodeJS Streamr Light Client <-> Python Flask <-> DataManager <-> ModelManager

Frankly, this flask app could be considered the front end if we want. Whatever
is easiest to implement.


'''
import os
import sys
import random
import json
import threading
import secrets
import satori
import requests
import pandas as pd
import datetime as dt
from flask import Flask, url_for, render_template, redirect, jsonify, send_file
from flask import send_from_directory, session, request, flash, Markup, Response
#from flask_mobility import Mobility
from waitress import serve
import webbrowser
from satori.web import forms
from satori.lib.engine.structs import Observation
from satori.lib import wallet


###############################################################################
## Helpers ####################################################################
###############################################################################

def spoofStreamer():
    thread = threading.Thread(target=satori.spoof.Streamr(
        sourceId='streamrSpoof',
        streamId='simpleEURCleanedHL',
    ).run, daemon=True)
    thread.start()
    thread = threading.Thread(target=satori.spoof.Streamr(
        sourceId='streamrSpoof',
        streamId='simpleEURCleanedC',
    ).run, daemon=True)
    thread.start()

###############################################################################
## Globals ####################################################################
###############################################################################

# development flags
full = True # just web or everything
debug = True

# singletons
Connection = None
Engine = None
Wallet = None
app = Flask(__name__)

app.config['SECRET_KEY'] = secrets.token_urlsafe(16)
if full:
    ipfsDaemon = satori.start.startIPFS()
    Wallet = wallet.Wallet()()
    Connection = satori.start.establishConnection(Wallet)
    Engine = satori.start.getEngine(Connection)
    Engine.run()

###############################################################################
## Functions ##################################################################
###############################################################################

def get_user_id():
    return session.get('user_id', '0')

###############################################################################
## Errors #####################################################################
###############################################################################

@app.errorhandler(404)
def not_found(e):
    return render_template('404.html'), 404

###############################################################################
## Routes - static ############################################################
###############################################################################

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(
        os.path.join(app.root_path, 'static/img/favicon'),
        'favicon.ico',
        mimetype='image/vnd.microsoft.icon')

@app.route('/static/<path:path>')
def send_static(path):
    return send_from_directory('static', path)


@app.route('/generated/<path:path>')
def send_generated(path):
    return send_from_directory('generated', path)

@app.route('/home')
def home():
    return redirect(url_for('dashboard'))

@app.route('/index')
def index():
    return redirect(url_for('dashboard'))

@app.route('/test')
def test():
    # print(session)
    # print(request)
    print(request.MOBILE)
    return render_template('test.html')

@app.route('/kwargs')
def kwargs():
    ''' ...com/kwargs?0-name=widget_name0&0-value=widget_value0&0-type=widget_type0&1-name=widget_name1&1-value=widget_value1&1-#type=widget_type1 '''
    kwargs = {}
    for i in range(25):
        if request.args.get(f'{i}-name') and request.args.get(f'{i}-value'):
            kwargs[request.args.get(f'{i}-name')] = request.args.get(f'{i}-value')
            kwargs[request.args.get(f'{i}-name') + '-type'] = request.args.get(f'{i}-type')
    return jsonify(kwargs)

@app.route('/ping', methods=['GET'])
def ping():
    from datetime import datetime
    return jsonify({'now': datetime.now().strftime("%Y-%m-%d %H:%M:%S")})

###############################################################################
## Routes - forms #############################################################
###############################################################################


@app.route('/configuration', methods=['GET', 'POST'])
def edit_configuration():
    import importlib
    global forms
    forms = importlib.reload(forms)

    def present_form(edit_configuration):
        edit_configuration.flaskPort.data = satori.config.flaskPort()
        edit_configuration.nodejsPort.data = satori.config.nodejsPort()
        edit_configuration.dataPath.data = satori.config.dataPath()
        edit_configuration.modelPath.data = satori.config.modelPath()
        edit_configuration.walletPath.data = satori.config.walletPath()
        edit_configuration.defaultSource.data = satori.config.defaultSource()
        edit_configuration.electrumxServers.data = satori.config.electrumxServers()
        resp = {
            'title': 'Configuration',
            'edit_configuration': edit_configuration}
        return render_template('forms/config.html', **resp)

    def accept_submittion(edit_configuration):
        data = {}
        if edit_configuration.flaskPort.data not in ['', None, satori.config.flaskPort()]:
            data = {**data, **{satori.config.verbose('flaskPort'): edit_configuration.flaskPort.data}}
        if edit_configuration.nodejsPort.data not in ['', None, satori.config.nodejsPort()]:
            data = {**data, **{satori.config.verbose('nodejsPort'): edit_configuration.nodejsPort.data}}
        if edit_configuration.dataPath.data not in ['', None, satori.config.dataPath()]:
            data = {**data, **{satori.config.verbose('dataPath'): edit_configuration.dataPath.data}}
        if edit_configuration.modelPath.data not in ['', None, satori.config.modelPath()]:
            data = {**data, **{satori.config.verbose('modelPath'): edit_configuration.modelPath.data}}
        if edit_configuration.walletPath.data not in ['', None, satori.config.walletPath()]:
            data = {**data, **{satori.config.verbose('walletPath'): edit_configuration.walletPath.data}}
        if edit_configuration.defaultSource.data not in ['', None, satori.config.defaultSource()]:
            data = {**data, **{satori.config.verbose('defaultSource'): edit_configuration.defaultSource.data}}
        if edit_configuration.electrumxServers.data not in ['', None, satori.config.electrumxServers()]:
            data = {**data, **{satori.config.verbose('electrumxServers'): [edit_configuration.electrumxServers.data]}}
        satori.config.modify(data=data)
        return redirect('/dashboard')

    edit_configuration = forms.EditConfigurationForm(formdata=request.form)
    if request.method == 'POST':
        return accept_submittion(edit_configuration)
    return present_form(edit_configuration)
    
###############################################################################
## Routes - dashboard #########################################################
###############################################################################

@app.route('/')
@app.route('/dashboard')
def dashboard():
    ''' 
    UI
    - send to setup process if first time running the app...
    - show earnings
    - access to wallet
    - access metrics for published streams
        (which streams do I have?)
        (how often am I publishing to my streams?)
    - access to data management (monitor storage resources)
    - access to model metrics 
        (show accuracy over time)
        (model inputs and relative strengths)
        (access to all predictions and the truth)
    '''
    if Engine is None:
        streamsOverview = [{'source': 'Streamr', 'stream': 'DATAUSD/binance/ticker', 'target':'Close', 'subscribers':'3', 'accuracy': '97.062 %', 'prediction': '3621.00', 'value': '3548.00', 'predictions': [2,3,1]}]
    else:
        streamsOverview = [model.overview() for model in Engine.models]
    resp = {
        'title': 'Dashboard',
        'wallet': Wallet,
        'streamsOverview': streamsOverview,
        'configOverrides': satori.config.get()}
    return render_template('dashboard.html', **resp)


class StreamsOverview():
    
    def __init__(self, engine):
        self.engine = engine
        self.overview = [{'source': '-', 'stream': '-', 'target':'-', 'subscribers':'-', 'accuracy': '-', 'prediction': '-', 'value': '-', 'values': [3,2,1], 'predictions': [3,2,1]}]
        self.demo = [{'source': 'Streamr', 'stream': 'DATAUSD/binance/ticker', 'target':'Close', 'subscribers':'99', 'accuracy': [.5,.7,.8,.85,.87,.9,.91,.92,.93], 'prediction': 15.25, 'value': 15, 'values': [12,13,12.5,13.25,14,13.5,13.4,13.7,14.2,13.5,14.5,14.75,14.6,15.1], 'predictions': [3,2,1]}]
        self.viewed = False
    
    def setIt(self):
        self.overview = [model.overview() for model in self.engine.models]
        self.viewed = False

    def setViewed(self):
        self.viewed = True
    
@app.route('/model-updates')
def modelUpdates():
    def update():
        streamsOverview = StreamsOverview(Engine)
        listeners = [] 
        #listeners.append(Engine.data.newData.subscribe(
        #    lambda x: streamsOverview.setIt() if x is not None else None))    
        if Engine is not None: 
            for model in Engine.models:
                listeners.append(model.predictionUpdate.subscribe(lambda x: streamsOverview.setIt() if x is not None else None))
            while True:
                if streamsOverview.viewed:
                    time.sleep(1)
                else: 
                    # parse it out here?
                    yield "data: " + str(streamsOverview.overview).replace("'", '"') + "\n\n"
                    streamsOverview.setViewed()
        else:
            yield "data: " + str(streamsOverview.demo).replace("'", '"') + "\n\n"
            
                    
    import time
    return Response(update(), mimetype='text/event-stream')

@app.route('/wallet')
def wallet():
    Wallet.get(allWalletInfo=True)
    import io
    import qrcode
    from base64 import b64encode
    img = qrcode.make(Wallet.address)
    buf = io.BytesIO()
    img.save(buf)
    buf.seek(0)
    #return send_file(buf, mimetype='image/jpeg')
    img = b64encode(buf.getvalue()).decode('ascii')
    img_tag = f'<img src="data:image/jpg;base64,{img}" class="img-fluid"/>'
    resp = {
        'title':'Wallet',
        'image': img_tag,
        'wallet': Wallet}
    return render_template('wallet.html', **resp) 

###############################################################################
## Routes - subscription ######################################################
###############################################################################

@app.route('/subscription/update', methods=['POST'])
def update():
    """
    returns nothing
    ---
    post:
      operationId: score
      requestBody:
        content:
          application/json:
            {
            "source-id": id,
            "stream-id": id,
            "observation-id": id,
            "content": {
                key: value
            }}
      responses:
        '200':
          json
    """
    ''' from streamr - datastream has a new observation
    upon a new observation of a datastream, the nodejs app will send this 
    python flask app a message on this route. The flask app will then pass the
    message to the data manager, specifically the scholar (and subscriber)
    threads by adding it to the appropriate subject. (the scholar, will add it
    to the correct table in the database history, notifying the subscriber who
    will, if used by any current best models, notify that model's predictor
    thread via a subject that a new observation is available by providing the
    observation directly in the subject).
    
    This app needs to create the DataManager, ModelManagers, and Learner in
    in order to have access to those objects. Specifically the DataManager,
    we need to be able to access it's BehaviorSubjects at data.newData
    so we can call .on_next() here to pass along the update got here from the 
    Streamr LightClient, and trigger a new prediction.
    '''
    #print('POSTJSON:', request.json)
    print('POSTJSON...')
    x = Observation(request.json)
    Engine.data.newData.on_next(x)
    
    return request.json

###############################################################################
## Routes - history ###########################################################
# we may be able to make these requests
###############################################################################

@app.route('/history/request')
def publsih():
    ''' to streamr - create a new datastream to publish to '''
    # todo: spoof a dataset response - random generated data, so that the
    #       scholar can be built to ask for history and download it.
    resp = {}
    return render_template('unknown.html', **resp)


@app.route('/history/')
def publsihMeta():
    ''' to streamr - publish to a stream '''
    resp = {}
    return render_template('unknown.html', **resp)

###############################################################################
## Entry ######################################################################
###############################################################################

if __name__ == '__main__':
    if full:
        spoofStreamer()

    #serve(app, host='0.0.0.0', port=satori.config.get()['port'])
    if not debug: 
        webbrowser.open('http://127.0.0.1:24685', new=0, autoraise=True)
    app.run(host='0.0.0.0', port=satori.config.flaskPort(), threaded=True, debug=debug)
    #app.run(host='0.0.0.0', port=satori.config.get()['port'], threaded=True)
    # https://stackoverflow.com/questions/11150343/slow-requests-on-local-flask-server
    # did not help
    
# http://localhost:24685/
# sudo nohup /app/anaconda3/bin/python app.py > /dev/null 2>&1 &
# > python satori\web\app.py    


