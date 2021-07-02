# Release malc

This file describes how to make release builds of `malc`.

To make a release, perform the following steps:

1. Make a release commit and push it to a new branch
2. Make a pull request to `master` and get it approved and merged
3. Make a release tag for the merged pull request
4. Make a snapshot commit and get it merged to `master`

### 1. Make a release commit and push it to a new branch

The release commit shall contain the following changes in `pom.xml`:

- `project.version` is set to the release version, e.g. `1.0.0`
- `project.scm.tag` is set to the release tag, e.g. `release/1.0.0`

The name of the new branch doesn't matter, since it will be deleted after the release commit has been merged to `master`, but the convention for branch names is `<user-name>/<branch-name>`, e.g. `max/release`.

The commit message shall be `Release <version>`, e.g. `Release 1.0.0`.

```
$ git checkout -b max/release
$ sed -i 's|^  <version>.*</version>$|  <version>1.0.0</version>|' pom.xml
$ sed -i 's|^    <tag>.*</tag>$|    <tag>release/1.0.0</tag>|' pom.xml
$ git add pom.xml
$ git commit -m "Release 1.0.0"
$ git push origin max/release
```

### 2. Make a pull request to `master` and get it approved and merged

Go to the repository on GitHub, click `Pull requests`, and then `New pull request`. Make sure that `base` is set to `master`, and set `compare` to your branch. Click `Create pull request`, add appropriate `Reviewers`, and add yourself as `Assignees`.

### 3. Make a release tag for the merged pull request

Once your pull request has been merged, you need to fetch the new merged commit in `master` to create the release tag:

```
$ git checkout master
$ git fetch
$ git merge --ff-only
$ git tag release/1.0.0
$ git push origin release/1.0.0
```

### 4. Make a snapshot commit and get it merged to `master`

The snapshot commit shall contain the following changes in `pom.xml`:

- `project.version` is set to the next snapshot version, e.g. `1.0.1-SNAPSHOT`
- `project.scm.tag` is set to `HEAD`

The name of the new branch doesn't matter, since it will be deleted after the release commit has been merged to `master`, but the convention for branch names is `<user-name>/<branch-name>`, e.g. `max/snapshot`.

The commit message shall be `Next snapshot`.

```
$ git checkout -b max/snapshot
$ sed -i 's|^  <version>.*</version>$|  <version>1.0.1-SNAPSHOT</version>|' pom.xml
$ sed -i 's|^    <tag>.*</tag>$|    <tag>HEAD</tag>|' pom.xml
$ git add pom.xml
$ git commit -m "Next snapshot"
$ git push origin max/snapshot
```

Get the snapshot commit approved and merged as in step 2 above.
