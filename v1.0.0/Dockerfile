FROM python:slim

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq unzip openssh-client gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/


# Install MongoDB tools (mongorestore, mongodump, and mongosh)
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y mongodb-mongosh mongodb-org-tools && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# # Copy scripts to a custom folder
# COPY scripts/*.sh /usr/local/scripts/
# RUN chmod +x /usr/local/scripts/*.sh

# # Add the custom folder to the PATH environment variable
# ENV PATH="/usr/local/scripts/:${PATH}"

# Start the script
CMD ["bash", "-c", "while true; do echo 'Hello World'; sleep 3600; done"]
