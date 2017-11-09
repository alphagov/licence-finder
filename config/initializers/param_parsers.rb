# Turn off XML parsing:
# https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
ActionDispatch::Request.parameter_parsers.delete(:xml)
ActionDispatch::Request.parameter_parsers.delete(:json)
