def symbolize_recursively! hash
  if hash.is_a? Hash
    hash.symbolize_keys!
    hash.values.each{ |v| symbolize_recursively! v }
  end
  hash
end

$GLOBAL = symbolize_recursively! YAML.load_file(Rails.root.join('config', 'config.global.yml'))
