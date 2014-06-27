# -*- encoding: utf-8 -*-

class Pony
  include Guacamole::Model

  attribute :name, String
  attribute :color, String
  attribute :type, Array[String]
end
