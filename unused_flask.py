import pkg_resources
import sys
import json
from flask_restplus import Api, Resource, fields, marshal
from flask import Flask, render_template, request

app = Flask(__name__)
api = Api(app)

json_example_format = api.model('json_example', {
    'language': fields.String('programming lanuage.'),
    'framework': fields.String('framework.'),
    'website': fields.String(),
    'python_version_info': fields.String(),
    'flask_version_info': fields.String(),
    'examples': fields.List(fields.String),
    'boolean_test': fields.Boolean()
})


@app.route('/')
def home():
    try:
        return render_template("index.html")
    except Exception as e:
        return str(e)

# @app.route('/generate')
# def gnerate_number():
# req_data


@api.route('/json_example')
class Json_Example(Resource):
    @api.expect(json_example_format)
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


# @app.route('/json-example', methods=['POST'])  # GET requests will be blocked
# def json_example():
#     req_data = request.get_json()

#     # retrive python version at run-time.
#     req_data['version_info']['python'] = str(sys.version_info[0]) + '.' + str(sys.version_info[1]) + '.' + str(sys.version_info[2])
#     req_data['version_info']['flask'] = pkg_resources.get_distribution("flask").version
#     language = req_data['language']
#     framework = req_data['framework']
#     python_version = req_data['version_info']['python']  # two keys are needed because of the nested object
#     flask_version = req_data['version_info']['flask']  # two keys are needed because of the nested object
#     example = req_data['examples'][0]  # an index is needed because of the array
#     boolean_test = req_data['boolean_test']

#     return '''
#            The language value is: {}
#            The framework value is: {}
#            The Python version is: {}
#            The Flask version is: {}
#            The item at index 0 in the example list is: {}
#            The boolean value is: {}'''.format(language, framework, python_version, flask_version, example, boolean_test)


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)
