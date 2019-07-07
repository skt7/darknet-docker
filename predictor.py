# This is the file that implements a flask server to do inferences. It's the file that you will modify to
# implement the scoring for your own algorithm.

from __future__ import print_function

import os
import json
import pickle
from io import StringIO
import sys
import signal
import traceback

import flask
import darknet
import pandas as pd
from PIL import Image
import json


class ScoringService(object):
    @classmethod
    def predict(self):
        return darknet.performDetect("test.jpg")

# The flask app for serving predictions
app = flask.Flask(__name__)


@app.route('/ping', methods=['GET'])
def ping():
    status = 200
    return flask.Response(response='\n', status=status, mimetype='application/json')


@app.route('/invocations', methods=['POST'])
def transformation():
    """Do an inference on a single batch of data. In this sample server, we take data as CSV, convert
    it to a pandas data frame for internal use and then convert the predictions back to CSV (which really
    just means one prediction per line, since there's a single column.
    """
    img = Image.open(flask.request.files['file'])
    print(img)
    print(type(img))

    img.save("test.jpg", "JPEG")

    predictions = ScoringService.predict()
    result = predictions

    res = []

    for obj,conf,box in predictions:
        res.append({'obj': obj, 'conf' : conf, 'box' : list(box)})

    res = json.dumps(res)

    return flask.Response(response=res, status=200, mimetype='application/json')

