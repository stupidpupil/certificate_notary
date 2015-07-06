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

$:<<'lib'

require 'rack-server-pages'
require 'certificate_notary'


class NotaryApp

  def call(env)
    req = Rack::Request.new(env)
    return Rack::ServerPages.call(env) if req.params.empty?
    return CertificateNotary::PerspectivesAPI::RackApp.call(env)
  end

end

run NotaryApp.new