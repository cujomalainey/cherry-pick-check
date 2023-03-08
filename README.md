# cherry-pick-check action

![Apache 2 licensed](https://img.shields.io/github/license/cujomalainey/cherry-pick-check)

This GitHub Action validates incoming PRs for release branches.

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
      - name: Install latest nightly
        uses: cujomalainey/cherry-pick-check@v1
        with:
            require_ref: true
            main_branch: main
```

## Inputs

| Name           | Required | Description                                                                                  | Type   | Default |
| -------------- | :------: | ---------------------------------------------------------------------------------------------| ------ | --------|
| `required_ref` |          | Require "cherry picked from" line in commits (generated with -x), otherwise rely on patch id | bool   | false   |
| `main_branch`  |          | Parent branch name to verify presense of PR commits against                                  | string | main    |

## Outputs

No output, only status reports

## License

This Action is distributed under the terms of the Apache-2 license, see [LICENSE](https://github.com/cujomalainey/cherry-pick-check/blob/main/LICENSE) for details.

## Contribute and support

Any contributions are welcomed!

If you want to report a bug or have a feature request,
check the [Contributing guide](https://github.com/cujomalainey/cherry-pick-check/blob/main/CONTRIBUTING.md).
