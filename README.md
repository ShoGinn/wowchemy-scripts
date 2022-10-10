# HUGO boilerplate / Wowchemy Theme Emphasis / Netlify Builds

## What it does

This is a collection of helper scripts as well as github workflows to support HUGO builds for Netlify deployment

## Requirements

This requires that you are running a POSIX operating system which includes Linux/macOS sorry Windows.

## How do I install it?

To install the entire setup and fully integrate it just copy and paste the code below.

For a fully list of what this does goto [What does this actually install?](#what-does-this-actually-install)

```sh
curl -fsSL https://raw.githubusercontent.com/ShoGinn/wowchemy-scripts/main/install.sh | bash
```

## What does this actually install?

The folder structure is as follows:

```generic
📦shoginn_scripts
 ┣ 📂.github
 ┃ ┗ 📂workflows
 ┃ ┃ ┣ 📜html_proof.yml
 ┃ ┃ ┣ 📜release.yml
 ┃ ┃ ┗ 📜update_netlify.yml
 ┗ 📂bin
 ┃ ┣ 📂build
 ┃ ┃ ┗ 📜hugo.sh
 ┃ ┣ 📂etc
 ┃ ┃ ┣ 📜.env.sample
 ┃ ┃ ┣ 📜.netlify.template
 ┃ ┃ ┗ 📜.replacements.template
 ┃ ┣ 📂functions
 ┃ ┃ ┗ 📜shoginn_scripts.sh
 ┃ ┣ 📂lib
 ┃ ┃ ┗ 📜.gitkeep
 ┃ ┣ 📂netlify
 ┃ ┃ ┗ 📜update_hugo_version.sh
 ┃ ┗ 📜setup.sh
 ```
