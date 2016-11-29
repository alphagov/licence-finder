APPLICATION_METADATA = {
  slug: APP_SLUG,
  content_id: "69af22e0-da49-4810-9ee4-22b4666ac627",
  title: "Licence Finder",
  description: "Find out which licences you might need for your activity or business.",
  section: "business",

  # Sending an empty array for `paths` and `prefixes` will make sure we don't
  # register routes in Panopticon.
  paths: [],
  prefixes: [],

  indexable_content: <<-HEREDOC.gsub(/\s+/, " ").strip,
    Find out which licences you might need for your
    activity or business, including temporary events notice, occasional licence,
    skip licence, and food premises registration.
  HEREDOC
  state: "live"
}
