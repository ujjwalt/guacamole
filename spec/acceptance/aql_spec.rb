# -*- encoding : utf-8 -*-

require 'guacamole'
require 'acceptance/spec_helper'

class Pony
  include Guacamole::Model

  attribute :name, String
  attribute :color, String
  attribute :type, Array[String]
end

class PoniesCollection
  include Guacamole::Collection
end

describe 'BasicAQLSupport' do
  subject { PoniesCollection }

  let(:pegasus_pony) { Fabricate(:pony, type: ['Pegasus']) }
  let(:earth_pony) { Fabricate(:pony, type: ['Earthpony'], name: 'Candy Mane') }
  let(:unicorn_pegasus_pony) { Fabricate(:pony, type: ['Pegasus', 'Unicorn']) }

  context 'with experimental AQL support enabled' do
    before do
      Guacamole.configuration.aql_support = :experimental

      [pegasus_pony, earth_pony, unicorn_pegasus_pony]
    end

    it 'should retrieve models by simple AQL queries' do
      pony_by_name = PoniesCollection.by_aql('FILTER pony.name == @name', name: 'Candy Mane').to_a.first
      expect(pony_by_name).to eq earth_pony
    end

    it 'should retrieve models by more complex AQL queries' do
      ponies_by_type = PoniesCollection.by_aql('FILTER POSITION(pony.type, @pony_type, false) == true', pony_type: 'Pegasus').to_a
      expect(ponies_by_type).to include unicorn_pegasus_pony
      expect(ponies_by_type).to include pegasus_pony
    end
  end

  context 'without experimental AQL support enabled' do
    before do
      Guacamole.configuration.aql_support = false
    end

    it 'should raise an error accessing the AQL feature' do
      expect { PoniesCollection.by_aql("random AQL fragment") }.to raise_error(Guacamole::AQLNotSupportedError)
    end
  end

end
