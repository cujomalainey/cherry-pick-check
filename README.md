# cherry-pick-check action

![Apache 2 licensed](https://img.shields.io/github/license/cujomalainey/cherry-pick-check)

This GitHub Action verifies all commits in the PR are in a parent branch. This check is meant for release branches and not development.

**Table of Contents**

* [Example workflow](#example-workflow)
* [Inputs](#inputs)
* [License](#license)
* [Contribute and support](#contribute-and-support)

## Example workflow

```yaml
on:
  pull_request:
    branches-ignore: 
      - main

name: Validate

jobs:
  check:
    name: Check Cherry Picks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check all commits exist in main
        uses: cujomalainey/cherry-pick-check@v1
        with:
            require_ref: true
            main_branch: main
```

## Inputs

| Name           | Required | Description                                                                                 | Type   | Default |
| -------------- | :------: | --------------------------------------------------------------------------------------------| ------ | --------|
| `required_ref` |          | Require "cherry picked from" line in commits (generated with -x), otherwise rely on subject | bool   | false   |
| `main_branch`  |          | Parent branch name to verify presense of PR commits against                                 | string | main    |

If you want to cover multiple branches you can do this with a [`matrix`](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) and pass in the branches via the matrix param.

## Outputs

No output, only status reports

## License

This Action is distributed under the terms of the Apache-2 license, see [LICENSE](https://github.com/cujomalainey/cherry-pick-check/blob/main/LICENSE) for details.

## Contribute and support

Any contributions are welcomed!

If you want to report a bug or have a feature request,
check the [Contributing guide](https://github.com/cujomalainey/cherry-pick-check/blob/main/CONTRIBUTING.md).
