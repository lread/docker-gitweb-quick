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
1. map your local directory to `/repo`
2. map desired port to 1234

See [test.sh](test.sh) for an interactive test. Can optionally specify repo dir, defaults to current dir.

After launch open http://localhost:3000/?p=.git
