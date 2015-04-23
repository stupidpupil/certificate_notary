require_relative 'spec_helper'
require 'rack/test'

describe CertificateNotary::PerspectivesAPI::RackApp do

  include Rack::Test::Methods
  Que.mode = :off

  before(:each) do
    CertificateNotary::DB[:que_jobs].delete
    CertificateNotary::Timespan.dataset.delete 
    CertificateNotary::Certificate.dataset.delete 
    CertificateNotary::Service.dataset.delete 
  end

  after(:all) do
    CertificateNotary::DB[:que_jobs].delete
    CertificateNotary::Timespan.dataset.delete 
    CertificateNotary::Certificate.dataset.delete 
    CertificateNotary::Service.dataset.delete 
  end

  let(:app){CertificateNotary::PerspectivesAPI::RackApp}

  context 'when there are no records for the request service' do
    it "returns a 404 and enqueues a ScanServiceJob" do
      get '/?host=example.com'
      expect(last_response.status).to be 404
      expect(CertificateNotary::DB[:que_jobs].where(:job_class => "CertificateNotary::ScanServiceJob").count).to be 1
    end
  end

  context 'when there is a timespan for the requested service' do
    let!(:s) { CertificateNotary::Service.create(host:'example.com',port:'443',service_type:'2')}
    let!(:c) { s.observe_der_encoded_cert ''}
    it "returns a 200 and enqueues a ScanServiceJob" do
      get '/?host=example.com'
      expect(last_response.status).to be 200
      expect(CertificateNotary::DB[:que_jobs].where(:job_class => "CertificateNotary::ScanServiceJob").count).to be 1
    end
  end

  context 'when no host is given' do
    it 'returns a 400' do
      get '/'
      expect(last_response.status).to be 400
    end
  end

  context 'when an unexpected parameter is given' do
    it 'returns a 400' do
      get '/?unexpected_parameter'
      expect(last_response.status).to be 400
    end
  end

end