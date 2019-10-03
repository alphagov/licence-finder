#!/usr/bin/env groovy

library("govuk")

node('elasticsearch-6.7') {
  govuk.buildProject(
    sassLint: false,
    rubyLintDiff: false,
    repoName: 'licence-finder',
    brakeman: true,
  )
}
