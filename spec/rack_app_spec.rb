# This file is part of the Ruby Certificate Notary.
# 
# The Ruby Certificate Notary is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# The Ruby Certificate Notary is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with the Ruby Certificate Notary.  If not, see <http://www.gnu.org/licenses/>.

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

  context 'when there is a timespan for the requested service and an If-Modified-Since header that matches the end of the latest timespan' do
    let!(:s) { CertificateNotary::Service.create(host:'example.com',port:'443',service_type:'2')}
    let!(:c) { s.observe_der_encoded_cert ''}

    it 'returns a 304 and enqueues a ScanServiceJob' do
      header 'If-Modified-Since', CertificateNotary::Service.find(host:'example.com',port:'443',service_type:'2').timespans.last.end.httpdate
      get '/?host=example.com'
      expect(last_response.status).to be 304
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

  context 'when an unknown service type is given' do
    it 'returns a 501' do
      get '/?host=example.com&service_type=1'
      expect(last_response.status).to be 501
    end
  end

end