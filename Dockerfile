FROM python:3.13.0a3-slim

MAINTAINER AWS ProServe

USER root

WORKDIR /app

ADD . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80

ENV NAME World

CMD ["python", "application.py"]
