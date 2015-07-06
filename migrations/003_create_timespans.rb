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

Sequel.migration do
  change do
    create_table(:timespans) do
      primary_key :id
      foreign_key :service_id, :services, null:false, index:true
      foreign_key :certificate_id, :certificates, null:false

      Time :start, null:false
      Time :end, null:false
    end
  end
end