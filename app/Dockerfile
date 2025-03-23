# FROM nginx:alpine

# # Create a custom group and user
# RUN addgroup -g 3001 appgroup && \
#     adduser -D -u 1001 -G appgroup appuser

# # Copy website files
# COPY . /usr/share/nginx/html

# # Ensure correct permissions for the new user
# RUN mkdir -p /var/cache/nginx/client_temp && \
#     mkdir -p /var/run/nginx && \
#     chown -R 1001:3001 /var/cache/nginx && \
#     chown -R 1001:3001 /usr/share/nginx/html && \
#     chown -R 1001:3001 /var/run/nginx

# # Copy custom nginx config
# COPY nginx.conf /etc/nginx/nginx.conf

# # Switch to custom user
# USER 1001

# # Expose port 80
# EXPOSE 80

# # Start Nginx
# CMD ["nginx", "-g", "daemon off;"]


FROM nginx:alpine

# Create a custom group and user
RUN addgroup -g 3001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

# Copy website files
COPY . /usr/share/nginx/html

# Ensure correct permissions for the new user
RUN mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/run/nginx && \
    chown -R 1001:3001 /var/cache/nginx && \
    chown -R 1001:3001 /usr/share/nginx/html && \
    chown -R 1001:3001 /var/run/nginx

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose new port
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
