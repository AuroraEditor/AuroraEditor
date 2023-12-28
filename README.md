<p align="center">
  <img alt="Logo" src="https://avatars.githubusercontent.com/u/106490518?s=128&v=4" width="128px;" height="128px;">
</p>

<p align="center">
  <h1 align="center">Aurora Editor</h1>
</p>

<p align="center">
  <a href='https://twitter.com/Aurora_Editor' target='_blank'>
    <img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/Aurora_Editor?color=f6579d&style=for-the-badge">
  </a>
  <a href='https://discord.gg/5aecJ4rq9D' target='_blank'>
    <img alt="Discord" src="https://img.shields.io/discord/997410333348077620?color=f98a6c&style=for-the-badge">
  </a>
  <a href='https://nightly.link/AuroraEditor/AuroraEditor/workflows/nightly/development/AuroraEditor_Nightly.zip' target='_blank'>
  <img alt="Download" src="https://img.shields.io/badge/Download-Nightly Build-6bbee8?style=for-the-badge">
 </a>
 <a href='https://twitter.com/intent/tweet?text=Try%20this%20new%20open-source%20code%20editor,%20Aurora%20Editor&url=https://auroraeditor.com&via=Aurora_Editor&hashtags=AuroraEditor,editor,AEIDE,developers,Aurora,OSS' target='_blank'><img src='https://img.shields.io/twitter/url?logo=twitter&style=for-the-badge&url=https%3A%2F%2Fauroraeditor.com'></a>
</p>

<br />

Aurora Editor is an IDE built by the community, for the community, and written in Swift for the best native performance and feel for macOS. 

It will support everything you could expect from an Xcode-inspired application, including deep integration with your selected Git provider, project planning, and your favourite built in editor tools.

<img width="1012" alt="github-banner" src="https://user-images.githubusercontent.com/63672227/187914690-2277654c-6cab-4738-b151-1c85947bea8b.jpg">

<br />

<p align="center">
  <a href='https://github.com/AuroraEditor/AuroraEditor/pulls'><img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
  <a href='https://github.com/AuroraEditor/AuroraEditor/issues'><img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge">
  <a href='https://github.com/AuroraEditor/AuroraEditor/fork'><img alt="GitHub forks" src="https://img.shields.io/github/forks/AuroraEditor/AuroraEditor?color=f98a6c&style=for-the-badge"></a>
 </p>
 
 <br />

## Motivation

Developers should be able to use an editor that feels snappy and fast.

Most comparable editors are built on Electron, this is a huge disadvantage because it utilizes a lot of unnecessary system resources. Electron requires a Chromium instance to run. This can mean massive performance losses and high RAM usage even for small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feel laggy. Native apps are smooth as butter and utilize system resources much more efficiently for better performance and reliability.

Xcode is a great native editor for developers on Mac, but unfortunately it doesn't support creating a multitude of projects in different programming languages, and this is where Aurora Editor comes in. Aurora Editor wants to give developers the possibility of creating their desired projects in their desired language on an editor that is native and gives a similar experience, performance and feel to that of Xcode on Mac.

## Included Repositories
<table>
  <tr>
    <td align="center">
      <a href="https://github.com/AuroraEditor/Version-Control-Kit">
        <img alt="Logo" src="https://user-images.githubusercontent.com/63672227/193885608-d6217c57-6a12-4470-a0c7-f1ecc80bc3f2.png" width="128">
        <p>Version Control Kit</p>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/AuroraEditor/AEExtensionKit">
      <img alt="Logo" src="https://user-images.githubusercontent.com/63672227/194052928-6c476452-3cd6-494b-9604-e1b8e1998390.png" width="128">
        <p>AE Extension Kit</p>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/migueldeicaza/SwiftTerm">
      <img alt="Logo" src="https://user-images.githubusercontent.com/63672227/194052608-65f97f2a-57fb-43a1-8b7e-46f1584a23dc.png" width="128">
        <p>SwiftTerm</p>
      </a>
    </td>
  </tr>
</table>

## Community

Join our community on [Discord](https://discord.gg/5aecJ4rq9D) or [Slack](https://join.slack.com/t/auroraeditor/shared_invite/zt-1fti1r72d-8mWmJsj279vDV~YdKhcUEA) where we discuss and collaborate on all things of Aurora Editor.

Don't be shy, jump right in and be part of the discussion!

## Community Details

We would love to hear what kind of great ideas you as the community have. If you have an idea or a feature request for Aurora Editor feel free to add it to the [Ideas Discussion](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/ideas).

If you created an awesome feature for Aurora Editor why not [Show and tell](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/show-and-tell), and celebrate with the community and developers of Aurora Editor.

When we have some awesome news or a big announcement to make, we will be making it in the [announcement Discussion](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/announcements). So stay tuned for any future announcements.

## Difference between `AuroraEditor` and `CodeEdit`

We have all contributed to CodeEdit, and some of us continue to contribute to the CE community. However, there are several notable distinctions in our approach:

1. We actively encourage the submission of smaller pull requests (PRs), even if they are not flawless. Our rationale is that this approach can expedite the project development.

2. We have adopted a different syntax highlighting engine. Our decision is based on the belief that Tree-sitter's parsing speed may not be sufficient, especially during the initial parsing stages.

3. We have streamlined the project by removing a significant number of modules that frequently encountered fetch failures and required additional instructions for users.

4. Our primary focus lies on functionality rather than aesthetics. While CodeEdit emphasizes creating visually appealing designs, our primary goal is to ensure that the system functions correctly. Design refinements are considered once functionality is achieved.

5. Some of us have experienced situations where our ideas were initially deemed unsuitable. However, it has come to our attention that these ideas were eventually implemented weeks later due to an admin's suggestion.

These are some of the key differences in our approach to CodeEdit, aimed at enhancing project development and efficiency.

Based of the following answer from <a href='https://github.com/0xWDG'>@0xWDG</a> in <a href='https://github.com/AuroraEditor/AuroraEditor/discussions/286'>Discussion#286</a>.

## Mental Health Awareness

We are aware of how difficult and overwhelming it can be sometimes for developers when working on a big or small project. If you feel like you are getting overwhelmed when working on a certain feature or bug on Aurora Editor don't be afraid to let us know and we'll be able to help you out and take over what you have been working on if you feel comfortable letting someone else do it. If you just feel the need to talk about certain issues feel free to talk about it in the [Mental Health Channel](https://discord.gg/HyC7Z9WaQS) or if just need advice on something ask in the [Advice Channel](https://discord.gg/Fnr5A5atbn).

## Contributing

Be part of the next revolution in code editing by contributing to the project.
This is a community-led effort, so we welcome as many contributors who can help!
Please read the following for more information.

* [What to do/add to the editor](https://github.com/AuroraEditor/AuroraEditor/discussions/categories/development-todo)
* [Contribution Guide](https://github.com/AuroraEditor/AuroraEditor/blob/main/CONTRIBUTING.md)
* [Architecture Guide](https://github.com/AuroraEditor/AuroraEditor/wiki/Architecture)
* [Developer Guide](https://github.com/AuroraEditor/AuroraEditor/wiki/Developer-Guide)
* [Troubleshooting Guide](https://github.com/AuroraEditor/AuroraEditor/wiki/Troubleshooting)

## Editor Localization

We want users to feel comfortable using Aurora Editor in their own speaking language, help us by translating Aurora Editor for you and the rest of the community.

[Translate Aurora Editor Now](https://app.lokalise.com/public/8719853963cfc24a9bfba9.04156986/)

## Contributors ✨

[Thanks goes to these wonderful people](http://auroraeditor.com/#contributors)

<!-- AEB-Contributors-Start -->
<!-- AEB-Contributors-End -->

## Sponsors

<a title="MacStadium" href="https://macstadium.com" target="_blank"><img src="https://user-images.githubusercontent.com/806104/162766594-eff7f985-31a9-48c5-9e58-139794fefa10.png" width="128"></a>
<a title="Lokalise" href="https://lokalise.com" target="_blank"><img src="https://user-images.githubusercontent.com/63672227/214901959-62aa13a7-8d85-44c9-abd0-7d9dc21d7255.png" width="128"></a>
<a href="https://sentry.io" title="Sentry">
  <picture>
    <source alt="Sentry" href="https://sentry.io" media="(prefers-color-scheme: dark)" srcset="https://github.com/AuroraEditor/AuroraEditor/assets/63672227/59a48bf3-5c3f-4904-9b1c-982bcf89fc5f" width="128">
    <img alt="Sentry" href="https://sentry.io" src="https://github.com/AuroraEditor/AuroraEditor/assets/63672227/cccf2fd4-7cfe-4ace-bb84-13557794f93c" width="128">
  </picture>
</a>
<a title="Screen Studio" href="https://www.screen.studio" target="_blank"><img src="https://github.com/AuroraEditor/AuroraEditor/assets/63672227/99ac2fb5-d341-430e-bdf4-63278286f562" width="128"></a>
[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%203.svg)](https://www.digitalocean.com/?refcode=d68c5c8d2ac1&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)


## Intellectual Property License

The Aurora Editor Logo is copyrighted by AuroraEditor and Aurora Company.

## Socials

<a href="https://www.producthunt.com/posts/aurora-editor?utm_source=badge-featured&amp;utm_medium=badge&amp;utm_souce=badge-aurora-editor">
<img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=372771&amp;theme=light" alt="AuroraEditor | Product Hunt">
</a>

## Stars flow
[![Star History Chart](https://api.star-history.com/svg?repos=auroraeditor/auroraeditor&type=Timeline)](https://star-history.com/#auroraeditor/auroraeditor&Timeline)
