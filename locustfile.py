# from locust import Httplocust
# from tasks import MyTasks
from locust import HttpLocust, TaskSet, task
import json


class UserBehavior(TaskSet):

    @task(1)
    def json_example(self):

        payload = {
            "language": "python",
            "framework": "flask",
            "website": "aws",
            "python_version_info": "1.2",
            "flask_version_info": "0.1",
            "examples": [
                "a", "b"
            ],
            "boolean_test": "false"
        }
        headers = {'content-type': 'application/json',
                   'x-api-key': 'bp-smartblotter'
                   # 'cache-control': "no-cache"
                   # 'postman-token': "f3b0ab6d-d38a-22bb-240c-82ce6443d101"
                   }

        self.client.post(url="/json_example", data=json.dumps(payload), headers=headers)  # catch_response=True


class WebsiteUser(HttpLocust):

    task_set = UserBehavior
    min_wait = 5000
    max_wait = 15000


# locust -f locustfile.py --host=http://EC2Co-EcsEl-1AHLHP48GLN13-1815227589.eu-west-1.elb.amazonaws.com:80
# locust -f locustfile.py --host=EC2Co-EcsEl-1AHLHP48GLN13-1815227589.eu-west-1.elb.amazonaws.com
# locust -f --no-web -c 1000 -r 100 --run-time 1h30m
