# docker-gitweb-quick

A docker image to quickly expose a single git repository to a web browser.

## Rationale

Cljdoc, is a web site that hosts Clojure library documentation. From its web pages, it references 
git resources where they are hosted. This host is usually GitHub.

When testing cljdoc locally against local commits in a local repository, I wanted not to reach out to
GitHub, but to point to a local git server. [Git's gitweb](https://git-scm.com/docs/gitweb) seemed like
a simple enough solution, hence this repo.

## Usage

In a nutshell:

1. map desired port to container port `1234`
2. map your local directory to container `/repo`, specify `:ro` for readonly

Example docker run command:
```
docker run --rm -d --name gitweb-quick -p 3000:1234 -v $(pwd):/repo:ro leeread/gitweb-quick:latest
```

## Developer Notes

### Building

If you want to build the docker image, clone the repo from github and:
```
make image 
```

For a sanity interactive test run of what you just built:
```
make test TEST_REPO_DIR=/your/path/to/your/git/repo
```
Or to sanity test against current dir:
```
make test
```

After launch open http://localhost:3000/?p=.git in your web browser.

### Version Scheme

major.minor.patch where:

- major will likely stay at 1
- minor will likely stay at 0, but might increment for a significant change
- patch is the git commit count 

### Publishing

On every push to this GitHub repo, CircleCI will:

1. Build the docker image
2. Version tag this GitHub repo
3. Push the docker image to docker hub

There was some setup required at CircleCI: 

- To push to docker hub, added DOCKER_USER and DOCKER_PASS environment variables.
- To be able to tag github repo, had [to give CircleCI write privs to this repo](https://circleci.com/docs/2.0/gh-bb-integration/#creating-a-github-deploy-key).

See circleci config.

