source "https://rubygems.org"
gemspec

# To support older versions, keep back some gems
if RUBY_VERSION < '2.0.0'
  gem 'tins', '< 1.7.0'
end

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'rake', '~> 10.3'
  gem 'rspec', '~> 3.1'
  gem 'coveralls', '~> 0.7'
end

