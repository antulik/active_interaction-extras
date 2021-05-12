
# Copied from Anyway config gem
module TestingHelpers
  # Sets the ENV variables to the provided
  # values and restore outside the block
  #
  # Also resets Anyway.env before and after calling the block
  # to make sure that the values are not cached.
  #
  # NOTE: to remove the env value, pass `nil` as the value
  def with_env(data)
    was_values = []

    data.each do |key, val|
      was_values << [key, ENV[key]]
      next ENV.delete(key) if val.nil?
      ENV[key] = val
    end

    yield
  ensure
    was_values.each do |(key, val)|
      next ENV.delete(key) if val.nil?
      ENV[key] = val
    end
  end
end
