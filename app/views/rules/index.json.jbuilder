json.array!(@rules) do |rule|
  json.extract! rule, :id, :master, :user_id, :url, :expression
  json.url rule_url(rule, format: :json)
end
