# Lightweight Nginx base image
FROM nginx:alpine

# Remove default nginx index.html
RUN rm -rf /usr/share/nginx/html/*

# Copy your custom index.html into correct path
COPY index.html /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
