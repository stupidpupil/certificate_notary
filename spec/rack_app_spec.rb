require_relative 'spec_helper'
require 'rack/test'

describe PerspectivesNotary::PerspectivesAPI::RackApp do

  include Rack::Test::Methods
  Que.mode = :off

  before(:each) do
    PerspectivesNotary::DB[:que_jobs].delete
    PerspectivesNotary::Timespan.dataset.delete 
    PerspectivesNotary::Certificate.dataset.delete 
    PerspectivesNotary::Service.dataset.delete 
  end

  after(:all) do
    PerspectivesNotary::DB[:que_jobs].delete
    PerspectivesNotary::Timespan.dataset.delete 
    PerspectivesNotary::Certificate.dataset.delete 
    PerspectivesNotary::Service.dataset.delete 
  end

  let(:app){PerspectivesNotary::PerspectivesAPI::RackApp.new}

  context 'when there are no records for the request service' do
    it "returns a 404 and enqueues a ScanServiceJob" do
      get '/?host=example.com'
      expect(last_response.status).to be 404
      expect(PerspectivesNotary::DB[:que_jobs].where(:job_class => "PerspectivesNotary::ScanServiceJob").count).to be 1
    end
  end

  context 'when there is a timespan for the requested service' do
    let!(:s) { PerspectivesNotary::Service.create(host:'example.com',port:'443',service_type:'2')}
    let!(:c) { s.observe_der_encoded_cert ''}
    it "returns a 200 and enqueues a ScanServiceJob" do
      get '/?host=example.com'
      expect(last_response.status).to be 200
      expect(PerspectivesNotary::DB[:que_jobs].where(:job_class => "PerspectivesNotary::ScanServiceJob").count).to be 1
    end
  end

end