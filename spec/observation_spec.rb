require_relative 'spec_helper'

describe "PerspectivesNotary::Observation#observe_fingerprint" do

  context 'when the fingerprint matches the most recent observation' do

    offset = 30

    s = PerspectivesNotary::Service.find_or_create(host:'service', port:'443', service_type:2)
    obs = PerspectivesNotary::Observation.create(service:s, fingerprint:'fingerprint', start:Time.now-offset, end:Time.now-offset)
    PerspectivesNotary::Observation.observe_fingerprint(s,'fingerprint')

    it 'updates the most recent observation' do
      expect(PerspectivesNotary::Observation.find(id:obs.id).end).to be > obs.end
      expect(PerspectivesNotary::Observation.where(service:s).last.id).to be obs.id
    end
  end

  context 'when the fingerprint matches the most recent observation, but the observation is not very recent' do

    s = PerspectivesNotary::Service.find_or_create(host:'service', port:'443', service_type:2)
    offset = PerspectivesNotary::Config.observation_update_limit+120
    obs = PerspectivesNotary::Observation.create(service:s, fingerprint:'fingerprint', start:Time.now-offset, end:Time.now-offset)
    PerspectivesNotary::Observation.observe_fingerprint(s,'fingerprint')

    it 'creates a new observation' do
      expect(PerspectivesNotary::Observation.where(service:s).last.id).not_to be obs.id
    end
  end

  context "when the fingerprint doesn't match the most recent observation" do
    
    offset = 30
    s = PerspectivesNotary::Service.find_or_create(host:'service', port:'443', service_type:2)
    obs = PerspectivesNotary::Observation.create(service:s, fingerprint:'fungerprunt', start:Time.now-offset, end:Time.now-offset)
    PerspectivesNotary::Observation.observe_fingerprint(s,'fingerprint')

    it 'creates a new observation' do
      expect(PerspectivesNotary::Observation.where(service:s).last.id).not_to be obs.id
    end

  end 

end