<p align="center">
  <img alt="Logo" src="https://avatars.githubusercontent.com/u/106490518?s=128&v=4" width="128px;" height="128px;">
</p>

<p align="center">
  <h1 align="center">AuroraEditor</h1>
</p>

<p align="center">
  <a href='https://twitter.com/Aurora_Editor' target='_blank'>
    <img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/Aurora_Editor?color=f6579d&style=for-the-badge">
  </a>
  <a href='https://discord.gg/5aecJ4rq9D' target='_blank'>
    <img alt="Discord" src="https://img.shields.io/discord/997410333348077620?color=f98a6c&style=for-the-badge">
  </a>
  <a href='https://nightly.link/AuroraEditor/AuroraEditor/workflows/nightly/main/AuroraEditor_Nightly.zip' target='_blank'>
  <img alt="Download" src="https://img.shields.io/badge/Download-Nightly Build-6bbee8?style=for-the-badge">
 </a>
</p>

<br />

AuroraEditor is a IDE built by the community, for the community, and written in Swift for the best native performance and feel for macOS. 

It will support everything you could expect from an Xcode-inspired application, including deep integration with your selected git provider, project planning, and your favourite built in editor tools.

<img width="1012" alt="github-banner" src="https://user-images.githubusercontent.com/63672227/187914690-2277654c-6cab-4738-b151-1c85947bea8b.jpg">

<br />

<p align="center">
  <a href='https://github.com/AuroraEditor/AuroraEditor/pulls'><img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
  <a href='https://github.com/AuroraEditor/AuroraEditor/pulls?q=is%3Apr+is%3Aclosed'><img alt="GitHub closed pull requests" src="https://img.shields.io/github/issues-pr-closed-raw/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
  <br />
  <a href='https://github.com/AuroraEditor/AuroraEditor/issues'><img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
  <a href='https://github.com/AuroraEditor/AuroraEditor/issues?q=is%3Aissue+is%3Aclosed'><img alt="GitHub closed issues" src="https://img.shields.io/github/issues-closed-raw/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
  <br />
  <img alt="GitHub branch checks state" src="https://img.shields.io/github/checks-status/AuroraEditor/AuroraEditor/main?color=f98a6c&style=for-the-badge">
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge">
  <a href='https://github.com/AuroraEditor/AuroraEditor/fork'><img alt="GitHub forks" src="https://img.shields.io/github/forks/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
 </p>
 
 <br />

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

## Motivation

Developers should be able to use an editor that feels snappy and fast.

Most comparable editors are built on Electron, This is a huge disadvantage because it utilize a lot of unneccecary system resources. Electron requires a Chromium instance to run. This can mean massive performance losses and high RAM usage even for small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feels laggy. Native apps are smooth as butter and utilize system resources much more efficiently for better performance and reliability.

Xcode is a great native editor for developers on Mac, but unfortunately it doesn't support creating a multitude of projects in different programming languages, and this is where Aurora Editor comes in. Aurora Editor wants to give developers the possibility of creating their desired projects in their desired language on a editor that is native and gives a similar experience, performance and feel than that of Xcode on Mac.

## Motivation for divergence from CodeEdit

This project originates from https://github.com/CodeEditApp/CodeEdit. We decided to take our own direction with this project for several reasons:

### Rate and direction of development
We want to increase the rate of development, which means:
- Encouraging people to make PRs, even if they aren't complete (this is an issue with CodeEdit, many amazing PRs go stale or take forever).
- Making the code review cycle faster, including allowing people to merge their PRs once they have recieved enough reviews, instead of having to wait for an admin to do it. 
- Making a clearer todo so that there is never the "what to do" programmer dilemma that slows down development.
- Getting people interested in Swift. Go to [#swift-beginners](https://discord.gg/Mp5pfU6bcD) on our Discord server for help!

### Discussion
- We want to make sure that the development discussion is *always* public, not kept in locked channels, and should stay that way,
- We want everybody to feel welcome, and that every commitment to the project counts!

### Architecture
- We felt that the architecture of CodeEdit wasn't up to standard. One example is the usage of Modules, which not only increased build time but also code complexity because communication between code compoments and modules is difficult. However, CodeEdit was insistent on keeping their structure. The only way we saw the CodeEdit project could continue is if this changed. 

## Aurora Editor vs CodeEdit

When looking at the core of both code bases, there isn't much difference between AuroraEditor (AE) and CodeEdit (CE). However, we are trying to change that, for example by following a cleaner [architecture](https://github.com/AuroraEditor/AuroraEditor/wiki/Architecture). Over time, the code base between AE and CE may barely be similar to each other. 

We follow a strict set of principals when developing AE, some of which includes 
- Keeping the code as performant as possible (including build times)
- Fixing memory leaks or excessive memory usage that may hurt performance
- Making sure PRs follow AE's architecture guide closely
- The code is readable at all times and meets our expectations in regards to performance

Even if the code isn't completely up to these standards, we will work with the contributor until we have a satisfactory PR. No merge left behind!

We try to keep our code base documented as much as possible, so that any new or existing contributor who's building new features or fixing a bug can just read the documentation and instantly have an idea of what's happening.

We very much respect the contributors that contributed to CE, and we would like to thank them for giving us a base to begin with.

## Community

Join our community on [Discord](https://discord.gg/5aecJ4rq9D) or [Slack](https://join.slack.com/t/auroraeditor/shared_invite/zt-1fti1r72d-8mWmJsj279vDV~YdKhcUEA) where we discuss and collaborate on all things of Aurora Editor.
Don't be shy, jump right in and be part of the discussion!

## Community Details

We would love to hear what kind of great ideas you as the community have. If you have an idea or a feature request for Aurora Editor feel free to add it to the [Ideas Discussion](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/ideas).

If you created an awesome feature for Aurora Editor why not [Show and tell](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/show-and-tell), and celebrate with the community and developers of Aurora Editor.

When we have some awesome news or a big annoucement to make, we will be making it in the [Annoucement Discussion](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/announcements). So stay tuned for any future annoucments.

## Mental Health Awareness

We are aware how difficult and overwhelming it can be sometimes for developers when working on a big or small project. If you feel like you are getting overwhelmed when working on a certain feature or bug on Aurora Editor don't be afraid to let us know and we'll be able to help you out and takeover what you have been working on if you feel comfortable letting someone else do it. If you just feel the need to talk about certain issues feel free to talk about it in the [Mental Health Channel](https://discord.gg/HyC7Z9WaQS) or if just need advice on something ask in the [Advice Channel](https://discord.gg/Fnr5A5atbn).

## Contributing

Be part of the next revolution in code editing by contributing to the project.
This is a community-led effort, so we welcome as many contributors who can help!
Please read the following for more information.

* [What to do/add to the editor](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/development-todo)
* [Contribution Guide](https://github.com/AuroraEditor/AuroraEditor/blob/main/CONTRIBUTING.md)
* [Architecture Guide](https://github.com/AuroraEditor/AuroraEditor/wiki/Architecture)
* [Developer Guide](https://github.com/AuroraEditor/AuroraEditor/wiki/Developer-Guide)
* [Troubeshooting Guide](https://github.com/AuroraEditor/AuroraEditor/wiki/Troubleshooting)

## Contributors ✨

Thanks goes to these wonderful people:

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://wdg.codes"><img src="https://avatars.githubusercontent.com/u/1290461?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Wesley De Groot</b></sub></a><br /><a href="#infra-wdg" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/AuroraEditor/AuroraEditor/commits?author=wdg" title="Tests">⚠️</a> <a href="https://github.com/AuroraEditor/AuroraEditor/commits?author=wdg" title="Code">💻</a> <a href="#maintenance-wdg" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/nanashili"><img src="https://avatars.githubusercontent.com/u/63672227?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nanashi Li</b></sub></a><br /><a href="#infra-nanashili" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/AuroraEditor/AuroraEditor/commits?author=nanashili" title="Tests">⚠️</a> <a href="https://github.com/AuroraEditor/AuroraEditor/commits?author=nanashili" title="Code">💻</a> <a href="#maintenance-nanashili" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/KaiTheRedNinja"><img src="https://avatars.githubusercontent.com/u/88234730?v=4?s=100" width="100px;" alt=""/><br /><sub><b>KaiTheRedNinja</b></sub></a><br /><a href="https://github.com/AuroraEditor/AuroraEditor/commits?author=KaiTheRedNinja" title="Tests">⚠️</a> <a href="https://github.com/AuroraEditor/AuroraEditor/commits?author=KaiTheRedNinja" title="Code">💻</a> <a href="#maintenance-KaiTheRedNinja" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/Angelk90"><img src="https://avatars.githubusercontent.com/u/20476002?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Angelk90</b></sub></a><br /><a href="https://github.com/AuroraEditor/AuroraEditor/issues?q=author%3AAngelk90" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/AlexBurneikis"><img src="https://avatars.githubusercontent.com/u/87457198?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Burneikis</b></sub></a><br /><a href="https://github.com/AuroraEditor/AuroraEditor/issues?q=author%3AAlexBurneikis" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/Ashwonixer"><img src="https://avatars.githubusercontent.com/u/62433766?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ashwonixer</b></sub></a><br /><a href="https://github.com/AuroraEditor/AuroraEditor/issues?q=author%3AAshwonixer" title="Bug reports">🐛</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

### Intellectual Property License

The Aurora Editor Logo is copyright of AuroraEditor and Arurora Company.

### MIT License

Copyright (C) 2022 Aurora Company

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
