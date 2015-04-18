require_relative 'spec_helper'

describe PerspectivesNotary::XMLBuilder do

  before :all do
    #PerspectivesNotary::DB[:observations].insert(service:'www.example.com:443,2', fingerprint:'05:17:38:8a:69:6a:14:3f:62:a9:5e:86:2a:90:8b:4a', start:Time.now, end:Time.now)
  end

  it 'produces valid XML' do
    #puts PerspectivesNotary::XMLBuilder.xml_for_service('www.google.com:443,2')
  end


  after :all do
    #PerspectivesNotary::DB[:observations].delete
  end

end