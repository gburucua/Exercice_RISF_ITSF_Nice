# Dockerfile
#FROM nginx:latest

# Create the directories NGINX needs
#RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp \
#    && chmod -R 755 /var/cache/nginx


# Copy the static files into the Nginx web root directory
#COPY index.html /usr/share/nginx/html/index.html


FROM nginx:1.20
COPY index.html /usr/share/nginx/html/index.html
WORKDIR /app
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d && \
        chown -R nginx:nginx /usr/share/nginx/html

RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid

# Switch to the nginx user
USER nginx

#EXPOSE <PORT_NUMBER>

# Specify the command to run NGINX
CMD ["nginx", "-g", "daemon off;"]