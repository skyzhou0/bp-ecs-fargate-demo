import pkg_resources
import sys
import json
from flask_restplus import Api, Resource, fields, marshal
from flask import Flask, render_template, request, Blueprint
from functools import wraps

app = Flask(__name__)
# blueprint = Blueprint('api', __name__, url_prefix='/api')
# api = Api(blueprint, doc='/swagger')
# app.register_blueprint(blueprint)

authorizations = {'apikey': {
    'type': 'apiKey',
    'in': 'header',
    'name': 'X-API-KEY'
}}
api = Api(app, authorizations=authorizations)


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = 'bp-smartblotter'

        if 'X-API-KEY' in request.headers:
            provided_token = request.headers['X-API-KEY']

        if not provided_token:
            return {'message': 'API Token is missing.'}, 401
        elif token != provided_token:
            return {'message': 'Provided API Token is incorrect'}, 401
        else:
            return f(*args, **kwargs)
    return decorated


json_example_format = api.model('json_example', {
    'language': fields.String('programming lanuage.'),
    'framework': fields.String('framework.'),
    'website': fields.String(),
    'python_version_info': fields.String(),
    'flask_version_info': fields.String(),
    'examples': fields.List(fields.String),
    'boolean_test': fields.Boolean()
})


# @api.route('/web_ui')
# class Web_UI(Resource):
#     def get(self):
#         try:
#             return render_template("index.html")
#         except Exception as e:
#             return str(e)


@api.route('/json_example')
class Json_Example(Resource):
    @api.expect(json_example_format)
    @api.doc(security='apikey')
    @token_required
    def post(self):
        req_data = api.payload

        # retrive python version at run - time.
        req_data['python_version_info'] = str(sys.version_info[0]) + '.' + str(sys.version_info[1]) + '.' + str(sys.version_info[2])
        req_data['flask_version_info'] = pkg_resources.get_distribution("flask").version
        language = req_data['language']
        framework = req_data['framework']
        python_version = req_data['python_version_info']
        flask_version = req_data['flask_version_info']
        example = req_data['examples'][0]  # an index is needed because of the array
        boolean_test = req_data['boolean_test']

        return {'The language value is': req_data['language'],
                'The framework value is': framework,
                'The Python version is': python_version,
                'The Flask version is': flask_version,
                'The item at index 0 in the example list is': example,
                'The boolean value is': boolean_test}, 200


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)
