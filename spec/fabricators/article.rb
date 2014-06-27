# -*- encoding: utf-8 -*-

require 'fabricators/comment'

class Article
  include Guacamole::Model

  attribute :title, String
  attribute :comments, Array[Comment]

  validates :title, presence: true
end
