# -*- encoding : utf-8 -*-

require 'guacamole'
require 'acceptance/spec_helper'

require 'bcrypt'

class SecurePonyCallbacks
  include Guacamole::Callbacks

  # Those will be triggered by the collection
  before_create :encrypt_password
  after_create  :throw_welcome_party
  around_create :log_create_time

  # Those will be triggered by the model
  before_validate :generate_token
  after_validate  :remove_safety_switch
  around_validate :log_validate_time

  def encrypt_password
    object.encrypted_password = BCrypt::Password.create(object.password)
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
  attribute :encrypted_password, String

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

      expect(BCrypt::Password.new(pinkie_pie.encrypted_password)).to eq pinkie_pie.password
    end

    it 'should fire the after create callback' do
      expect(Party).to receive(:throw!)

      collection.save pinkie_pie
    end

    it 'should fire the around create callback' do
      expect(TimingLogger).to receive(:log_time).with('before_create').ordered
      expect(TimingLogger).to receive(:log_time).with('after_create').ordered

      collection.save pinkie_pie
    end

    context 'fill time stamp attributes' do
      let(:past) { 'Oct 26 1955 01:21'.to_datetime }
      let(:now)  { 'Oct 26 1985 01:21'.to_datetime }

      it 'should fill created_at and updated_at on create' do
        Timecop.freeze(now) do
          collection.save pinkie_pie
        end

        expect(pinkie_pie.created_at).to eq now
        expect(pinkie_pie.updated_at).to eq now
      end

      it 'should update updated_at on update' do
        collection.save pinkie_pie
        pinkie_pie.name = 'Pinkie Pie - Updated'

        Timecop.freeze(now) do
          collection.save pinkie_pie
        end

        expect(pinkie_pie.updated_at).to eq now
      end

      context 'with the default callback' do
        let(:pinkie_pie) { Fabricate.build(:pony, name: 'Pinkie Pie') }
        let(:collection) { PoniesCollection }

        it 'should fill created_at and updated_at on create' do
          Timecop.freeze(now) do
            collection.save pinkie_pie
          end

          expect(pinkie_pie.created_at).to eq now
          expect(pinkie_pie.updated_at).to eq now
        end

        it 'should update updated_at on update' do
          Timecop.freeze(past) do
            collection.save pinkie_pie
          end

          pinkie_pie.color = 'pink'

          Timecop.freeze(now) do
            collection.save pinkie_pie
          end

          expect(pinkie_pie.created_at).to eq past
          expect(pinkie_pie.updated_at).to eq now
        end
      end
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
