desc "Linting"
task lint: :environment do
  sh "bundle exec rubocop --format clang"
end
