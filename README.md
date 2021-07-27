# findtable

This is Rails Application for finding restaurant with filtering and sorting according to ratings and average prices.

## Prerequisite

Make sure you've installed

- [docker](https://docs.docker.com/engine/install/#server)

- [docker-compose](https://docs.docker.com/compose/install/)

## Setup

In terminal navigate to the working directory

```
docker-compose build
```
## Rails Server

Start the rails server by the following command

```
docker-compose up
```

Start the dashboard by the following command

```
docker-compose exec dashboard rails s -b 0.0.0.0
```
