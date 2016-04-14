# consumer node_1
NODE = 'node_1'.freeze
gem 'pg'
gem 'pry'

require 'pg'

conn = PG.connect(
  dbname: 'paxos_db',
  host: 'localhost',
  user: 'paxos_replication_user',
  port: '5432'
)

def identify_next_job(conn)
  conn.exec(<<-SQL).first
    SELECT job_id
    FROM jobs
    WHERE (being_worked_on_by IS NULL OR being_worked_on_by = '#{NODE}')
    AND completed IS NOT TRUE LIMIT 1
  SQL
end

def execute_job(job_id, conn)
  locked = conn.exec(<<-SQL).first
    UPDATE jobs
    SET being_worked_on_by = '#{NODE}',
        updated_at = now()
    WHERE (job_id = #{job_id}
    AND being_worked_on_by IS NULL)
    OR updated_at - created_at > '00:10:00'
    RETURNING key_to_be_incremented
  SQL

  #locked = conn.exec(<<-SQL).first
  #  SELECT key_to_be_incremented
  #  FROM jobs
  #  WHERE job_id = #{job_id}
  #  AND being_worked_on_by = '#{NODE}'
  #SQL

  if locked
    sleep(5)
    # races
    conn.exec(<<-SQL)
      WITH perform AS (
        UPDATE target_update_table
        SET value = value + 1
        FROM jobs
        WHERE target_update_table.key = #{Integer(locked['key_to_be_incremented'])}
        AND jobs.being_worked_on_by = '#{NODE}'
        RETURNING target_update_table.key
      )
      UPDATE jobs
      SET completed = TRUE,
      updated_at = now()
      FROM perform
      WHERE jobs.being_worked_on_by = '#{NODE}'
      AND job_id = #{job_id}
    SQL
    true
  else
    false
  end
end

puts "Start time: #{Time.now}"
job = identify_next_job(conn)
while (job)
  if (execute_job(job['job_id'], conn))
    puts "executed #{job['job_id']}"
  end
  job = identify_next_job(conn)
end

puts "End time: #{Time.now}"
puts "Node #{NODE} quit"
