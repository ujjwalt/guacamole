# -*- encoding : utf-8 -*-

require 'guacamole'
require 'acceptance/spec_helper'

class SecurePony
  include Guacamole::Model

  attribute :name, String
  attribute :hashed_password, String

  # define a virtual attribute
  attr_accessor :password
end

class SecurePoniesCollection
  include Guacamole::Collection
end

class SecurePonyCallbacks
  include Guacamole::Callbacks

  around :secure_pony

  before_create :hash_password

  def hash_password
    object.hashed_password = Digest::SHA1.hexdigest object.password
  end
end

describe 'CallbacksSpec' do
  describe 'create callbacks' do
    subject { SecurePoniesCollection }

    it 'should fire the before create callback' do
      pinkie_pie = SecurePony.new name: 'Pinkie Pie', password: 'cupcakes'

      subject.save pinkie_pie

      expect(pinkie_pie.hashed_password).to eq Digest::SHA1.hexdigest pinkie_pie.password
    end
  end
end
