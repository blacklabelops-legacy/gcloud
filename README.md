This is a container stuffed with the latest Google Cloud SDK along with all modules. It is the easiest way to
run commands against your cloud instances, apps, switch projects and regions!

Furthermore, you can schedule your commands with cron in order to manage the cloud!

# Make It Short!

In short, you can run Google Cloud SDK commands against your cloud projects with this container. Just by executing:

~~~~
$ docker run -it --rm \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    -e "CLOUDSDK_CORE_PROJECT=example-project" \
    -e "CLOUDSDK_COMPUTE_ZONE=europe-west1-b" \
    -e "CLOUDSDK_COMPUTE_REGION=europe-west1" \
    blacklabelops/gcloud \
    gcloud compute instances list
~~~~

> Lists your instances inside the specified cloud project. Note: Auth credentials are inside the file
auth.json.

You can even set up a Cron Schedule and manage the cloud!

~~~~
$ docker run --rm \
	  -v $(pwd)/logs/:/logs \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    -e "GCLOUD_CRON=$(base64 example-crontab.txt)" \
    blacklabelops/gcloud
$ cat logs/gcloud.log
~~~~

> Will start the schedule and log to the local log folder. The cron schedule is defined inside the file example-crontab.txt.

# Use Cases

* Managing backups by pushing files to Cloud Storage and Buckets.
* Restoring backups from Cloud Storage and Buckets into containers.
* Executing Long Running File Transfers.

# Google Cloud API

You can only run commands against existing cloud projects!

Documentation can be found here: [Creating & Deleting Projects](https://developers.google.com/console/help/new/#creatingdeletingprojects)

Also you will have to activate APIs manually before you can use them!

Documentation can be found here: [Activating & Deactivating APIs](https://developers.google.com/console/help/new/#activating-and-deactivating-apis)

# Google Cloud Authentication

There are two ways to authenticate the gcloud tools and execute gcloud commands. Both ways need
a Google Cloud OAuth Service Account file. This is documented here: [Service Account Authentication](https://cloud.google.com/storage/docs/authentication?hl=en#service_accounts).

You can now mount the file into your container and execute commands like this:

~~~~
$ docker run -it --rm \
    -v $(pwd)/auth.json:/auth.json \
    -e "GCLOUD_ACCOUNT_FILE=/auth.json" \
    blacklabelops/gcloud \
    bash
$ gcloud compute instances list
~~~~

> Opens the bash console inside the container, the second command is executed inside the authenticated container. This works both with json and P12 key files.

You can also Base64 encode the authentication file and stuff it inside an environment variable. This works perfect for long-running stand-alone containers.

~~~~
$ docker run -it --rm \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    blacklabelops/gcloud \
    bash
$ gcloud compute instances list
~~~~

> Opens the bash console inside the container, the second command is executed inside the authenticated container. This works both with json and P12 key files.

# Setting the Cloud Project

Set your default Google Project by defining the CLOUDSDK_CORE_PROJECT environment variable.

~~~~
$ docker run -it --rm \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    -e "CLOUDSDK_CORE_PROJECT=example-project" \
    blacklabelops/gcloud \
    bash
$ gcloud compute instances list
~~~~

> Runs all commands against the project `example-project`.

# Setting the Zone and Region

Set your default Google Project Zone and Region with the environment variables CLOUDSDK_COMPUTE_ZONE and
CLOUDSDK_COMPUTE_REGION.

The documentation can be found here : [Regions & Zones](https://cloud.google.com/compute/docs/zones?hl=en)

Example:

~~~~
$ docker run -it --rm \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    -e "CLOUDSDK_CORE_PROJECT=example-project" \
    -e "CLOUDSDK_COMPUTE_ZONE=europe-west1-b" \
    -e "CLOUDSDK_COMPUTE_REGION=europe-west1" \
    blacklabelops/gcloud \
    bash
$ gcloud compute zones list
$ gcloud compute regions describe ${CLOUDSDK_COMPUTE_REGION}
~~~~

> Set your region and zone to belgium. More details appear with the `describe` command.

# Cron Scheduling

This container can manage gcloud instances using cron. The crontab can be mounted or simply converted into
a base64 string and configured inside the container over environment variables.

An working example crontab can be found here: [example-crontab.txt](example-crontab.txt)

Please note that in the case of cron triggering commands, the environment variables have
to be configured inside the crontab. See my example file for details.

Also note that when you need to include your own scripts then you just have to extend this container.

Mounting a crontab:

~~~~
$ docker run --rm \
	  -v $(pwd)/example-crontab.txt:/example-crontab.txt \
    -v $(pwd)/logs/:/logs \
    -e "GCLOUD_CRONFILE=/example-crontab.txt" \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    -e "GCLOUD_CRON=$(base64 example-crontab.txt)" \
    blacklabelops/gcloud
~~~~

> Needs an environment variable in order to tell the entryscript where to find the crontab.

Using a Base64 encoded crontab:

~~~~
$ docker run --rm \
	  -v $(pwd)/logs/:/logs \
    -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
    -e "GCLOUD_CRON=$(base64 example-crontab.txt)" \
    blacklabelops/gcloud
~~~~

> The authentication file and crontab are encoded on the fly.

# Container Logging

I use this containers for logging:

* [blacklabelops/fluentd](https://github.com/blacklabelops/fluentd)
* [blacklabelops/loggly](https://github.com/blacklabelops/fluentd/tree/master/fluentd-loggly)

# Google Storage Container Backups

First run the Jenkins example container:

~~~~
docker run -d -p 8090:8080 --name jenkins_jenkins_1 blacklabelops/jenkins
~~~~

> This will pull the container and start the latest jenkins on port 8090

Instant backup of the jenkins volume using a run-once container:

~~~~
$ docker run \
  --volumes-from jenkins_jenkins_1 \
  -v $(pwd)/backups/:/backups \
  -v $(pwd)/logs/:/logs \
  -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
  blacklabelops/gcloud \
  bash -c "cd /jenkins/ && tar -czvf /backups/JenkinsBackup$(date +%Y-%m-%d-%H-%M-%S).tar.gz * && gsutil rsync /backups gs://jenkinsbackups"
~~~~

> Note: You need a cloud storage named `jenkinsbackups` to make this work

Now the cron example with a prefixed schedule:

~~~~
$ docker run \
  --volumes-from jenkins_jenkins_1 \
  -v $(pwd)/backups/:/backups \
  -v $(pwd)/logs/:/logs \
  -e "GCLOUD_ACCOUNT=$(base64 auth.json)" \
  -e "GCLOUD_CRON=$(base64 example-crontab.backup.txt)" \
  blacklabelops/gcloud
~~~~

> Backup using cron schedule.

# References

* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Google Cloud](https://cloud.google.com/)
* [Google Developers Cloud Console](https://console.developers.google.com/project)
