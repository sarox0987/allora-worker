# Use a lightweight base image
FROM golang:1.22-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy go module files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the binary
RUN go build -o main .

# Use a smaller base image for the final image
FROM alpine:latest

# Copy the binary from the builder stage
COPY --from=builder /app/main /app/

# Set the working directory
WORKDIR /app

# Expose the port your application listens on
EXPOSE 8000

# Command to run the application
CMD ["./main"]