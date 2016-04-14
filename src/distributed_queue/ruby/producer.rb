gem 'pg'

require 'pg'

conn = PG.connect(
  dbname: 'paxos_db',
  host: 'localhost',
  user: 'paxos_replication_user',
  port: '5432'
)

def queue_job(key, conn)
  conn.exec(<<-SQL).first['job_id']
    INSERT INTO jobs(key_to_be_incremented, created_at, updated_at)
    VALUES (#{key}, now(), now())
    RETURNING job_id
  SQL
end

# create 10 KV pairs

conn.exec('insert into target_update_table(key, value) select r, 0 from generate_series(1,10) r')

puts "Start time: #{Time.now}"
# queue jobs to increment all keys to 10
conn.exec('select key from target_update_table').each do |result|
  for i in (1..10)
    queue_job(Integer(result['key']), conn)
  end
end
puts "End time: #{Time.now}"
