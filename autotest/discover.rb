Autotest.add_discovery { "rspec2" }

imported_exceptions =  IO.readlines('.gitignore').inject([]) do |acc, line|
  acc << line.strip if line.to_s[0] != '#' && line.strip != ''; acc
end

Autotest.add_hook :initialize do |autotest|

  autotest.add_exception('.git')
  autotest.add_exception(%r{^\./Gemfile.lock})

  imported_exceptions.each do |exception|
    autotest.add_exception(exception)
  end

  false

end

