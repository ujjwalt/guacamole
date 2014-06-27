# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/callbacks'

class FakeModel
end

class FakeCallback
  include Guacamole::Callbacks
end

describe Guacamole::Callbacks do
  describe 'registering callbacks' do
    let(:model) { FakeModel.new }
    let(:callback_class) { double('CallbackClass') }
    let(:callback_instance) { double('CallbackInstance') }

    before do
      subject.register_callback model.class, callback_class
    end

    it 'should register a callback class to be used with a model class' do
      expect(subject.registry[model.class]).to eq callback_class
    end

    it 'should retrieve the callback class for a given model class' do
      allow(callback_class).to receive(:new).with(model).and_return(callback_instance)

      expect(subject.callbacks_for(model)).to eq callback_instance
    end

    context 'no callback defined for model class' do
      it 'should return the DefaultCallback' do
        any_model = double('ModelWithoutCallbacks')
        expect(subject.callbacks_for(any_model)).to be_instance_of Guacamole::Callbacks::DefaultCallback
      end
    end
  end

  describe 'building callbacks' do
    subject { FakeCallback }

    it 'should include ActiveModel::Callbacks' do
      expect(subject.ancestors).to include ActiveModel::Callbacks
    end
  end

  describe 'callback instances' do
    let(:model) { double('Model') }
    subject { FakeCallback.new model }

    it 'should provide access to the concrete model instance' do
      expect(subject.object).to eq model
    end

    it 'should run :validate callbacks' do
      expect { subject.run_callbacks :validate }.not_to raise_error
    end

    it 'should run :save callbacks' do
      expect { subject.run_callbacks :save }.not_to raise_error
    end

    it 'should run :create callbacks' do
      expect { subject.run_callbacks :create }.not_to raise_error
    end

    it 'should run :update callbacks' do
      expect { subject.run_callbacks :update }.not_to raise_error
    end

    it 'should run :destroy callbacks' do
      expect { subject.run_callbacks :destroy }.not_to raise_error
    end
  end

  describe Guacamole::Callbacks::DefaultCallback do
    subject { Guacamole::Callbacks::DefaultCallback }

    it 'should include Guacamole::Callbacks' do
      expect(subject.ancestors).to include Guacamole::Callbacks
    end
  end
end
