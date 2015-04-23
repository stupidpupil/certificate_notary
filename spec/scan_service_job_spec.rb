require_relative 'spec_helper'

describe CertificateNotary::ScanServiceJob do
  
  before(:each) {CertificateNotary::DB[:que_jobs].delete}
  after(:all) {CertificateNotary::DB[:que_jobs].delete}

  Que.mode = :off
  describe '.enqueue_unless_exists' do
  

    context 'when called once' do
      it 'creates one job' do
        CertificateNotary::ScanServiceJob.enqueue_unless_exists 1
        expect(CertificateNotary::DB[:que_jobs].count).to be 1
      end
    end

    context 'when called twice' do

      it 'creates one job' do
        CertificateNotary::ScanServiceJob.enqueue_unless_exists 2
        CertificateNotary::ScanServiceJob.enqueue_unless_exists 2
        expect(CertificateNotary::DB[:que_jobs].count).to be 1
      end
    end

  end
end