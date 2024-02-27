# Dockerfile
FROM nginx:latest

# Copy the static files into the Nginx web root directory
COPY index.html /usr/share/nginx/html/index.html