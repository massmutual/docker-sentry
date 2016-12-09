# docker-sentry

This repository will help you get [Sentry](https://getsentry.com/welcome/) running on your local machine.

## Dependencies

The instructions below can't be completed unless you have docker-machine installed. If you don't have it installed yet (and are using a Mac) [click here for instructions](https://docs.docker.com/docker-for-mac/).

## Local Installation Instructions

First, clone down this repository to your local machine and change into that directory:

```
$ git clone git@github.com:massmutual/docker-sentry.git
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
$ docker-compose -f docker-compose.yml -f docker-compose.local.yml up -d redis postgres
```

Next, prepare the database for Sentry:

```
$ docker-compose -f docker-compose.yml -f docker-compose.local.yml run --rm sentry upgrade
```

This command will ask you to create a user and, when prompted, be sure to give it superuser access.

Finally, start sentry, sentry's CRON process and its queue worker:

```bash
$ docker-compose -f docker-compose.yml -f docker-compose.local.yml up -d sentry sentry-cron sentry-worker-1
```

You're done! Nice! To see Sentry in action you'll need to get the IP for the docker-machine instance you just created:

```
$ docker-machine ip docker-sentry-local
```

Copy that IP address, paste it in your favorite web browser and login (with the credentials you created when initializing the database) to get started.

## Integrating Sentry With Applications

Once Sentry is up and running locally you'll probably want to test how it works. You can do this by integrating it with another locally running application, here's how:

1. First login to Sentry and click the blue **New Project** button in the top right of your browser window.

2. Enter a name and click **Create Project**.

3. Find the applicable **Framework** (if using one) or **Language** your app is utilizing, click on it and then follow the simple Installation & Setup instructions.

4. Now do something in your app that you know will raise an exception (if your app is super-stable then just add a bit of code you know will cause it to barf).

5. Within Sentry click on the 'Projects & Teams' link in the left sidebard (it's under the ORGANIZATION heading) and then click on the project you created in Step 2 to see how Sentry displays/aggregates errors.

## Releasing to AWS

First, change into the repo directory:

```
$ cd path/to/docker-sentry
```

Next, create a zip archive that ignores any git-related files or archives. In the command below substitute `YYYY-MM-DD` with today's date:

```
$ zip -r docker-sentry-YYYY-MM-DD.zip . -x *.git* -x *.zip*
```

Now, upload this file into the `releases` folder of the `mm-datascience-sentry` bucket in the Data Science Non-Prod AWS account.

And finally, initiate a CodeDeploy release that points to the file path of the zip file you just uploaded into S3. This deployment should be to the `SentryProdDeploymentGroup` deployment group of the `Sentry` application in the Non-Prod Data Science AWS account.
