#!/usr/bin/env groovy

library("govuk")

node {

  govuk.buildProject(
    sassLint: false,
    rubyLintDiff: false,
    repoName: 'licence-finder',
    brakeman: true,
  )
}
