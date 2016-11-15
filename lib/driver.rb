require 'mysql'

class Driver

attr_reader :sites

def initialize(url)
@url = url
@sites = []
end

def find_sites
con = Mysql.new ENV["MYSQL_SERVER"], ENV["MYSQL_USER"], ENV["MYSQL_CREDS"], ENV["MYSQL_DB"]
rs = con.query("select s.url from users u join sites s on (u.id = s.owner_id) where u.id = #{@url} order by u.id desc limit 10;")
n_rows = rs.num_rows
n_rows.times do
@sites << rs.fetch_row.join("\s")
end
@sites
end


end

