# -*- encoding : utf-8 -*-

require 'guacamole'
require 'acceptance/spec_helper'

class SecurePony
  include Guacamole::Model

  attribute :name, String
  attribute :token, String
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

  before_create   :hash_password
  before_validate :generate_token

  def hash_password
    object.hashed_password = Digest::SHA1.hexdigest object.password
  end

  def generate_token
    object.token = SecureRandom.hex
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

  describe 'validate callbacks' do
    it 'should fire the before validate callback' do
      pinkie_pie = SecurePony.new name: 'Pinkie Pie', password: 'cupcakes'

      pinkie_pie.valid?

      expect(pinkie_pie.token).not_to be_nil
    end
  end
end
