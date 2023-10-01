# Contribute to Aurora Editor

Feel free to join and collaborate on our [Discord Server](https://discord.gg/vChUXVf9Em).

> Note:
> Since Aurora Editor is still in the development stage it can crash randomly.

&nbsp;

## Fork & Clone Aurora Editor

Tap the **"Fork"** button on the top of the site.

After forking clone the forked repository to your Mac. 

e.g. using `git clone https://github.com/yourusername/AuroraEditor.git`

&nbsp;

## Explore Issues

Find issues from the [Issues tab](https://github.com/AuroraEditor/AuroraEditor/issues).

If you find an issue you want to work on, please indicate it in the issue by commenting 

`@aurora-editor-bot please assign me`.

&nbsp;

## Getting Started

...

&nbsp;

## Code Style

We do not yet have a written out coding style, [Swiftlint rules do apply](.swiftlint.yml).

&nbsp;

## Pull Request

Once you are happy with your changes, submit a `Pull Request`.

The pull request opens with a template loaded. Fill out all fields that are relevant.

The `PR` should include following information:
* A descriptive **title** on what changed.
* A detailed **description** of changes.
* If you made changes to the UI please add a **screenshot** or **video** as well.
* If there is a related issue please add a **reference to the issue**. If not, create one beforehand and link it.
* If your PR is still in progress mark it as **Draft**.

&nbsp;

## Checks, Tests & Documentation

GitHub will inform the required reviewers for you.

Please resolve all `Violation` errors in Xcode. Otherwise the swiftlint check on GitHub will fail.

Once you submit the `PR` GitHub will run a couple of actions which run tests and `SwiftLint` (this can take a couple of minutes). Should a test fail, it cannot be merged until tests succeed.

Make sure to resolve all merge-conflicts otherwise the `PR` cannot be merged.

> **Important**: make sure your code is well documented so others can interact with your code easily!
