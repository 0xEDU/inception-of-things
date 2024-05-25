FROM gitlab/gitlab-ce:latest

# Copy GitLab configuration and data
COPY config /etc/gitlab
COPY logs /var/log/gitlab
COPY data /var/opt/gitlab
COPY your-backup-file.tar /var/opt/gitlab/backups/your-backup-file.tar

# Run GitLab setup
RUN gitlab-ctl reconfigure
RUN gitlab-rake gitlab:backup:restore BACKUP=your-backup-file
