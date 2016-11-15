RSpec::Matchers.define :match_xml do |expected|
  match do |actual|
    clean_xml(expected) == clean_xml(actual)
  end

  def clean_xml(str)
    str.split("\n").map(&:strip).join('')
  end
end
