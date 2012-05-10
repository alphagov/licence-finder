module SectionHelper
  def selector_of_section(section_name)
    case section_name
    when /^completed question (\d+)$/
      [:xpath, "//*[contains(@class, 'done-questions')]//li[contains(@class, 'done')][.//*[contains(@class, 'question-number')][text() = '#{$1}']]"]
    when 'current question'
      [:css, '.current-question']
    when 'results'
      [:css, 'article.results']
    else
      raise "Can't find mapping from \"#{section_name}\" to a section."
    end
  end

  def within_section(section_name)
    within *selector_of_section(section_name) do
      yield
    end
  end
end

RSpec.configuration.include SectionHelper, :type => :request
