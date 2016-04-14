DROP TABLE jobs CASCADE;
DROP TABLE target_update_table;
CREATE TABLE jobs(job_id SERIAL PRIMARY KEY, key_to_be_incremented INTEGER NOT NULL, being_worked_on_by TEXT, completed BOOLEAN DEFAULT FALSE , created_at TIMESTAMP, updated_at TIMESTAMP);
CREATE TABLE target_update_table(key INTEGER PRIMARY KEY, value INTEGER);

SELECT paxos_join_group('cron', 'host=localhost port=5432', 'host=localhost port=5434');
