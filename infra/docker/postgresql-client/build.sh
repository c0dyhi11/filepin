#!/bin/bash
docker login --username=c0dyhi11
docker build -t c0dyhi11/postgresql-client .
docker push c0dyhi11/postgresql-client
