# -*- encoding : utf-8 -*-

require 'guacamole'
require 'acceptance/spec_helper'

class SecurePonyCallbacks
  include Guacamole::Callbacks

  # Those will be triggered by the collection
  before_create :hash_password
  after_create  :throw_welcome_party
  around_create :log_create_time

  # Those will be triggered by the model
  before_validate :generate_token
  after_validate  :remove_safety_switch
  around_validate :log_validate_time

  def hash_password
    object.hashed_password = Digest::SHA1.hexdigest object.password
  end

  def throw_welcome_party
    Party.throw!
  end

  def log_create_time
    TimingLogger.log_time 'before_create'
    yield
    TimingLogger.log_time 'after_create'
  end

  def generate_token
    object.token = SecureRandom.hex
  end

  def remove_safety_switch
    object.safety_switch = :removed
  end

  def log_validate_time
    TimingLogger.log_time 'before_validate'
    yield
    TimingLogger.log_time 'after_validate'
  end
end

class SecurePony
  include Guacamole::Model

  callbacks :secure_pony_callbacks

  attribute :name, String
  attribute :token, String
  attribute :hashed_password, String

  # define a virtual attribute
  attr_accessor :password, :safety_switch
end

class SecurePoniesCollection
  include Guacamole::Collection
end

class Party
  def self.throw!; end
end

class TimingLogger
  def self.log_time(*args); end
end

describe 'CallbacksSpec' do
  subject { SecurePonyCallbacks }

  let(:pinkie_pie) { SecurePony.new name: 'Pinkie Pie', password: 'cupcakes' }

  before do
    allow(TimingLogger).to receive(:log_time)
  end

  describe 'collection based callbacks' do
    let(:collection) { SecurePoniesCollection }

    it 'should fire the before create callback' do
      collection.save pinkie_pie

      expect(pinkie_pie.hashed_password).to eq Digest::SHA1.hexdigest pinkie_pie.password
    end

    it 'should fire the after create callback' do
      expect(Party).to receive(:throw!)

      collection.save pinkie_pie
    end

    it 'should fire the around create callback' do
      expect(TimingLogger).to receive(:log_time).with('before_create')
      expect(TimingLogger).to receive(:log_time).with('after_create')

      collection.save pinkie_pie
    end
  end

  describe 'model based callbacks' do
    it 'should fire the before validate callback' do
      pinkie_pie.valid?

      expect(pinkie_pie.token).not_to be_nil
    end

    it 'should fire the after validate callback' do
      pinkie_pie.valid?

      expect(pinkie_pie.safety_switch).to be_truthy
    end

    it 'should fire the around validate callback' do
      expect(TimingLogger).to receive(:log_time).with('before_validate')
      expect(TimingLogger).to receive(:log_time).with('after_validate')

      pinkie_pie.valid?
    end
  end
end
