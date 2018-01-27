# docker-antivirus

thebaconguy/docker-antivirus is a virus and malware scanner as a Docker microservice. It runs inotify as the main process that watches a pre-defined volume for file write events and calls clamscan for each new file that is written into the volume. We do *not* use the ClamAV daemon, which has a constant, large memory consumption. 

### Notes
- **The image may only be built once per hour on the same IP address due to download limitations of the ClamAV signatures**
- a running container instance consumes around 10 MB memory when idle
- the image is maintained by Dietrich Rordorf, [Ediqo](https://www.ediqo.com/)
- initially the Dockerfile was prepared for [IWF](http://www.iwf.ch/web-solutions/)
- you can contribute to this project at https://github.com/rordi/docker-antivirus

#### Changes added in this fork (thebaconguy/docker-antivirus)
- Copies files to temp scanning directory instead of moving them, allowing files to continue being used (e.g. seeding) until they are found to be malicious. Inspired by [this great comment](https://www.linkedin.com/feed/update/urn:li:article:8952422602466404009?commentUrn=urn%3Ali%3Acomment%3A%28article%3A8952422602466404009%2C6286958125845217280%29)
- This also means the '/data/av/ok' volume will be unused, as the scanned files will stay where they originally were in '/data/av/queue' unless a scan says they're dirty and moves them into quarantine.

#### Version 2
- released 06.11.2017
- use supervisord as main command, spawning inotify and cron as subprocesses
- refactor assets folder structure to reduce number of layers in resulting Docker image

#### Version 1
 - released 19.01.2017
 - first stable build

### Quick start

If you simply want to try out the setup, copy the docker-compose.yml file from the [repository](https://github.com/thebaconguy/docker-antivirus) to your local file system and run:

    docker-compose up -d


### Introduction

Build for [thebaconguy/docker-antivirus](https://hub.docker.com/r/thebaconguy/docker-antivirus/) Docker image running [Linux Malware Detect (LMD)](https://github.com/rfxn/linux-malware-detect) with [ClamAV](https://github.com/vrtadmin/clamav-devel) as the scanner.

thebaconguy/docker-antivirus provides a plug-in container to e.g. scan file uploads in web applications before further processing.

The container requires three volume mounts from where to take files to scan, and to deliver back scanned files and scan reports.

The container auto-updates the LMD and ClamAV virus signatures once per hour.

Optionally, an email alert can be sent to a specified email address whenever a virus/malware is detected in a file.


### Required volume mounts

Please provide the following volume mounts at runtime (e.g. in your docker-compose file). The antivirus container expects the following paths to be present when running:

        /data/av/queue         --> files to be checked
        /data/av/ok            --> checked files (ok)
        /data/av/nok           --> scan reports for infected files

Additionally, you may mount the quarantine folder and provide it to the antivirus container at the following path (this might be useful if you want to process the quarantined files from another container):

        /data/av/quarantine    --> quarantined files



### Docker Pull & Run

To install the container, pull it from the Docker registry (latest tag refers to
the master branch, use dev tag for dev branch):

    docker pull thebaconguy/docker-antivirus:latest

To run the docker container, use the following command. If you pass an email address as the last argument, email alerts will be activated and sent to this email address whenever a virus is detected.

    docker run -tid --name docker-antivirus thebaconguy/docker-antivirus [email@example.net]


### Docker Build & Run

To build your own image, clone the repo and cd into the cloned repository root folder. Then, build as follows:

    docker build -t docker-antivirus .

To start the built image, run the following command. Optionally pass an email address to activate email alerts when a virus/malware is detected:

    docker run -tid --name docker-antivirus docker-antivirus:latest [email@example.net]


### Testing

You can use the [EICAR test file](https://en.wikipedia.org/wiki/EICAR_test_file) to test the AV setup. (Caution: create the file yourself and copy-paste the file content that can be found on the linked Wikipedia article.)


### Mounting volumes with docker-compose

Here is an exmple entry that you can use in your docker-compose file to easily plug in the container into your existing network. Replace "networkid" with your actual netwerk id. Optionally turn on email alerts by uncommenting the "command". Finally, make sure the ./data/av/... folders exist on your local/host system or change the paths.


    docker-av:
      image: thebaconguy/docker-antivirus
      container_name: docker-av
      # uncomment and set the email address to receive email alerts when viruses are detected
      #command:
      # - /usr/local/install_alerts.sh email@example.net
      volumes:
        - ./data/queue:/data/av/queue
        - ./data/ok:/data/av/ok
        - ./data/nok:/data/av/nok
      networks:
        - yournetworkid
