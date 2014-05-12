# -*- encoding: utf-8 -*-

class Book
  extend ActiveSupport::Autoload
  include Guacamole::Model

  autoload :Author, 'fabricators/author'

  attribute :title, String
  attribute :author, Author
end
