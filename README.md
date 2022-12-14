# HUGO boilerplate / Wowchemy Theme Emphasis / Netlify Builds

## What it does

A collection of helper scripts and GitHub workflows to support HUGO builds for Netlify deployment.

## Requirements

A POSIX operating system which includes Linux/macOS, sorry, Windows.

## How do I install it?

To install the entire setup and fully integrate it copy and paste the code below.

For a full list of what this does, go to [What does this install?](#what-does-this-install)

```sh
curl -fsSL https://raw.githubusercontent.com/ShoGinn/wowchemy-scripts/main/install.sh | bash
```

## What does this install?

The folder structure is as follows:

```generic
๐ฆshoginn_scripts
 โ ๐bin
 โ โฃ ๐build
 โ โ โ ๐hugo.sh
 โ โฃ ๐etc
 โ โ โฃ ๐.env.sample
 โ โ โฃ ๐.netlify.template
 โ โ โ ๐.replacements.template
 โ โฃ ๐functions
 โ โ โ ๐shoginn_scripts.sh
 โ โฃ ๐lib
 โ โ โ ๐.gitkeep
 โ โฃ ๐netlify
 โ โ โ ๐update_hugo_version.sh
 โ โ ๐setup.sh
 ```

During the install, it creates the folder structure above; it then provides you the option to `CTRL-C` and not run the setup.sh

### Setup.sh does what?

The setup file uses `NODE` (npm) and creates some shortcuts necessary to build your HUGO project and serve it locally.

### What are the workflows?

The Workflows are there to prove the HTML from your build and if that passes then checks your git commits using the Google release-please action to create a version automatically

> WARNING: **THEY ARE NOT AUTOMATICALLY UPDATED!**

If this is an important feature please check the release notes.
