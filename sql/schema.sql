-- Create table for daily backup job metadata
-- This table will be replicated across all client-specific databases
CREATE TABLE IF NOT EXISTS daily_jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,                  -- Unique Commvault Job ID
    client_name VARCHAR(255) NOT NULL,    -- Name of the client in Commvault
    agent_type VARCHAR(100),              -- Type of agent (e.g., Virtual Server, File System)
    status VARCHAR(50) NOT NULL,          -- Job status (Completed, Failed, Completed w/ Errors)
    start_time DATETIME,                  -- When the job started
    end_time DATETIME,                    -- When the job finished
    data_size_gb DECIMAL(10, 2),          -- Amount of data protected in GB
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of data ingestion
    UNIQUE KEY unique_job (job_id)        -- Prevent duplicate entries for the same job
);