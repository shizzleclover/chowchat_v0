# Use Flutter's official Docker image
FROM cirrusci/flutter:stable

# Set working directory inside the container
WORKDIR /app

# Copy everything from your project into the container
COPY . .

# Build Flutter web in release mode
RUN flutter build web --release

# Install a simple static file server
RUN apt-get update && apt-get install -y nodejs npm
RUN npm install -g serve

# Expose port 10000 (Render expects apps to run on a port)
EXPOSE 10000

# Start the server to serve Flutter Web build
CMD ["serve", "-s", "build/web", "-l", "10000"]
