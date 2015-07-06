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