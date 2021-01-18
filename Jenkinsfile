#!/usr/bin/env groovy

library("govuk")

node('elasticsearch-6.7 && mongodb-2.4') {
  govuk.buildProject(
    repoName: 'licence-finder',
    brakeman: true,
  )
}
