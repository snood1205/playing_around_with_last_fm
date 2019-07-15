def example
  raise 'hello'
ensure
  puts 'this better be hit'
end

example
