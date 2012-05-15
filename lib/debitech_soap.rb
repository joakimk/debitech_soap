module DebitechSoap
  # It takes a little while to load, so don't load it when rails loads.
  autoload :API, File.expand_path(File.join(File.dirname(__FILE__), 'debitech_soap/api'))
end
