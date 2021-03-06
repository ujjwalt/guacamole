# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/document_model_mapper'

class FancyModel
end

class FakeIdentityMap
  class << self
    def retrieve_or_store(*args, &block)
      block.call
    end
  end
end

describe Guacamole::DocumentModelMapper do
  subject { Guacamole::DocumentModelMapper }

  it 'should be initialized with a model class' do
    mapper = subject.new FancyModel, FakeIdentityMap
    expect(mapper.model_class).to eq FancyModel
  end

  describe 'document_to_model' do
    subject { Guacamole::DocumentModelMapper.new FancyModel, FakeIdentityMap }

    let(:document)            { double('Ashikawa::Core::Document') }
    let(:document_attributes) { double('Hash') }
    let(:model_instance)      { double('ModelInstance').as_null_object }
    let(:some_key)            { double('Key') }
    let(:some_rev)            { double('Rev') }

    before do
      allow(subject.model_class).to receive(:new).and_return(model_instance)
      allow(document).to receive(:to_h).and_return(document_attributes)
      allow(document).to receive(:key).and_return(some_key)
      allow(document).to receive(:revision).and_return(some_rev)
    end

    it 'should create a new model instance from an Ashikawa::Core::Document' do
      expect(subject.model_class).to receive(:new).with(document_attributes)

      model = subject.document_to_model document
      expect(model).to eq model_instance
    end

    it 'should set the rev and key on a new model instance' do
      expect(model_instance).to receive(:key=).with(some_key)
      expect(model_instance).to receive(:rev=).with(some_rev)

      subject.document_to_model document
    end

    context 'with referenced_by models' do
      let(:referenced_by_model_name)   { :cupcakes }
      let(:referenced_by_models)       { [referenced_by_model_name] }
      let(:association_proxy)          { Guacamole::Proxies::ReferencedBy }
      let(:association_proxy_instance) { double('AssociationProxy') }

      before do
        allow(subject).to receive(:referenced_by_models).and_return referenced_by_models
        allow(association_proxy).to receive(:new)
          .with(referenced_by_model_name, model_instance)
          .and_return(association_proxy_instance)
      end

      it 'should initialize the association proxy with referenced_by model and its name' do
        expect(association_proxy).to receive(:new)
          .with(referenced_by_model_name, model_instance)
          .and_return(association_proxy_instance)

        subject.document_to_model document
      end

      it 'should set an association proxy' do
        expect(model_instance).to receive("#{referenced_by_model_name}=").with(association_proxy_instance)

        subject.document_to_model document
      end
    end

    context 'with referenced models' do
      let(:referenced_model_name)      { :pony }
      let(:referenced_models)          { [referenced_model_name] }
      let(:association_proxy)          { Guacamole::Proxies::References }
      let(:association_proxy_instance) { double('AssociationProxy') }

      before do
        allow(subject).to receive(:referenced_models).and_return referenced_models
        allow(association_proxy).to receive(:new)
          .with(referenced_model_name, document)
          .and_return(association_proxy_instance)
      end

      it 'should initialize the association proxy with the document and the referenced model name' do
        expect(association_proxy).to receive(:new)
          .with(referenced_model_name, document)
          .and_return(association_proxy_instance)

        subject.document_to_model document
      end

      it 'should set an association proxy' do
        expect(model_instance).to receive("#{referenced_model_name}=").with(association_proxy_instance)

        subject.document_to_model document
      end
    end

    context 'with embedded ponies' do
      # This is handled by Virtus, we just need to provide a hash
      # and the coercing will be taken care of by Virtus
    end
  end

  describe 'model_to_document' do
    subject { Guacamole::DocumentModelMapper.new FancyModel, FakeIdentityMap }

    let(:model)            { double('Model') }
    let(:model_attributes) { double('Hash').as_null_object }

    before do
      allow(model).to receive(:attributes).and_return(model_attributes)
      allow(model_attributes).to receive(:dup).and_return(model_attributes)
    end

    it 'should transform a model into a simple hash' do
      expect(subject.model_to_document(model)).to eq model_attributes
    end

    it 'should return a copy of the model attributes hash' do
      expect(model_attributes).to receive(:dup).and_return(model_attributes)

      subject.model_to_document(model)
    end

    it 'should remove the key and rev attributes from the document' do
      expect(model_attributes).to receive(:except).with(:key, :rev)

      subject.model_to_document(model)
    end

    context 'with embedded ponies' do
      let(:somepony) { double('Pony') }
      let(:pony_array) { [somepony] }
      let(:ponylicious_attributes) { double('Hash').as_null_object }

      before do
        subject.embeds :ponies

        allow(model).to receive(:ponies)
          .and_return pony_array

        allow(somepony).to receive(:attributes)
          .and_return ponylicious_attributes
      end

      it 'should convert all embedded ponies to pony hashes' do
        expect(somepony).to receive(:attributes)
          .and_return ponylicious_attributes

        subject.model_to_document(model)
      end

      it 'should exclude key and rev on embedded ponies' do
        expect(ponylicious_attributes).to receive(:except)
          .with(:key, :rev)

        subject.model_to_document(model)
      end
    end

    context 'with referenced_by models' do
      let(:referenced_by_model_name) { :cupcakes }
      let(:referenced_by_models)     { [referenced_by_model_name] }

      before do
        allow(subject).to receive(:referenced_by_models).and_return referenced_by_models
      end

      it 'should remove the referenced_by attribute from the document' do
        expect(model_attributes).to receive(:delete).with(referenced_by_model_name)

        subject.model_to_document(model)
      end
    end

    context 'with referenced models' do
      let(:referenced_model)       { double('ReferencedModel', key: 23) }
      let(:referenced_model_name)  { :pony }
      let(:referenced_models)      { [referenced_model_name] }

      before do
        allow(subject).to receive(:referenced_models).and_return referenced_models
        allow(model).to receive(:send).with(referenced_model_name).and_return referenced_model
      end

      it 'should remove the referenced attribute from the document' do
        expect(model_attributes).to receive(:delete).with(referenced_model_name)

        subject.model_to_document(model)
      end

      it 'should add the key of the referenced model to the document' do
        expect(model_attributes).to receive(:[]=).with(:"#{referenced_model_name}_id", referenced_model.key)

        subject.model_to_document(model)
      end
    end
  end

  describe 'embed' do
    subject { Guacamole::DocumentModelMapper.new FancyModel, FakeIdentityMap }

    it 'should remember which models to embed' do
      subject.embeds :ponies

      expect(subject.models_to_embed).to include :ponies
    end
  end

  describe 'referenced_by' do
    subject { Guacamole::DocumentModelMapper.new FancyModel, FakeIdentityMap }

    it 'should remember which models holding references' do
      subject.referenced_by :ponies

      expect(subject.referenced_by_models).to include :ponies
    end
  end

  describe 'references' do
    subject { Guacamole::DocumentModelMapper.new FancyModel, FakeIdentityMap }

    it 'should remember which models are referenced' do
      subject.references :pony

      expect(subject.referenced_models).to include :pony
    end
  end
end
