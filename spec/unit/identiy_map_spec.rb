# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/identity_map'

describe Guacamole::IdentityMap::Session do
  context 'initialization' do
    subject { Guacamole::IdentityMap::Session }

    let(:an_app) { double('TheApp') }

    it 'should require an app object' do
      middleware = subject.new an_app

      expect(middleware.instance_variable_get('@app')).to eq an_app
    end
  end

  context 'resetting the IdentityMap' do
    let(:some_app) { double('TheApp').as_null_object }
    let(:rack_env) { double('RackEnv') }
    let(:logger)   { double('Logger').as_null_object }

    subject { Guacamole::IdentityMap::Session.new some_app }

    before do
      allow(Guacamole).to receive(:logger).and_return(logger)
    end

    it 'should reset the IdentityMap upon `call` and bypass to the @app' do
      expect(Guacamole::IdentityMap).to receive(:reset)

      subject.call rack_env
    end

    it 'should pass the request to the @app instance' do
      expect(some_app).to receive(:call).with(rack_env)

      subject.call rack_env
    end

    it 'should log the reset action as debug' do
      expect(logger).to receive(:debug).with('[SESSION] Resetting the IdentityMap')

      subject.call rack_env
    end
  end

end

describe Guacamole::IdentityMap do
  subject { Guacamole::IdentityMap }

  before do
    subject.reset
  end

  describe 'Management' do
    it 'should always return an identity_map_instance' do
      expect(subject.identity_map_instance).not_to be_nil
    end

    it 'should reset the current map' do
      expect(Hamster).to receive(:hash)

      subject.reset
      subject.identity_map_instance
    end

    context 'construct the storage key' do
      it 'should use the object' do
        some_object = double('SomeObject', key: '1337')

        expect(subject.key_for(some_object)).to eq [some_object.class, some_object.key]
      end

      it 'should construct the map key based on the class and the key' do
        some_class = double(:SomeClass)
        some_key   = '1337'

        expect(subject.key_for(some_class.class, some_key)).to eq [some_class.class, some_key]
      end
    end
  end

  describe 'Store objects' do
    let(:cupcake) { double('Cupcake', key: '42') }

    before do
      subject.reset
    end

    it 'should use the `key_for` method to construct the map key' do
      expect(subject).to receive(:key_for).with(cupcake).and_return(:the_key)

      subject.store cupcake
    end

    it 'should store the object in the map' do
      subject.store cupcake

      expect(subject.include?(cupcake)).to be true
    end

    it 'should use an immutable storage' do
      old_map = subject.identity_map_instance
      subject.store cupcake

      expect(old_map.key?(subject.key_for(cupcake))).to be false
    end

    it 'should return the stored object' do
      expect(subject.store(cupcake)).to eq cupcake
    end
  end

  describe 'Retrieve objects' do
    let(:pony) { double('Pony', key: '23') }

    before do
      subject.store pony
    end

    it 'should load the corresponding object from the map' do
      expect(subject.retrieve(pony.class, pony.key)).to eq pony
    end
  end

  describe 'Retrieve or store objects' do
    let(:rainbow) { double('Rainbow', key: 'all-the-colors') }

    it 'should store and retrieve an object in one step' do
      result = subject.retrieve_or_store(rainbow.class, rainbow.key) do
        rainbow
      end

      expect(subject.retrieve(rainbow.class, rainbow.key)).to eq result
    end
  end
end
