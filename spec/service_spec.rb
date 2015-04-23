require_relative 'spec_helper'

describe CertificateNotary::Service do

  describe '#observe_der_encoded_cert' do

    let(:s) { CertificateNotary::Service.create(host:'example.com',port:'443',service_type:'2')}

    after(:each) do
      CertificateNotary::Timespan.dataset.delete 
      CertificateNotary::Certificate.dataset.delete 
      CertificateNotary::Service.dataset.delete 
    end


    context 'when called with nil' do

      before {s.observe_der_encoded_cert nil}

      it "doesn't create a new timespan" do
        expect(s.timespans.none?).to be true
      end
    end

    context 'when called with a string' do


      context 'with an existing recent timespan' do
        let!(:t){CertificateNotary::Timespan.create(service:s, certificate:CertificateNotary::Certificate.with_der_encoded_cert(''), start:Time.now-10, end:Time.now-5)}

        before {s.observe_der_encoded_cert ''}

        it 'updates the existing timespan' do
          expect(s.timespans.last.end).to be_within(1).of(Time.now)
          expect(s.timespans.count).to eql 1
          expect(s.timespans.last.id).to be t.id
        end
      end

      context 'with an existing recent timespan for a different certificate' do
        let!(:t){CertificateNotary::Timespan.create(service:s, certificate:CertificateNotary::Certificate.with_der_encoded_cert('1'), start:Time.now-10, end:Time.now-5)}

        before {s.observe_der_encoded_cert ''}

        it 'creates a new timespan' do
          expect(s.timespans.count).to eql 2
          expect(s.timespans.last.end).to be_within(2).of(Time.now)
          expect(s.timespans.last.id).to_not be t.id
        end        
      end

      context 'with an existing distant timespan' do
        let!(:t){CertificateNotary::Timespan.create(service:s, certificate:CertificateNotary::Certificate.with_der_encoded_cert(''), start:Time.at(0), end:Time.at(5))}

        before {s.observe_der_encoded_cert ''}

        it 'creates a new timespan' do
          expect(s.timespans.count).to eql 2
          expect(s.timespans.last.end).to be_within(2).of(Time.now)
          expect(s.timespans.last.id).to_not be t.id
        end

      end

      context 'with no existing timespans' do

        before {s.observe_der_encoded_cert ''}

        it 'creates a new timespan' do
          expect(s.timespans.count).to eql 1
          expect(s.timespans.last.end).to be_within(1).of(Time.now)
        end
      end

    end

  end

end