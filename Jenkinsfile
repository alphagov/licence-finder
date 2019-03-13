#!/usr/bin/env groovy

library("govuk")

node('elasticsearch-5.6') {
  govuk.buildProject(
    sassLint: false,
    rubyLintDiff: false,
    repoName: 'licence-finder',
    brakeman: true,
  )
}
