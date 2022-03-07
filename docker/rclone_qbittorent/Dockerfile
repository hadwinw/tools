FROM debian:bullseye-slim
RUN apt update && apt install -y rclone qbittorrent-nox ca-certificates && rm -rf /var/lib/apt/lists/*
RUN mkdir /down
COPY entrypoint.sh /sbin/
RUN chmod +x /sbin/entrypoint.sh
CMD /sbin/entrypoint.sh