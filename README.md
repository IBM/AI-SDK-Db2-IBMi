# WatsonX-SDK-Db2-IBMi

WatsonX client SDK for Db2 on IBM i


## Installation

To install on IBM i, you need to clone this git repository onto an IBM i. You can do this with the following methods:

1. use `git clone` on this repo
2. download the repo as a .zip from GitHub and extract it to your IBM i

Once the repo sources are in the IFS, then you can use GNU Make to build the SDK. GNU Make, `gmake`, is available in yum. Read more on the [IBM i OSS](https://ibmi-oss-docs.readthedocs.io/en/latest/yum/README.html#installation) docs.

Everything will get built into the `watsonx` repository.

```sh
cd /where/you/extracted/the/repo
gmake
```