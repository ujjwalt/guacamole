# -*- encoding: utf-8 -*-

Fabricator(:pony) do
  name  { Faker::Name.name }
  color { %w(purple pink blue yellow green white).sample }
  type  { %w(Pegasus Earthpony Unicorn).sample }
end
