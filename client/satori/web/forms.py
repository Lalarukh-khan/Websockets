from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, IntegerField, SelectField
from satori import config

class EditConfigurationForm(FlaskForm):
    flaskPort = IntegerField(config.verbose('flaskPort'), validators=[])
    nodejsPort = IntegerField(config.verbose('nodejsPort'), validators=[])
    dataPath = StringField(config.verbose('dataPath'), validators=[])
    modelPath = StringField(config.verbose('modelPath'), validators=[])
    walletPath = StringField(config.verbose('wallletPath'), validators=[])
    defaultSource = SelectField(config.verbose('defaultSource'), validators=[], choices=['streamr', 'satori'])
    # todo: make this two fields: a list where you can select and remove (can't remove the last one), and you can add by typing in the name on a textfield...
    electrumxServers = SelectField(config.verbose('electrumxServers'), validators=[], choices=[config.electrumxServers()])
    submit = SubmitField('Save')

