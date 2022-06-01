# Containers for DAaaS

Containers to be used for general purpose Data Science.

## Docker Basics and Good Practices

> The information below covers some recommended good practices with Docker and
> provides some links for further reading.

**Useful References and Background Reading:**

- [Python on Docker Handbook][]
- [Container Security Fundamentals Book][]

### Start from a minimal official docker image

- Dockerhub has [official images][docker-official-images] that are maintained by
  the Docker community (e.g. security updates happen in a timely manner).

- An [official base image][docker-official-bases] is usually a great starting
  point to build off of.

- Many custom images only slightly extend a common base image (e.g. [Nvidia's
  base images][nvidia-base-image] are slight extensions of the ubuntu official
  base image)

**Recommendation:** start from a small official base image and build layers
ontop of it.

**Example steps to add a new image to aaw-contrib-containers**
1. Scan image using a tool like Trivy `$ ./trivy image hub.docker.com/yourdockerimage:latest (*best practice*)
2. Create new branch of StatCan/aaw-contrib-contains
3. Commit docker file and publish new branch
4. Allow repo CI, ACR and Artifactory scan to complete
5. Create pull request (ping us in our Slack space https://statcan-aaw.slack.com **#general**)

### Scan your containers for vulnerabilities

- There are lots of tools to do this in an automated way (e.g. [trivy][])

- Can build a docker image and scan it as part of a continuous integration
  pipeline. E.g. a condition to merge to master is that the Dockerfile provided
  must build successfully and then pass a security scan.

**Recommendation:** scan images for vulnerabilities, and consider incorporating
this process as a job in your CI/CD pipeline.

### Order stanzas from least likely to change to most likely to change

- Each line in your `Dockerfile` is called a stanza.

- When you are building an image, Docker is creating and caching an image layer
  for each stanza in your `Dockerfile`. Since layers are cached, if you build
  your image multiple times (e.g. you are changing certain stanzas), Docker can
  reuse the cached layers to reduce build time.

- However, any stanzas that come after the changed stanza **will be rebuilt**
  and therefore do not benefit from this layer caching that Docker implements.

**Recommendation:** to take advantage of layer caching and reduce your image
build times, it is recommended to put expensive stanzas that don't change often
early in your Dockerfile, and put lighter stanzas that do change often at the
end. This allows you to avoid rebuilding expensive unchanging layers every time
you need to rebuild your image after making a small change (e.g. installing a
new Python package).

### Handling python packages in Dockerfiles

- In general it is good practice to use a `requirements.txt` file in a project and to pin the versions (`pandas==1.2.3` rather than just `pandas`). Requirements files are also useful in constructing more succinct Dockerfiles (`RUN pip install -r requirements.txt` is briefer than `RUN pip install package1 package2 ...`)

- But, sometimes `requirements.txt` files can cause issues in Dockerfiles. For example, if you have 10 packages that never change but one that is updated frequently, you have the same problem as when you put frequently changed items at the top of a Dockerfile. Sometimes it is appropriate to have `requirements_rarely_changing.txt` and `requirements_frequently_changing.txt` (or, perhaps better titles), this way the frequently changing packages can be installed later in the Dockerfile.

### Do setup, execute, and cleanup in a single stanza

- As mentioned above, docker creates image layers based on a single stanza.

- If you do these steps in 3 separate stanzas, you will create 3 different
  layers that will all be stacked on your image. This can lead to Docker images
  that take up a lot more space on disk than they need to.

**Good Example:**

```docker
RUN apt-get -y update && \
    apt-get install git && \
    rm -rf /var/lib/apt/lists/*
```

**Bad Example:**

```docker
RUN apt-get -y update
RUN apt-get install git
RUN rm -rf /var/lib/apt/lists/*
```

**Recommendation:** Keep your setup, execute, and cleanup work in a single
stanza so that an image layer of minimal size gets created instead of multiple
larger layers.

### Execute containers as non-`root` user

- If the base image doesn't have one, [add a non-root user to your
  container][docker-add-user]. **Don't forget to [set `USER` at the
  end][docker-set-user].**

- By default, many containers are configured to run as root user.

- This is necessary at build time because we often need to install packages and
  change configuration settings.

- When it's time to run the container, however, we should run it as a non-root
  user (i.e. a less privileged user) by default.

- Reason for the above is that containers only provide process level
  virtualization as opposed to true operating system level virtualization. With
  a virtual machine manager such as VMWare, running as root on the VM doesn't
  give you access to the host machine. In a container runtime like Docker,
  however, your container is just a special kind of process on the host machine
  (spawned from the Docker Daemon on the host). This means it is possible for a
  malicious container to run as a process with root privileges on the host
  machine if the container itself is executed as root.

- Docker provides the `USER` directive to change the active user (can create a
  user using the `adduser` command in linux, see code snippet above).

**Recommendation:** always set the user to a non-root user at the end of your
Dockerfile by default using the `USER` directive in your Dockerfile.

### Do a multi-stage build

There are a couple of key reasons to building an image in this way.

- Reduced disk footprint - you can use one image to build one or more artifacts,
  then simply copy the relevant build artifact(s) out of the first image into a
  second image.

- Improved Security - You can use a complete image to build your application,
  then copy your application into a [distroless][] image.
  - A distroless image is a very stripped down image that contains only your
    applications and its runtime dependencies (e.g. a Python image might contain
    a python interpreter in a virtual environment)
  - This implies that there are no shells, package managers, or other programs
    you would expect to find on a standard Linux distribution).
  - Improves security because there is much less attack surface area (i.e. there
    are fewer ways an attacker can perform a malicious act on a distroless
    image).

**Recommendation:** consider using a multistage build to reduce disk footprint,
and, if applicable, consider copying your applications/build artifacts to a
distroless image to improve security.

### Avoid cache-busting your Dockerfiles

- Docker tries to avoid building anything it knows has not changed, but it cannot always detect this properly. When in situations where Docker always rebuilds layers unnecessarily, consider breaking your build into multiple images. This way you can put your static content in the first image, then base your final image on that first image (`FROM myfirstimage:v123`). This way you prevent Docker from trying to decide if your static content needs to be rebuilt (but note, if you do this and your static content does need rebuidling, you need to do that yourself!)

- Sometimes with python packages Docker will misunderstand whether a `requirements.txt` has changed, forcing a full reinstall of your python packages even when they are cached. One way around this is to add `RUN pip install mySlowPackages==0.1.2` explicitly near the top of the Dockerfile **in addition to in your requirements.txt file later in the build**. The benefit of this is that those explicit calls to pip are easier for Docker to cache, so they won't be reinstalled as frequently. And even though you do `pip install -r requirements.txt` later, pip itself will see that your package is already installed and skip it, meaning you save almost as much time as if Docker got the cache correct.

### Set build-time variables

- Docker provides an `ARG` directive that lets you specify build-time arguments.

- These build-time arguments don't persist when you launch a container instance
  from the image (in contrast to the `ENV` directive that sets environment
  variables that persist once the image is built).

- If you declare a build argument with `ARG`, you can pass
  `--build-arg ARG_NAME=some_value` when you run your `docker build` command to
  override whatever the default value of that argument is.

- Example: your image build depends on specific versions of another package you
  want to install, to make the image reusable, you may want to pass the package
  version as a build argument so that you can build different versions of the
  image over time.

- Example: you might want to set different build-time variables if you are
  building your image for different hosts (e.g. the URL for a proxy server).

- See [documentation on Docker builds][docker-build-args] for more information.

**Recommendation:** where applicable, consider using build-time arguments by
using `ARG` and `--build-arg` to declare and override build-time arguments.

### Lint your Dockerfile

- There is a tool called [hadolint][] that you can use to lint your Dockerfile.

- The linter will indicate areas where you can improve your Dockerfile and also
  provide suggestions.

**Recommendation:** lint your Dockerfile to improve code quality.

### Understand when not to use Alpine-based images

- A popular minimal image that is used as a base image in the Docker community
  is the [alpine][] image, which is based off of the Alpine distribution of
  Linux.

- This is a very lightweight image that has many use cases, but it may not be a good choice as a base image for data science oriented projects. In particular, for projects with heavy Python dependencies, it may be worth considering an alternative base image.

- Why?

  - Reason is that most python packages include prebuilt wheels (wheels are a kind of pre-built distribution for python that allow you to avoid the build stage that is normally required with source distributions).
  - Since Alpine is very stripped down compared to other Linux distributions, it has a different version of the standard C library that is required by most C programs (including Python). Specifically, the Alpine image uses the [`musl`](https://musl.libc.org/) implementation of the C standard library instead of [`glibc`](https://www.gnu.org/software/libc/) implementation.
  - Because of the above, Python wheels generally aren't available for `musl`, so when you install Python packages on an Alpine based image, you install the source code, which means that all C code in every Python package you use must be compiled.
  - This also means you need to figure out every system library dependency yourself.

- **Bottom Line:** If you try to install a bunch of Python packages on an Alpine based image, your build may take longer, be more error prone, and result in a higher disk footprint than if you installed those Python packages on an image based on Debian or another Linux distribution with the full standard C library (`glibc`).

**Recommendation:** Depending on your project requirements, if your project contains many Python dependencies, you may want to consider using a Docker image based on Debian or another Linux distribution other than Alpine. Note that this is not an absolute recommendation, as there are other considerations (e.g. security) that can impact the decision of which base image to use. However, you should be aware of the above-mentioned implication of using Alpine images for projects with significant Python dependencies.

**Background reading for those interested:**

- Article: [Python Wheels][]
- Article: [Alpine Docker with Python vs. Debian][]

[python on docker handbook]: https://pythonspeed.com/products/productionhandbook/
[container security fundamentals book]: https://www.amazon.ca/Container-Security-Fundamental-Containerized-Applications/dp/1492056707
[docker-official-images]: https://docs.docker.com/docker-hub/official_images/
[docker-official-bases]: https://hub.docker.com/search?type=image&category=base&image_filter=official
[nvidia-base-image]: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1.1/ubuntu20.04-x86_64/base/Dockerfile
[trivy]: https://github.com/aquasecurity/trivy
[docker-add-user]: https://github.com/StatCan/daaas-containers/blob/99e1fad4755e8d31990f074afa7ea084150c071a/frontier-counts/Dockerfile#L1-L10
[docker-set-user]: https://github.com/StatCan/daaas-containers/blob/99e1fad4755e8d31990f074afa7ea084150c071a/frontier-counts/Dockerfile#L23
[distroless]: https://github.com/GoogleContainerTools/distroless
[docker-build-args]: https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
[hadolint]: https://github.com/hadolint/hadolint
[alpine]: https://hub.docker.com/_/alpine
[python wheels]: https://realpython.com/python-wheels/
[alpine docker with python vs. debian]: https://pythonspeed.com/articles/alpine-docker-python/
