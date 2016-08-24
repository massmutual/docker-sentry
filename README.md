# docker-sentry

This repository will help you get [Sentry](https://getsentry.com/welcome/) running on your local machine.

## Dependencies

The instructions below can't be completed unless you have docker-machine installed. If you don't have it installed yet (and are using a Mac) [click here for instructions](https://docs.docker.com/docker-for-mac/).

## Local Installation Instructions

First, clone down this repository to your local machine and change into that directory:

```
$ git clone git@github.com:respondcreate/docker-sentry.git
$ cd docker-sentry
```

Next, use docker-machine to create a new virtual box to host this application:

```bash
$ docker-machine create -d virtualbox docker-sentry-local
```

Then, make the docker-machine instance you created active in your current shell session:

```bash
$ eval "$(docker-machine env docker-sentry-local)"
```

Now, start the redis & postgres containers:

```
$ docker-compose up -d redis postgres
```

Next, prepare the database for Sentry:

```
$ docker-compose run --rm sentry upgrade
```

This command will ask you to create a user and, when prompted, be sure to give it superuser access.

Finally, start sentry, sentry's CRON process and its queue worker:

```bash
$ docker-compose up -d sentry sentry-cron sentry-worker-1
```

You're done! Nice! To see Sentry in action you'll need to get the IP for the docker-machine instance you just created:

```
$ docker-machine ip docker-sentry-local
```

Copy that IP address, paste it in your favorite web browser and login (with the credentials you created when initializing the database) to get started.
