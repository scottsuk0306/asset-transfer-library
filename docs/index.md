---
layout: default
title: Home
---

# Asset Transfer Library
{: .fs-9 }

`asset-transfer-library` is a collection of chaincode and application that works on `fabric-samples/test-network`. 
{: .fs-6 .fw-300 }

[View it on GitHub](https://github.com/scottsuk0306/asset-transfer-library){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## Getting started

### Dependencies
asset-transfer-library is built on 
`fabric-samples` repository. Follow all the steps in the [Hyperledger Fabric - Getting Started](https://hyperledger-fabric.readthedocs.io/en/release-2.2/getting_started.html) before executing scripts in this repository.

### Installation

1. Install the repository
```bash
$ cd ~/fabric-samples
$ git clone https://github.com/scottsuk0306/asset-transfer-library
```
2. Try out some shell scripts in `~/fabric-samples/asset-transfer-library`
```bash
$ ./library-test.sh
```
3. _Optional:_ Initialize search data (creates `search-data.json`)
```bash
$ bundle exec just-the-docs rake search:init
```
3. Run you local Jekyll server
```bash
$ jekyll serve
```
```bash
# .. or if you're using a Gemfile (bundler)
$ bundle exec jekyll serve
```
4. Point your web browser to [http://localhost:4000](http://localhost:4000)

If you're hosting your site on GitHub Pages, [set up GitHub Pages and Jekyll locally](https://help.github.com/en/articles/setting-up-your-github-pages-site-locally-with-jekyll) so that you can more easily work in your development environment.